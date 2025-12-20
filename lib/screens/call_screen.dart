import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:est/widgets/retro_background.dart';
import 'package:est/widgets/retro_button.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

// IMPORTANT: REPLACEME with your Agora App ID
const String _kAppId = ""; 

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String _channelName = "test_channel";
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  final TextEditingController _channelController = TextEditingController(text: "test_channel");
  final TextEditingController _appIdController = TextEditingController(text: _kAppId);

  bool _inCall = false;
  bool _isMicMuted = false;
  bool _isVideoMuted = false;

  @override
  void initState() {
    super.initState();
  }



  Future<void> _initAgora() async {
    // Retrieve permissions
    if (!kIsWeb) {
      await [Permission.microphone, Permission.camera].request();
    }

    // Create the engine
    String appId = _appIdController.text.trim();
    if (appId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter an App ID")),
        );
        setState(() => _inCall = false);
        return;
    }

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onError: (ErrorCodeType err, String msg) {
            debugPrint("Agora Error: $err $msg");
        }
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: "", // Token is null for testing (if App is in Open mode)
      channelId: _channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    if (_inCall) {
        _disposeAgora();
    }
    super.dispose();
  }

  Future<void> _disposeAgora() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  void _onJoin() async {
    setState(() {
        _channelName = _channelController.text;
        _inCall = true;
    });
    await _initAgora();
  }

  void _onLeave() {
    setState(() {
      _inCall = false;
      _localUserJoined = false;
      _remoteUid = null;
    });
    _disposeAgora();
  }

  void _onToggleMic() {
      setState(() {
          _isMicMuted = !_isMicMuted;
      });
      _engine.muteLocalAudioStream(_isMicMuted);
  }

  void _onToggleVideo() {
      setState(() {
          _isVideoMuted = !_isVideoMuted;
      });
      _engine.muteLocalVideoStream(_isVideoMuted);
  }


  @override
  Widget build(BuildContext context) {
    return RetroBackground(
        child: SafeArea(
            child: _inCall ? _buildCallView() : _buildJoinView(),
        ),
    );
  }

  Widget _buildJoinView() {
      return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  const Text(
                      "VIDEO LINK",
                      style: TextStyle(
                          fontFamily: "Pixel",
                          fontSize: 32,
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                      ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.purpleAccent, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                          controller: _appIdController,
                          style: const TextStyle(color: Colors.white, fontFamily: "Pixel"),
                          decoration: const InputDecoration(
                              labelText: "APP ID",
                              labelStyle: TextStyle(color: Colors.purpleAccent, fontFamily: "Pixel"),
                              border: InputBorder.none,
                          ),
                      ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.cyanAccent, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                          controller: _channelController,
                          style: const TextStyle(color: Colors.white, fontFamily: "Pixel"),
                          decoration: const InputDecoration(
                              labelText: "CHANNEL NAME",
                              labelStyle: TextStyle(color: Colors.cyanAccent, fontFamily: "Pixel"),
                              border: InputBorder.none,
                          ),
                      ),
                  ),
                  const SizedBox(height: 40),
                  RetroButton(
                      label: "INITIATE LINK",
                      color: Colors.greenAccent,
                      onTap: _onJoin,
                  ),
                  const SizedBox(height: 20),
                  RetroButton(
                      label: "ABORT",
                      color: Colors.redAccent,
                      onTap: () => Navigator.pop(context),
                  ),
              ],
          ),
      );
  }

  Widget _buildCallView() {
    return Stack(
      children: [
        Center(
          child: _remoteVideo(),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 100,
            height: 150,
            child: Center(
              child: _localUserJoined
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
        _toolbar(),
      ],
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: _channelName),
        ),
      );
    } else {
      return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
               Text(
                "WAITING FOR REMOTE SIGNAL...",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Pixel", 
                    color: Colors.white54, 
                    fontSize: 20
                ),
              ),
               SizedBox(height: 20),
               CircularProgressIndicator(color: Colors.cyanAccent)
          ],
      );
    }
  }

  Widget _toolbar() {
      return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.black54,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      _toolbarBtn(
                          icon: _isMicMuted ? Icons.mic_off : Icons.mic,
                          color: _isMicMuted ? Colors.red : Colors.white,
                          onTap: _onToggleMic,
                      ),
                      const SizedBox(width: 20),
                      RetroButton(
                         label: "DISCONNECT",
                         color: Colors.redAccent,
                         fontSize: 12,
                         onTap: _onLeave,
                      ),
                       const SizedBox(width: 20),
                      _toolbarBtn(
                          icon: _isVideoMuted ? Icons.videocam_off : Icons.videocam,
                          color: _isVideoMuted ? Colors.red : Colors.white,
                          onTap: _onToggleVideo,
                      ),
                  ],
              ),
          ),
      );
  }

  Widget _toolbarBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
       return GestureDetector(
           onTap: onTap,
           child: Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                   color: Colors.black,
                   shape: BoxShape.circle,
                   border: Border.all(color: color, width: 2),
               ),
               child: Icon(icon, color: color, size: 28),
           ),
       );
  }
}
