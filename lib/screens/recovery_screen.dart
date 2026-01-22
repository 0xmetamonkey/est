import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/shot.dart';
import '../services/shot_manager.dart';
import '../services/cloud_shot_manager.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  bool _isLoading = true;
  List<FileSystemEntity> _foundFiles = [];
  Set<String> _selectedPaths = {};
  final ShotManager _shotManager = ShotManager();
  final CloudShotManager _cloudShotManager = CloudShotManager();

  // Customization state
  final TextEditingController _titleController = TextEditingController(text: 'Recovered Memory');
  ShotType _selectedType = ShotType.content;

  @override
  void initState() {
    super.initState();
    _scanForFiles();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _scanForFiles() async {
    setState(() => _isLoading = true);
    
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();
      
      final List<FileSystemEntity> allFiles = [];
      
      // internal helper to safely list files
      void addFilesFrom(Directory dir) {
        try {
          if (dir.existsSync()) {
            allFiles.addAll(dir.listSync(recursive: true));
          }
        } catch (e) {
          print('Error scanning ${dir.path}: $e');
        }
      }

      addFilesFrom(docsDir);
      addFilesFrom(tempDir);
      
      // Filter for ANY media file to debug naming
      final mediaFiles = allFiles.where((file) {
        if (file is! File) return false;
        final name = file.path.split(Platform.pathSeparator).last.toLowerCase();
        // Ignore files that start with '.', they are usually system junk
        if (name.startsWith('.')) return false;
        
        return name.endsWith('.jpg') || name.endsWith('.jpeg') || 
               name.endsWith('.png') || name.endsWith('.mp4') || 
               name.endsWith('.mov');
      }).toList();

      // Sort by modification time (newest first)
      mediaFiles.sort((a, b) {
        return b.statSync().modified.compareTo(a.statSync().modified);
      });

      setState(() {
        _foundFiles = mediaFiles;
        // Don't auto-select everything
        _selectedPaths = {}; 
      });
    } catch (e) {
      debugPrint('Error scanning files: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cleanupRecoveredItems() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove "Recovered Memory" Items?'),
        content: const Text(
          'This will delete all shots named "Recovered Memory" from your Life Reel.\n\n'
          'Use this to clean up clutter before trying again with better names.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    
    try {
      // 1. Get all completed shots
      final shots = await _shotManager.getCompletedShots();
      
      // 2. Identify ones to delete
      final toDelete = shots.where((s) => s.title == 'Recovered Memory').toList();
      
      if (toDelete.isEmpty) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No generic recovered items found to delete.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // 3. Remove them locally
      shots.removeWhere((s) => s.title == 'Recovered Memory');
      await _shotManager.saveCompletedShots(shots);
      
      // 4. Remove from Cloud
      for (final shot in toDelete) {
        await _cloudShotManager.deleteShot(shot.id);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${toDelete.length} clutter items.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error cleaning up: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cleaning up: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreSelected() async {
    if (_selectedPaths.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      int restoredCount = 0;
      
      // Use the custom title/type for all selected items
      final customTitle = _titleController.text.trim().isEmpty 
          ? 'Recovered Memory' 
          : _titleController.text.trim();
          
      for (final path in _selectedPaths) {
        final file = File(path);
        final name = path.split(Platform.pathSeparator).last;
        final stats = await file.stat();
        final date = stats.modified;
        
        // Determine type
        final nameLower = name.toLowerCase();
        final isVideo = nameLower.endsWith('.mp4') || nameLower.endsWith('.mov');
        
        // Create a new shot for this recovery
        final shot = Shot(
          id: 'recovered_${date.millisecondsSinceEpoch}_${name.hashCode}',
          title: customTitle,
          type: _selectedType,
          createdAt: date,
          status: ShotStatus.completed,
          totalDurationSeconds: 0, 
          capturedFrames: isVideo ? 0 : 1,
        );
        
        // Add a session to correctly backdate the completion time
        shot.sessions.add(ShotSession(
          startTime: date,
          endTime: date,
          durationSeconds: 0,
        ));
        
        // Add specific media
        if (isVideo) {
          shot.videoPaths.add(path);
        } else {
          shot.imagePaths.add(path);
        }

        // Save to Local and Cloud
        await _shotManager.completeShot(shot); // This saves to completed_shots local
        await _cloudShotManager.updateShot(shot); // This sends to Firestore (creates new doc if needed)
        
        restoredCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Restored $restoredCount items as "$customTitle"!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recover Lost Media'),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _foundFiles.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No media files found on device.'),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // --- Customization Header ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '1. Name these items (Optional):', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Yoga Session, Coding, Trip...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '2. Select Activity Type:', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ShotType>(
                                isExpanded: true,
                                value: _selectedType,
                                items: ShotType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text('${type.emoji} ${type.displayName}'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedType = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Undo / Cleanup ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _cleanupRecoveredItems,
                          icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                          label: const Text(
                            'Delete previous "Recovered Memory" items', 
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ),
                    ),

                    const Divider(height: 1),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Found ${_foundFiles.length} media files.\nSelect items to restore:',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _foundFiles.length,
                        itemBuilder: (context, index) {
                          final file = _foundFiles[index];
                          final path = file.path;
                          final name = path.split(Platform.pathSeparator).last;
                          final isSelected = _selectedPaths.contains(path);
                          final stat = file.statSync();
                          final isVideo = name.toLowerCase().endsWith('.mp4');
                          
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedPaths.add(path);
                                } else {
                                  _selectedPaths.remove(path);
                                }
                              });
                            },
                            title: Text(
                              name, 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(_formatDate(stat.modified)),
                            secondary: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isVideo ? Colors.blue[50] : Colors.purple[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isVideo ? Icons.videocam : Icons.image,
                                color: isVideo ? Colors.blue : const Color(0xFF9C89B8),
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: _selectedPaths.isEmpty ? null : _restoreSelected,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C89B8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32, 
                              vertical: 16
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Restore ${_selectedPaths.length} Items',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
