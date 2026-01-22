import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shot.dart';
import '../services/shot_manager.dart';
import '../services/sound_manager.dart';
import 'camera_recording_screen.dart';
import '../services/cloud_shot_manager.dart';

class TimerScreen extends StatefulWidget {
  final Shot shot;
  final int dailySuperTime;

  const TimerScreen({
    super.key,
    required this.shot,
    required this.dailySuperTime,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final ShotManager _shotManager = ShotManager();
  final SoundManager _soundManager = SoundManager();
  final CloudShotManager _cloudShotManager = CloudShotManager();
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  DateTime? _sessionStartTime;
  int _capturedFramesThisSession = 0;

  @override
  void initState() {
    super.initState();
    _seconds = widget.shot.totalDurationSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _soundManager.playStop();
    } else {
      _soundManager.playStart();
    }
    
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _sessionStartTime = DateTime.now();
      widget.shot.status = ShotStatus.active;
      widget.shot.startedAt = _sessionStartTime;
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
        });
      });
    } else {
      _timer?.cancel();
      widget.shot.status = ShotStatus.pending;
    }
  }

  Future<void> _captureFrame() async {
    _soundManager.playCamera();
    
    // Open camera recording screen
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CameraRecordingScreen(
          shotTitle: widget.shot.title,
          shotType: '${widget.shot.type.emoji} ${widget.shot.type.displayName}',
        ),
      ),
    );

    // Handle captured media from camera screen
    if (result != null && result is Map<String, dynamic>) {
      final videos = result['videos'] as List<String>? ?? [];
      final images = result['images'] as List<String>? ?? [];
      final frameCount = result['frameCount'] as int? ?? 0;
      
      setState(() {
        _capturedFramesThisSession += frameCount;
        widget.shot.capturedFrames += frameCount;
        
        // Add captured media paths to shot
        widget.shot.videoPaths.addAll(videos);
        widget.shot.imagePaths.addAll(images);
      });

      if (videos.isNotEmpty || images.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Captured ${videos.length} videos, ${images.length} photos'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _endSession() async {
    _timer?.cancel();
    _soundManager.playComplete();
    
    // Save session data
    if (_sessionStartTime != null) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!).inSeconds;
      final session = ShotSession(
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        durationSeconds: sessionDuration,
      );
      widget.shot.sessions.add(session);
    }
    
    widget.shot.totalDurationSeconds = _seconds;
    
    // Complete the shot
    await _shotManager.completeShot(widget.shot);
    await _cloudShotManager.updateShot(widget.shot);
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C89B8).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.shot.type.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '🎬 Shot Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.shot.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C89B8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duration:'),
                        Text(
                          _formatDuration(_seconds),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (_capturedFramesThisSession > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Frames captured:'),
                          Text(
                            '$_capturedFramesThisSession',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shot type:'),
                        Text(
                          '${widget.shot.type.emoji} ${widget.shot.type.displayName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C89B8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      if (_isRunning) {
                        _toggleTimer();
                      }
                      // Save progress before leaving
                      widget.shot.totalDurationSeconds = _seconds;
                      await _shotManager.updateShot(widget.shot);
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  // Shot type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C89B8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.shot.type.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.shot.type.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9C89B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Shot title
              Center(
                child: Column(
                  children: [
                    const Text(
                      '🎬 Now Shooting',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF999999),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.shot.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Timer display
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isRunning 
                        ? const Color(0xFF9C89B8).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(_seconds),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w200,
                      color: _isRunning 
                          ? const Color(0xFF9C89B8)
                          : const Color(0xFF2D2D2D),
                      letterSpacing: -2,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Capture frame button (always visible when running)
                  if (_isRunning)
                    GestureDetector(
                      onTap: _captureFrame,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF9C89B8),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9C89B8).withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF9C89B8),
                          size: 28,
                        ),
                      ),
                    ),
                  
                  if (_isRunning)
                    const SizedBox(width: 32),
                  
                  // Start/Pause button
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C89B8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C89B8).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // End session button
              if (_seconds > 0)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _endSession,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9C89B8),
                      side: const BorderSide(
                        color: Color(0xFF9C89B8),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '✅ Complete Shot',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
