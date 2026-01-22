import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shot.dart';
import '../models/story.dart';

class CloudShotManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  // Get user's shots from Firestore
  Stream<List<Shot>> getUserShotsStream() {
    if (_currentUid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('shots')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Shot.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();
    });
  }

  // Add shot to Firestore
  Future<String?> addShot(Shot shot) async {
    if (_currentUid == null) return null;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_currentUid)
          .collection('shots')
          .add(shot.toJson());

      // After adding, check for potential story connections
      await _detectStoryConnections(docRef.id, shot);

      return docRef.id;
    } catch (e) {
      print('Error adding shot: $e');
      return null;
    }
  }

  // Update shot
  Future<void> updateShot(Shot shot) async {
    if (_currentUid == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('shots')
        .doc(shot.id)
        .set(shot.toJson(), SetOptions(merge: true));
  }

 // Delete shot
  Future<void> deleteShot(String shotId) async {
    if (_currentUid == null) return;

    await _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('shots')
        .doc(shotId)
        .delete();
  }

  // STORY DETECTION ALGORITHM
  Future<void> _detectStoryConnections(String shotId, Shot shot) async {
    if (_currentUid == null) return;

    // Extract @mentions from title
    final mentions = _extractMentions(shot.title);
    
    if (mentions.isEmpty) return; // No mentions, no connections

    // For each mentioned user, find their recent shots
    for (final mentionedEmail in mentions) {
      await _findConnectionsWithUser(shotId, shot, mentionedEmail);
    }
  }

  // Extract @mentions from text
  List<String> _extractMentions(String text) {
    final regex = RegExp(r'@(\S+)');
    return regex
        .allMatches(text)
        .map((m) => m.group(1)!)
        .toList();
  }

  // Find story connections with a specific user
  Future<void> _findConnectionsWithUser(
    String shotId,
    Shot shot,
    String mentionedIdentifier,
  ) async {
    try {
      // Find user by email or name
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: mentionedIdentifier)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) return;

      final mentionedUserId = userQuery.docs.first.id;

      // Get their recent shots (last 48 hours)
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 48));
      
      final theirShotsQuery = await _firestore
          .collection('users')
          .doc(mentionedUserId)
          .collection('shots')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
          .get();

      // Score each potential connection
      for (final theirShotDoc in theirShotsQuery.docs) {
        final theirShot = Shot.fromJson({
          ...theirShotDoc.data(),
          'id': theirShotDoc.id,
        });

        final score = _calculateConnectionScore(shot, theirShot);

        if (score > 50) {
          // High enough score - create connection suggestion
          await _createConnectionSuggestion(
            shotId,
            theirShotDoc.id,
            mentionedUserId,
            score,
          );
        }
      }
    } catch (e) {
      print('Error finding connections: $e');
    }
  }

  // Calculate connection score between two shots
  double _calculateConnectionScore(Shot shot1, Shot shot2) {
    double score = 0;

    // 1. Mentioned the other user (high confidence)
    if (_extractMentions(shot1.title).isNotEmpty) {
      score += 50;
    }

    // 2. Keyword overlap
    final keywords1 = _extractKeywords(shot1.title);
    final keywords2 = _extractKeywords(shot2.title);
    final commonKeywords = keywords1.intersection(keywords2);
    score += commonKeywords.length * 10;

    // 3. Time proximity (within 48 hours)
    final timeDiff = shot1.createdAt.difference(shot2.createdAt).abs();
    if (timeDiff.inHours < 48) {
      score += 30 - (timeDiff.inHours / 2);
    }

    // 4. Shot type similarity
    if (shot1.type == shot2.type) {
      score += 10;
    }

    return score;
  }

  // Extract keywords (simple implementation)
  Set<String> _extractKeywords(String text) {
    final stopWords = {'the', 'a', 'an', 'to', 'for', 'from', 'in', 'on', 'at'};
    return text
        .toLowerCase()
        .split(RegExp(r'[\s@]+'))
        .where((word) => word.length > 2 && !stopWords.contains(word))
        .toSet();
  }

  // Create connection suggestion
  Future<void> _createConnectionSuggestion(
    String fromShotId,
    String toShotId,
    String toUserId,
    double score,
  ) async {
    final connection = StoryConnection(
      fromShotId: '$_currentUid/$fromShotId',
      toShotId: '$toUserId/$toShotId',
      confidenceScore: score,
      reasons: [],
      detectedAt: DateTime.now(),
    );

    await _firestore
        .collection('story_connections')
        .add(connection.toFirestore());

    // TODO: Send notification to both users
  }

  // Get pending story connections for current user
  Stream<List<StoryConnection>> getPendingConnectionsStream() {
    if (_currentUid == null) return Stream.value([]);

    return _firestore
        .collection('story_connections')
        .where('fromShotId', isGreaterThanOrEqualTo: '$_currentUid/')
        .where('fromShotId', isLessThan: '$_currentUid/\uf8ff')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StoryConnection.fromFirestore(doc))
          .toList();
    });
  }

  // Accept a story connection
  Future<void> acceptConnection(String connectionId) async {
    await _firestore
        .collection('story_connections')
        .doc(connectionId)
        .update({'status': 'accepted'});

    // TODO: Create or update Story
  }

  // Reject a story connection
  Future<void> rejectConnection(String connectionId) async {
    await _firestore
        .collection('story_connections')
        .doc(connectionId)
        .update({'status': 'rejected'});
  }
}
