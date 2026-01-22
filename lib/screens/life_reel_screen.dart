import 'dart:io';
import 'package:flutter/material.dart';
import '../models/shot.dart';
import '../services/shot_manager.dart';
import '../services/cloud_shot_manager.dart';
import 'package:intl/intl.dart';
import 'video_player_screen.dart';

class LifeReelScreen extends StatefulWidget {
  const LifeReelScreen({super.key});

  @override
  State<LifeReelScreen> createState() => _LifeReelScreenState();
}

class _LifeReelScreenState extends State<LifeReelScreen> {
  final ShotManager _shotManager = ShotManager();
  final CloudShotManager _cloudShotManager = CloudShotManager();
  List<Shot> _completedShots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedShots();
  }

  Future<void> _loadCompletedShots() async {
    final shots = await _shotManager.getCompletedShots();
    setState(() {
      _completedShots = shots.reversed.toList(); // Most recent first
      _loading = false;
    });
  }

  Future<void> _showEditShotDialog(Shot shot) async {
    final titleController = TextEditingController(text: shot.title);
    ShotType selectedType = shot.type;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Shot Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ShotType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Activity Type',
                  border: OutlineInputBorder(),
                ),
                items: ShotType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text('${type.emoji} ${type.displayName}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedType = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C89B8),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      if (!mounted) return;
      setState(() => _loading = true);
      
      try {
        // Update local object
        // Create new shot object to avoid mutation issues
        final updatedShot = Shot(
          id: shot.id,
          title: titleController.text,
          type: selectedType,
          captureFrame: shot.captureFrame,
          createdAt: shot.createdAt,
          status: shot.status,
          startedAt: shot.startedAt,
          totalDurationSeconds: shot.totalDurationSeconds,
          capturedFrames: shot.capturedFrames,
          sessions: shot.sessions,
          videoPaths: shot.videoPaths,
          imagePaths: shot.imagePaths,
        );

        // Update in DBs
        await _shotManager.updateShot(updatedShot); // This might need check if updateCompletedShot exists, falling back to updateShot which deals with list
        
        // Actually ShotManager.updateShot updates the 'shots_v2' list (pending). 
        // We need to update the COMPLETED list.
        // Let's manually do it here to ideally:
        final allCompleted = await _shotManager.getCompletedShots();
        final index = allCompleted.indexWhere((s) => s.id == shot.id);
        if (index != -1) {
          allCompleted[index] = updatedShot;
          await _shotManager.saveCompletedShots(allCompleted);
        }
        
        // Update Cloud
        await _cloudShotManager.updateShot(updatedShot);
        
        // Refresh UI
        await _loadCompletedShots();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shot updated successfully')),
          );
        }
      } catch (e) {
        debugPrint('Error updating shot: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  void _playVideo(String videoPath, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoPath: videoPath,
          title: title,
        ),
      ),
    );
  }

  void _viewImage(String imagePath, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF9C89B8),
                    const Color(0xFF9C89B8).withOpacity(0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '🎞️ Your Life Reel',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _completedShots.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(48.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.movie_outlined,
                                  size: 64,
                                  color: const Color(0xFF9C89B8).withOpacity(0.3),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'No shots yet',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Complete your first shot to\nstart building your life reel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFBBBBBB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _completedShots.length,
                          itemBuilder: (context, index) {
                            return _TimelineItem(
                              shot: _completedShots[index],
                              isFirst: index == 0,
                              isLast: index == _completedShots.length - 1,
                              onPlayVideo: _playVideo,
                              onViewImage: _viewImage,
                              onEdit: () => _showEditShotDialog(_completedShots[index]),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Shot shot;
  final bool isFirst;
  final bool isLast;
  final Function(String, String) onPlayVideo;
  final Function(String, String) onViewImage;
  final VoidCallback onEdit;

  const _TimelineItem({
    required this.shot,
    required this.isFirst,
    required this.isLast,
    required this.onPlayVideo,
    required this.onViewImage,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final lastSession = shot.sessions.isNotEmpty 
        ? shot.sessions.last 
        : null;
    
    final timeString = lastSession != null
        ? DateFormat('h:mm a').format(lastSession.endTime)
        : '';

    final hasMedia = shot.videoPaths.isNotEmpty || shot.imagePaths.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C89B8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C89B8).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: hasMedia ? 160 : 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF9C89B8),
                        const Color(0xFF9C89B8).withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Shot card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onLongPress: onEdit,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            shot.type.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shot.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                Text(
                                  shot.type.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF9C89B8).withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (timeString.isNotEmpty)
                            Text(
                              timeString,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.timer_outlined,
                            label: _formatDuration(shot.totalDurationSeconds),
                          ),
                          if (shot.capturedFrames > 0) ...[
                            const SizedBox(width: 8),
                            _MetaChip(
                              icon: Icons.camera_alt_outlined,
                              label: '${shot.capturedFrames} frames',
                            ),
                          ],
                          if (shot.videoPaths.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _MetaChip(
                              icon: Icons.videocam_outlined,
                              label: '${shot.videoPaths.length} videos',
                            ),
                          ],
                        ],
                      ),
                      
                      // Media thumbnails
                      if (hasMedia) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              // Video thumbnails
                              ...shot.videoPaths.map((videoPath) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => onPlayVideo(videoPath, shot.title),
                                  child: Container(
                                    width: 100,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF9C89B8).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          Icons.movie_outlined,
                                          color: Colors.white.withOpacity(0.5),
                                          size: 32,
                                        ),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF9C89B8),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF9C89B8).withOpacity(0.5),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                              // Image thumbnails
                              ...shot.imagePaths.map((imagePath) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => onViewImage(imagePath, shot.title),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF9C89B8).withOpacity(0.3),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.file(
                                        File(imagePath),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.broken_image_outlined,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF9C89B8).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF9C89B8),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF9C89B8).withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
