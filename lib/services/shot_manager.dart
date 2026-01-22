import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shot.dart';

class ShotManager {
  static const String _shotsKey = 'shots_v2';
  static const String _completedShotsKey = 'completed_shots';
  static const String _cycleStartKey = 'cycle_start_time';
  static const String _legacyActivitiesKey = 'activities';
  
  // Singleton pattern
  static final ShotManager _instance = ShotManager._internal();
  factory ShotManager() => _instance;
  ShotManager._internal();

  // Get all pending shots
  Future<List<Shot>> getShots() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we need to migrate from legacy activities
    if (!prefs.containsKey(_shotsKey) && prefs.containsKey(_legacyActivitiesKey)) {
      await _migrateLegacyActivities();
    }
    
    final shotsJson = prefs.getString(_shotsKey);
    if (shotsJson == null) {
      return [];
    }
    
    final List<dynamic> decoded = jsonDecode(shotsJson);
    return decoded.map((json) => Shot.fromJson(json)).toList();
  }

  // Create default shots (restore user's 12 activities) - PUBLIC
  Future<void> createDefaultShots() async {
    final defaultActivities = [
      'Coding',
      'Yoga',
      'Write',
      'Loop',
      'Sketch/paint',
      'Shoot 1kin1k',
      'Crunches/abs',
      'Resistance band/dumbell',
      'Read book',
      'Piano practice',
      'Go for audition/find acting work',
      'Self tape',
    ];
    
    final shots = defaultActivities.map((activity) {
      return Shot.fromLegacyActivity(activity);
    }).toList();
    
    await saveShots(shots);
  }

  // Restore missing defaults without deleting custom shots
  Future<void> restoreMissingDefaults() async {
    final defaultActivities = [
      'Coding',
      'Yoga',
      'Write',
      'Loop',
      'Sketch/paint',
      'Shoot 1kin1k',
      'Crunches/abs',
      'Resistance band/dumbell',
      'Read book',
      'Piano practice',
      'Go for audition/find acting work',
      'Self tape',
    ];

    final existingShots = await getShots();
    final existingTitles = existingShots.map((s) => s.title.toLowerCase()).toSet();

    // Find missing activities
    final missingActivities = defaultActivities.where((activity) {
      return !existingTitles.contains(activity.toLowerCase());
    }).toList();

    // Add missing ones
    for (final activity in missingActivities) {
      final newShot = Shot.fromLegacyActivity(activity);
      await addShot(newShot);
    }
  }

  // Save shots
  Future<void> saveShots(List<Shot> shots) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(shots.map((s) => s.toJson()).toList());
    await prefs.setString(_shotsKey, encoded);
  }

  // Get completed shots
  Future<List<Shot>> getCompletedShots() async {
    final prefs = await SharedPreferences.getInstance();
    final shotsJson = prefs.getString(_completedShotsKey);
    if (shotsJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(shotsJson);
    return decoded.map((json) => Shot.fromJson(json)).toList();
  }

  // Save completed shots
  Future<void> saveCompletedShots(List<Shot> shots) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(shots.map((s) => s.toJson()).toList());
    await prefs.setString(_completedShotsKey, encoded);
  }

  // Add a new shot
  Future<void> addShot(Shot shot) async {
    final shots = await getShots();
    shots.add(shot);
    await saveShots(shots);
  }

  // Update a shot
  Future<void> updateShot(Shot shot) async {
    final shots = await getShots();
    final index = shots.indexWhere((s) => s.id == shot.id);
    if (index != -1) {
      shots[index] = shot;
      await saveShots(shots);
    }
  }

  // Delete a shot
  Future<void> deleteShot(String shotId) async {
    final shots = await getShots();
    shots.removeWhere((s) => s.id == shotId);
    await saveShots(shots);
  }

  // Complete a shot
  Future<void> completeShot(Shot shot) async {
    // Remove from pending
    final shots = await getShots();
    shots.removeWhere((s) => s.id == shot.id);
    await saveShots(shots);
    
    // Add to completed
    shot.status = ShotStatus.completed;
    final completed = await getCompletedShots();
    completed.add(shot);
    await saveCompletedShots(completed);
    
    // Update total time for today
    await _updateTotalTimeToday(shot.totalDurationSeconds);
  }

  // Get cycle start time
  Future<DateTime> getCycleStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_cycleStartKey);
    
    if (timeString == null) {
      // Initialize new cycle
      final now = DateTime.now();
      await prefs.setString(_cycleStartKey, now.toIso8601String());
      return now;
    }
    
    return DateTime.parse(timeString);
  }

  // Start new cycle
  Future<void> startNewCycle() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(_cycleStartKey, now.toIso8601String());
  }

  // Check if cycle should reset (4 hours)
  Future<bool> shouldResetCycle() async {
    final cycleStart = await getCycleStartTime();
    final now = DateTime.now();
    final difference = now.difference(cycleStart);
    return difference.inHours >= 4;
  }

  // Get time until next cycle
  Future<Duration> getTimeUntilNextCycle() async {
    final cycleStart = await getCycleStartTime();
    final nextCycle = cycleStart.add(const Duration(hours: 4));
    final now = DateTime.now();
    return nextCycle.difference(now);
  }

  // Migrate legacy activities to shots
  Future<void> _migrateLegacyActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activities = prefs.getStringList(_legacyActivitiesKey) ?? [];
    
    if (activities.isEmpty) return;
    
    final shots = activities.map((activity) {
      return Shot.fromLegacyActivity(activity);
    }).toList();
    
    await saveShots(shots);
    
    // Don't delete legacy data, just mark as migrated
    await prefs.setBool('migrated_to_shots', true);
  }

  // Update total time for today
  Future<void> _updateTotalTimeToday(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'total_seconds_$today';
    
    final currentTotal = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, currentTotal + seconds);
  }

  // Get stats for today
  Future<Map<String, dynamic>> getTodayStats() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final totalSeconds = prefs.getInt('total_seconds_$today') ?? 0;
    
    final completed = await getCompletedShots();
    final todayCompleted = completed.where((shot) {
      final completedDate = shot.sessions.isNotEmpty 
          ? shot.sessions.last.endTime.toIso8601String().split('T')[0]
          : DateTime.now().toIso8601String().split('T')[0];
      return completedDate == today;
    }).toList();
    
    // Count by type
    final typeStats = <ShotType, int>{};
    for (var shot in todayCompleted) {
      typeStats[shot.type] = (typeStats[shot.type] ?? 0) + 1;
    }
    
    return {
      'totalSeconds': totalSeconds,
      'shotsCompleted': todayCompleted.length,
      'capturedFrames': todayCompleted.fold<int>(
        0, 
        (sum, shot) => sum + shot.capturedFrames,
      ),
      'typeStats': typeStats,
    };
  }
}
