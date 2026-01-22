import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:convert';
import '../models/shot.dart';
import '../services/shot_manager.dart';
import '../services/cloud_shot_manager.dart';
import '../services/data_migration_service.dart';
import '../services/sound_manager.dart';
import '../services/notification_manager.dart';
import '../services/auth_service.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';
import 'data_analysis_screen.dart';
import 'life_reel_screen.dart';
import 'profile_screen.dart';

class DoPage extends StatefulWidget {
  const DoPage({super.key});

  @override
  State<DoPage> createState() => _DoPageState();
}

class _DoPageState extends State<DoPage> {
  final ShotManager _shotManager = ShotManager();
  final CloudShotManager _cloudShotManager = CloudShotManager();
  final DataMigrationService _migrationService = DataMigrationService();
  final AuthService _authService = AuthService();
  final SoundManager _soundManager = SoundManager();
  
  List<Shot> _shots = [];
  int _dailySuperTime = 60;
  Map<String, dynamic> _todayStats = {};
  Duration _timeUntilNextCycle = Duration.zero;
  Timer? _cycleTimer;
  Timer? _reminderTimer;
  bool _isMigrating = false;
  StreamSubscription<List<Shot>>? _cloudShotsSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _startCycleTimer();
    _startReminderTimer();
  }

  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);
    
    // Check if migration is needed
    final needsMigration = await _migrationService.needsMigration();
    
    if (needsMigration) {
      setState(() {
        _isMigrating = true;
      });
      
      // Migrate local data to cloud
      await _migrationService.migrateLocalDataToCloud();
      
      setState(() {
        _isMigrating = false;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Your data has been backed up to cloud!'),
            backgroundColor: Color(0xFF9C89B8),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    
    // Load data and listen to cloud changes
    await _loadData();
    _listenToCloudShots();
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _listenToCloudShots() {
    _cloudShotsSubscription = _cloudShotManager.getUserShotsStream().listen((cloudShots) {
      if (mounted) {
        setState(() {
          _shots = cloudShots;
        });
        // Also sync to local backup
        _migrationService.syncCloudToLocal();
      }
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _reminderTimer?.cancel();
    _cloudShotsSubscription?.cancel();
    super.dispose();
  }


  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final shots = await _shotManager.getShots();
    final stats = await _shotManager.getTodayStats();
    final timeUntilCycle = await _shotManager.getTimeUntilNextCycle();
    
    print('DEBUG: Loaded ${shots.length} shots');
    
    if (mounted) {
      setState(() {
        _shots = shots;
        _dailySuperTime = prefs.getInt('daily_super_time') ?? 60;
        _todayStats = stats;
        _timeUntilNextCycle = timeUntilCycle;
      });
    }

    // Check if cycle should reset
    if (await _shotManager.shouldResetCycle()) {
      _showCycleResetDialog();
    }
  }

  void _startCycleTimer() {
    _cycleTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final timeUntilCycle = await _shotManager.getTimeUntilNextCycle();
      setState(() {
        _timeUntilNextCycle = timeUntilCycle;
      });

      if (timeUntilCycle.isNegative) {
        _showCycleResetDialog();
      }
    });
  }

  void _startReminderTimer() {
    // 10-minute reminders
    _reminderTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _showReminder();
    });
  }

  void _showReminder() async {
    // Play loud sound + vibration
    final notificationManager = NotificationManager();
    await notificationManager.show10MinuteReminder();
    
    // Also show visual notification
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.access_time_filled, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '⏰ Time Check!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '10 minutes passed. What are you capturing?',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF9C89B8),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'GOT IT',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showCycleResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎬 New Cycle!'),
        content: const Text(
          'A new 4-hour cycle has begun. Your shots have been refreshed for this cycle.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _shotManager.startNewCycle();
              _loadData();
            },
            child: const Text('Start Fresh'),
          ),
        ],
      ),
    );
  }

  Future<void> _addShot() async {
    _soundManager.playClick();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _AddShotDialog(),
    );

    if (result != null) {
      final shot = Shot(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: result['title'],
        type: result['type'],
        captureFrame: result['captureFrame'] ?? false,
        createdAt: DateTime.now(),
      );

      // Save to both local and cloud
      await _shotManager.addShot(shot);
      await _cloudShotManager.addShot(shot);
      
      // Cloud will trigger automatic refresh via stream
    }
  }

  Future<void> _deleteShot(String shotId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shot?'),
        content: const Text('Are you sure you want to delete this shot? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _shotManager.deleteShot(shotId);
      await _loadData();
    }
  }

  void _startShot(Shot shot) {
    _soundManager.playStart();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          shot: shot,
          dailySuperTime: _dailySuperTime,
        ),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _openSettings() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
    
    if (result == true) {
      await _loadData();
    }
  }

  void _openLifeReel() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LifeReelScreen(),
      ),
    );
  }

  String _formatCycleTime(Duration duration) {
    if (duration.isNegative) return '0:00:00';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _todayStats['totalSeconds'] ?? 0;
    final shotsCompleted = _todayStats['shotsCompleted'] ?? 0;
    final capturedFrames = _todayStats['capturedFrames'] ?? 0;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addShot,
        backgroundColor: const Color(0xFF9C89B8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('New Shot'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
          onRefresh: () async {
            // Trigger cloud fetch
            await _cloudShotManager.getUserShotsStream().first;
            await _loadData();
          },
          color: const Color(0xFF9C89B8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Enjoy Super Time',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.account_circle_outlined),
                              color: Colors.white,
                              iconSize: 28,
                            ),
                            IconButton(
                              onPressed: _openLifeReel,
                              icon: const Icon(Icons.movie_outlined),
                              color: Colors.white,
                              iconSize: 28,
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const DataAnalysisScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.analytics_outlined),
                              color: Colors.white,
                              iconSize: 28,
                            ),
                            IconButton(
                              onPressed: _openSettings,
                              icon: const Icon(Icons.settings_outlined),
                              color: Colors.white,
                              iconSize: 28,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Cycle timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Next Cycle in',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatCycleTime(_timeUntilNextCycle),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stats row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.movie_filter,
                        label: 'Shots',
                        value: shotsCompleted.toString(),
                        color: const Color(0xFF9C89B8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer_outlined,
                        label: 'Time',
                        value: _formatDuration(totalSeconds),
                        color: const Color(0xFF9C89B8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.camera_alt_outlined,
                        label: 'Frames',
                        value: capturedFrames.toString(),
                        color: const Color(0xFF9C89B8),
                      ),
                    ),
                  ],
                ),
              ),

              // Section header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                child: Text(
                  '🎬 Today\'s Shot List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),

              // Shots list
              Expanded(
                child: _shots.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(48.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.movie_creation_outlined,
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
                                  'Pull down to sync\nOR\nAdd your first shot',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFBBBBBB),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                OutlinedButton(
                                  onPressed: () async {
                                    // Restore defaults option
                                    await _shotManager.createDefaultShots();
                                    _loadData();
                                  },
                                  child: const Text('Restore Default Activities'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _shots.length,
                        itemBuilder: (context, index) {
                          return _ShotCard(
                            shot: _shots[index],
                            onTap: () => _startShot(_shots[index]),
                            onDelete: () => _deleteShot(_shots[index].id),
                          );
                        },
                      ),
              ),
              
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
          if (_isLoading || _isMigrating)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C89B8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${totalSeconds}s';
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShotCard extends StatelessWidget {
  final Shot shot;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ShotCard({
    required this.shot,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C89B8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      shot.type.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            shot.type.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF9C89B8).withOpacity(0.7),
                            ),
                          ),
                          if (shot.captureFrame) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Color(0xFF9C89B8),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFBBBBBB),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddShotDialog extends StatefulWidget {
  const _AddShotDialog();

  @override
  State<_AddShotDialog> createState() => _AddShotDialogState();
}

class _AddShotDialogState extends State<_AddShotDialog> {
  late TextEditingController _controller;
  ShotType _selectedType = ShotType.action;
  bool _captureFrame = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'New Shot',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'What are you doing?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit_outlined),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Shot Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ShotType.values.length,
                itemBuilder: (context, index) {
                  final type = ShotType.values[index];
                  final isSelected = type == _selectedType;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF9C89B8) 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF9C89B8) 
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              type.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected 
                                    ? Colors.white 
                                    : const Color(0xFF666666),
                                fontWeight: isSelected 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            CheckboxListTile(
              value: _captureFrame,
              onChanged: (value) {
                setState(() {
                  _captureFrame = value ?? false;
                });
              },
              title: const Text('Capture Frame'),
              secondary: const Icon(Icons.camera_alt_outlined),
              activeColor: const Color(0xFF9C89B8),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  Navigator.pop(context, {
                    'title': _controller.text,
                    'type': _selectedType,
                    'captureFrame': _captureFrame,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C89B8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create Shot',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
