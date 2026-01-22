import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:convert';
import '../models/shot.dart';

class DataMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Migrate local shots to Firebase
  Future<void> migrateLocalDataToCloud() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('No user logged in, cannot migrate');
      return;
    }

    try {
      print('🔄 Starting data migration to Firebase...');

      // 1. Get local shots from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final shotsJson = prefs.getString('shots');
      
      if (shotsJson == null) {
        print('✅ No local data to migrate');
        return;
      }

      // 2. Parse local shots
      final List<dynamic> decoded = jsonDecode(shotsJson);
      final localShots = decoded.map((json) => Shot.fromJson(json)).toList();

      print('📦 Found ${localShots.length} local shots to migrate');

      // 3. Upload each shot to Firestore
      for (final shot in localShots) {
        await _migrateSingleShot(user.uid, shot);
      }

      // 4. Mark migration as complete (don't delete local data yet!)
      await prefs.setBool('migrated_to_cloud', true);
      await prefs.setString('migration_date', DateTime.now().toIso8601String());

      print('✅ Migration complete! ${localShots.length} shots uploaded to Firebase');
      print('💾 Local data preserved as backup');

    } catch (e) {
      print('❌ Migration error: $e');
      // Don't delete local data if migration fails!
    }
  }

  // Migrate a single shot and its media
  Future<void> _migrateSingleShot(String userId, Shot shot) async {
    try {
      // Check if shot already exists in cloud
      final existing = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shots')
          .where('createdAt', isEqualTo: Timestamp.fromDate(shot.createdAt))
          .where('title', isEqualTo: shot.title)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        print('⏭️  Shot "${shot.title}" already in cloud, skipping');
        return;
      }

      // Upload shot to Firestore
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shots')
          .add(shot.toJson());

      print('✓ Uploaded shot: ${shot.title}');

      // TODO: Migrate media files if they exist
      // (We'll handle media upload in next phase)

    } catch (e) {
      print('❌ Error migrating shot "${shot.title}": $e');
    }
  }

  // Check if migration is needed
  Future<bool> needsMigration() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final alreadyMigrated = prefs.getBool('migrated_to_cloud') ?? false;
    
    if (alreadyMigrated) {
      print('✅ Data already migrated on ${prefs.getString('migration_date')}');
      return false;
    }

    final hasLocalData = prefs.containsKey('shots');
    return hasLocalData;
  }

  // Sync: Pull cloud data and update local storage
  Future<void> syncCloudToLocal() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get cloud shots
      final cloudSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('shots')
          .get();

      final cloudShots = cloudSnapshot.docs.map((doc) {
        return Shot.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();

      final prefs = await SharedPreferences.getInstance();

      // Split into pending and completed
      final pending = cloudShots.where((s) => s.status != ShotStatus.completed).toList();
      final completed = cloudShots.where((s) => s.status == ShotStatus.completed).toList();

      // Save to standard keys used by ShotManager
      await prefs.setString('shots_v2', jsonEncode(pending.map((s) => s.toJson()).toList()));
      await prefs.setString('completed_shots', jsonEncode(completed.map((s) => s.toJson()).toList()));
      
      // Also update cloud backup key just in case
      await prefs.setString('shots_cloud_backup', jsonEncode(cloudShots.map((s) => s.toJson()).toList()));
      await prefs.setString('last_sync', DateTime.now().toIso8601String());

      print('✅ Synced from cloud: ${pending.length} pending, ${completed.length} completed');

    } catch (e) {
      print('❌ Sync error: $e');
    }
  }
}
