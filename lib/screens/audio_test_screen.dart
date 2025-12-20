import 'dart:async';
import 'package:est/widgets/retro_background.dart';
import 'package:est/widgets/retro_button.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioTestScreen extends StatefulWidget {
  const AudioTestScreen({super.key});

  @override
  State<AudioTestScreen> createState() => _AudioTestScreenState();
}

class _AudioTestScreenState extends State<AudioTestScreen> {
  late AudioRecorder _audioRecorder;
  late AudioPlayer _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/test_audio.m4a';
        
        // Config for v5
        await _audioRecorder.start(const RecordConfig(), path: path);
        
        setState(() {
          _isRecording = true;
          _audioPath = null;
        });
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
    } catch (e) {
      debugPrint("Error stopping record: $e");
    }
  }

  Future<void> _playRecording() async {
    if (_audioPath != null) {
      try {
        Source urlSource = DeviceFileSource(_audioPath!);
        await _audioPlayer.play(urlSource);
        setState(() => _isPlaying = true);
      } catch (e) {
        debugPrint("Error playing audio: $e");
      }
    }
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return RetroBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TITLE
            ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  colors: [Colors.green, Colors.cyanAccent],
                ).createShader(rect);
              },
              child: const Text(
                "AUDIO LINK TEST",
                style: TextStyle(
                  fontFamily: "Pixel",
                  color: Colors.white,
                  fontSize: 28,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 50),

            // STATUS INDICATOR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: _isRecording ? Colors.red : (_isPlaying ? Colors.green : Colors.grey),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isRecording ? Colors.red.withOpacity(0.5) : (_isPlaying ? Colors.green.withOpacity(0.5) : Colors.transparent),
                    blurRadius: 15,
                  )
                ],
              ),
              child: Text(
                _isRecording ? "RECORDING..." : (_isPlaying ? "PLAYING..." : "READY"),
                style: TextStyle(
                  fontFamily: "Pixel",
                  color: _isRecording ? Colors.red : (_isPlaying ? Colors.green : Colors.grey),
                  fontSize: 24,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // CONTROLS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // RECORD BUTTON
                GestureDetector(
                  onLongPress: _startRecording,
                  onLongPressUp: _stopRecording,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRecording ? Colors.redAccent : Colors.cyan,
                        width: 4,
                      ),
                      color: _isRecording ? Colors.redAccent.withOpacity(0.2) : Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: _isRecording ? Colors.redAccent : Colors.cyan,
                          blurRadius: _isRecording ? 20 : 0,
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.mic,
                      color: _isRecording ? Colors.redAccent : Colors.cyan,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Text(
              "HOLD TO RECORD",
              style: TextStyle(
                fontFamily: "Pixel",
                color: Colors.white54,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // PLAYBACK CONTROLS
            if (_audioPath != null && !_isRecording)
              RetroButton(
                label: _isPlaying ? "STOP PLAYBACK" : "PLAY RECORDING",
                color: _isPlaying ? Colors.red : Colors.greenAccent,
                onTap: _isPlaying ? _stopPlayback : _playRecording,
              ),

            const SizedBox(height: 30),
            
            RetroButton(
              label: "BACK",
              color: Colors.grey,
              fontSize: 14,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
