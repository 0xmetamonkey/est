import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:est/widgets/retro_background.dart';
import 'package:est/widgets/retro_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

// IMPORTANT: Replace with your Agora App ID
const String _kAppId = ""; 

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  String _channelName = "audio_test";
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  final TextEditingController _channelController = TextEditingController(text: "audio_test");
  final TextEditingController _appIdController = TextEditingController(text: _kAppId);

  bool _inCall = false;
  bool _isMicMuted = false;
  bool _isSpeakerOn = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initAgora() async {
    // Retrieve permissions
    if (!kIsWeb) {
      await [Permission.microphone].request();
    }

    // Create the engine
    String appId = _appIdController.text.trim();
    if (appId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter an App ID")),
          );
        }
        setState(() => _inCall = false);
        return;
    }

    try {
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("✅ Local user ${connection.localUid} joined channel $_channelName");
            if (mounted) {
              setState(() {
                _localUserJoined = true;
              });
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("✅ Remote user $remoteUid joined");
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
              });
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("❌ Remote user $remoteUid left channel");
            if (mounted) {
              setState(() {
                _remoteUid = null;
              });
            }
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint("❌ Agora Error: $err - $msg");
          },
          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
            debugPrint("🔄 Connection state: $state, reason: $reason");
          },
        ),
      );

      // Enable audio
      await _engine.enableAudio();
      
      // Set audio profile for better quality
      await _engine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioGameStreaming,
      );

      if (!kIsWeb) {
        await _engine.setEnableSpeakerphone(_isSpeakerOn);
      }

      // Join channel with proper options
      await _engine.joinChannel(
        token: "",
        channelId: _channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
        ),
      );

      debugPrint("🎯 Attempting to join channel: $_channelName with App ID: ${appId.substring(0, 8)}...");
    } catch (e) {
      debugPrint("❌ Error initializing Agora: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
        setState(() => _inCall = false);
      }
    }
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

  void _onToggleSpeaker() {
      setState(() {
          _isSpeakerOn = !_isSpeakerOn;
      });
      _engine.setEnableSpeakerphone(_isSpeakerOn);
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
                  ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        colors: [Colors.greenAccent, Colors.cyanAccent],
                      ).createShader(rect);
                    },
                    child: const Text(
                        "AUDIO LINK",
                        style: TextStyle(
                            fontFamily: "Pixel",
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                        ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                      "VOICE ONLY • LIGHTWEIGHT",
                      style: TextStyle(
                          fontFamily: "Pixel",
                          fontSize: 14,
                          color: Colors.white54,
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
                      label: "INITIATE AUDIO LINK",
                      color: Colors.greenAccent,
                      onTap: _onJoin,
                  ),
                  const SizedBox(height: 20),
                  RetroButton(
                      label: "BACK",
                      color: Colors.grey,
                      onTap: () => Navigator.pop(context),
                  ),
              ],
          ),
      );
  }

  Widget _buildCallView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CALL STATUS
          ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                colors: [Colors.greenAccent, Colors.cyanAccent],
              ).createShader(rect);
            },
            child: const Text(
              "AUDIO LINK ACTIVE",
              style: TextStyle(
                fontFamily: "Pixel",
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 40),

          // CONNECTION STATUS
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black54,
              border: Border.all(
                color: _localUserJoined ? Colors.greenAccent : Colors.orange,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _localUserJoined ? Icons.check_circle : Icons.sync,
                  color: _localUserJoined ? Colors.greenAccent : Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 10),
                Text(
                  _localUserJoined ? "CONNECTED" : "CONNECTING...",
                  style: TextStyle(
                    fontFamily: "Pixel",
                    fontSize: 20,
                    color: _localUserJoined ? Colors.greenAccent : Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // REMOTE USER STATUS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              border: Border.all(color: Colors.purpleAccent, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _remoteUid != null ? Icons.person : Icons.person_outline,
                  color: _remoteUid != null ? Colors.pinkAccent : Colors.white54,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Text(
                  _remoteUid != null 
                      ? "REMOTE USER: $_remoteUid" 
                      : "WAITING FOR REMOTE...",
                  style: TextStyle(
                    fontFamily: "Pixel",
                    fontSize: 16,
                    color: _remoteUid != null ? Colors.pinkAccent : Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // CONTROLS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controlButton(
                icon: _isMicMuted ? Icons.mic_off : Icons.mic,
                label: _isMicMuted ? "MUTED" : "MIC ON",
                color: _isMicMuted ? Colors.red : Colors.greenAccent,
                onTap: _onToggleMic,
              ),
              const SizedBox(width: 20),
              _controlButton(
                icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                label: _isSpeakerOn ? "SPEAKER" : "EARPIECE",
                color: _isSpeakerOn ? Colors.cyanAccent : Colors.grey,
                onTap: _onToggleSpeaker,
              ),
            ],
          ),

          const SizedBox(height: 30),

          RetroButton(
            label: "DISCONNECT",
            color: Colors.redAccent,
            onTap: _onLeave,
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: "Pixel",
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
