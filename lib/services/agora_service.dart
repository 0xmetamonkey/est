import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  RtcEngine? _engine;
  final String _appId = '4077f6fd011c42e9aaac7d1ee0075d95';

  // State
  final ValueNotifier<int?> remoteUid = ValueNotifier<int?>(null);
  final ValueNotifier<bool> localUserJoined = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isMicMuted = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isSpeakerOn = ValueNotifier<bool>(true);
  final ValueNotifier<String?> lastError = ValueNotifier<String?>(null);

  RtcEngine? get engine => _engine;

  void _log(String msg) {
    debugPrint("[Agora] $msg");
  }

  Future<void> initialize({
    required String channelName,
    required String token,
    required bool isVideoMode,
  }) async {
    _log("=== STARTING INITIALIZATION ===");
    
    // Reset state
    remoteUid.value = null;
    localUserJoined.value = false;
    lastError.value = null;

    try {
      // Step 1: Permissions
      _log("Requesting permissions...");
      final permissions = [Permission.microphone, if (isVideoMode) Permission.camera];
      final statuses = await permissions.request();
      
      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        throw Exception("Microphone permission required");
      }
      if (isVideoMode && statuses[Permission.camera] != PermissionStatus.granted) {
        throw Exception("Camera permission required");
      }
      _log("✓ Permissions granted");

      // Step 2: Create engine if needed
      if (_engine == null) {
        _log("Creating engine...");
        _engine = createAgoraRtcEngine();
        await _engine!.initialize(RtcEngineContext(
          appId: _appId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ));
        _log("✓ Engine created");
        
        // Register handlers ONCE
        _engine!.registerEventHandler(RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            _log("✓ Joined: ${connection.localUid}");
            localUserJoined.value = true;
          },
          onUserJoined: (connection, uid, elapsed) {
            _log("✓ Remote user joined: $uid");
            remoteUid.value = uid;
          },
          onUserOffline: (connection, uid, reason) {
            _log("✗ Remote user left: $uid");
            remoteUid.value = null;
          },
          onError: (err, msg) {
            _log("ERROR: $err - $msg");
            lastError.value = msg;
          },
        ));
      }

      // Step 3: Configure for video or audio
      if (isVideoMode) {
        _log("Enabling video...");
        await _engine!.enableVideo();
        await _engine!.startPreview();
        _log("✓ Video enabled");
      } else {
        _log("Audio-only mode");
        await _engine!.disableVideo();
      }

      // Step 4: Set role
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      
      // Step 5: Join channel
      _log("Joining channel: $channelName");
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: 0,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: isVideoMode,
          publishMicrophoneTrack: true,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );
      _log("✓ Join request sent");
      
      // Step 6: Set speaker AFTER joining (non-critical)
      try {
        await _engine!.setEnableSpeakerphone(isVideoMode);
        _log("✓ Speaker set");
      } catch (e) {
        _log("Speaker setting skipped: $e");
        // Non-critical - ignore
      }

    } catch (e) {
      _log("FATAL ERROR: $e");
      lastError.value = e.toString();
      rethrow;
    }
  }

  Future<void> leaveChannel() async {
    _log("Leaving channel...");
    await _engine?.leaveChannel();
    await _engine?.stopPreview();
    remoteUid.value = null;
    localUserJoined.value = false;
  }

  Future<void> toggleMute() async {
    final newMute = !isMicMuted.value;
    await _engine?.muteLocalAudioStream(newMute);
    isMicMuted.value = newMute;
  }

  Future<void> toggleSpeaker() async {
    final newSpeaker = !isSpeakerOn.value;
    await _engine?.setEnableSpeakerphone(newSpeaker);
    isSpeakerOn.value = newSpeaker;
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }

  Future<void> dispose() async {
    await leaveChannel();
    await _engine?.release();
    _engine = null;
  }
}
