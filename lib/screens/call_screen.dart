import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/agora_service.dart';
import '../services/wallet_service.dart';

class CallScreen extends StatefulWidget {
  final bool isVideoMode;
  final String channelId;
  final String token;

  const CallScreen({
    super.key,
    required this.isVideoMode,
    required this.channelId,
    required this.token,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final AgoraService _agoraService = AgoraService();
  final WalletService _walletService = WalletService();
  
  // Billing Logic
  Timer? _billingTimer;
  int _seconds = 0;
  // Rates: 10 for Audio, 20 for Video
  late final int _tokensPerMinute = widget.isVideoMode ? 20 : 10;
  int _tokensSpent = 0;

  @override
  void initState() {
    super.initState();
    _initCall();
    _startBillingTimer();
  }

  Future<void> _initCall() async {
    print("=== CALL SCREEN INIT START ===");
    // 0. Load wallet balance from storage FIRST
    await _walletService.init();
    print("Wallet loaded: ${_walletService.balance.value} tokens");
    
    // 1. Check Balance
    if (_walletService.balance.value < _tokensPerMinute) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Insufficient Tokens! You have ${_walletService.balance.value}, need $_tokensPerMinute"), backgroundColor: Colors.red)
        );
        Navigator.pop(context);
      }
      return;
    }

    try {
      print("Starting Agora init...");
      await _agoraService.initialize(
        channelName: widget.channelId,
        token: widget.token,
        isVideoMode: widget.isVideoMode,
      );
      print("Agora init SUCCESS!");
    } catch (e) {
      print("AGORA FAILED: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to connect: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _startBillingTimer() {
    _billingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _seconds++);
        
        // Deduct every 60 seconds (or immediately at start if you prefer, but lets do per minute)
        if (_seconds > 0 && _seconds % 60 == 0) {
          _processDeduction();
        }
      }
    });
  }

  Future<void> _processDeduction() async {
    final success = await _walletService.deduct(_tokensPerMinute);
    if (success) {
      setState(() => _tokensSpent += _tokensPerMinute);
    } else {
      _endSession(reason: "Insufficient Tokens");
    }
  }

  @override
  void dispose() {
    _billingTimer?.cancel();
    _agoraService.leaveChannel();
    super.dispose();
  }

  // Cost calculation helpers
  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _endSession({String? reason}) {
    // Show Summary Dialog
    _agoraService.leaveChannel();
    _billingTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(reason == null ? 'Session Ended' : 'Call Ended'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reason != null) ...[
              Text(reason, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
            ],
            const Text('Total Duration:'),
            Text(_formatTime(_seconds), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Total Spent:'),
            Text('$_tokensSpent Tokens', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Dialog
              if (reason != null) Navigator.pop(context); // Screen if forced
              else Navigator.pop(context); // Screen normal
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Context Content (Video or Avatar)
            if (widget.isVideoMode) _buildVideoContent() else _buildAudioContent(),

            // 2. Connecting State (Spinner)
            ValueListenableBuilder<bool>(
              valueListenable: _agoraService.localUserJoined,
              builder: (context, joined, _) {
                 if (!joined) {
                   return const Center(
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         CircularProgressIndicator(color: Colors.white),
                         SizedBox(height: 20),
                         Text("Connecting securely...", style: TextStyle(color: Colors.white54)),
                       ],
                     ),
                   );
                 }
                 return const SizedBox.shrink();
              },
            ),

            // 3. Top Controls (Timer & Cost)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(_seconds),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_tokensSpent Tokens',
                        style: const TextStyle(color: Colors.purpleAccent, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Bottom Controls
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: _buildControlBar(),
            ),
            
            // 5. Error Overlay
            ValueListenableBuilder<String?>(
              valueListenable: _agoraService.lastError,
              builder: (context, error, _) {
                if (error == null) return const SizedBox.shrink();
                return Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
                    child: Text(error, style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    return Stack(
      children: [
        // Remote Video (Full)
        ValueListenableBuilder<int?>(
          valueListenable: _agoraService.remoteUid,
          builder: (context, remoteUid, _) {
            if (remoteUid == null || _agoraService.engine == null) {
              return const Center(child: Text("Waiting for client...", style: TextStyle(color: Colors.white30)));
            }
            return AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _agoraService.engine!,
                canvas: VideoCanvas(uid: remoteUid),
                connection: RtcConnection(channelId: widget.channelId),
              ),
            );
          },
        ),
        // Local Video (PIP)
        ValueListenableBuilder<bool>(
          valueListenable: _agoraService.localUserJoined,
          builder: (context, joined, _) {
            if (!joined || _agoraService.engine == null) return const SizedBox.shrink();
            return Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(12), color: Colors.black),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _agoraService.engine!,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAudioContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[900],
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.white54),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<int?>(
            valueListenable: _agoraService.remoteUid,
            builder: (context, uid, _) {
              return Text(
                uid == null ? "Waiting for audio..." : "Connected",
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.9),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Toggle
          ValueListenableBuilder<bool>(
            valueListenable: _agoraService.isMicMuted,
            builder: (context, isMuted, _) {
              return _ControlButton(
                icon: isMuted ? Icons.mic_off : Icons.mic,
                color: isMuted ? Colors.white : Colors.blue,
                bgColor: isMuted ? Colors.red : Colors.white10,
                onTap: _agoraService.toggleMute,
              );
            },
          ),

          // End Call (Big)
          _ControlButton(
            icon: Icons.call_end,
            color: Colors.white,
            bgColor: Colors.red,
            size: 64,
            onTap: () => _endSession(reason: "User Ended Call"),
          ),

          // Speaker/Camera Toggle
          if (widget.isVideoMode)
             _ControlButton(
              icon: Icons.cameraswitch, 
              color: Colors.white, 
              bgColor: Colors.white10,
              onTap: _agoraService.switchCamera,
            )
          else
            ValueListenableBuilder<bool>(
              valueListenable: _agoraService.isSpeakerOn,
              builder: (context, isSpeaker, _) {
                return _ControlButton(
                  icon: isSpeaker ? Icons.volume_up : Icons.phone_in_talk, 
                  color: isSpeaker ? Colors.blue : Colors.white,
                  bgColor: isSpeaker ? Colors.white24 : Colors.white10,
                  onTap: _agoraService.toggleSpeaker,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  final double size;

  const _ControlButton({required this.icon, required this.color, required this.bgColor, required this.onTap, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}
