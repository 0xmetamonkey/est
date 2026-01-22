import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User canceled
      }

      // Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Create/update user profile in Firestore
      if (userCredential.user != null) {
        await _createOrUpdateUserProfile(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Create or update user profile in Firestore
  Future<void> _createOrUpdateUserProfile(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      // New user - create profile
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      await userRef.set(profile.toFirestore());
    } else {
      // Existing user - update last active
      await userRef.update({
        'lastActive': Timestamp.fromDate(DateTime.now()),
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
      });
    }
  }

  // Sign out
  Future<void> signOut() async {
    // Clear all local data first
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Then sign out from Firebase and Google
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Get user profile from Firestore
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Search users by email or name
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Add friend
  Future<void> addFriend(String friendUid) async {
    final currentUid = currentUser?.uid;
    if (currentUid == null) return;

    await _firestore.collection('users').doc(currentUid).update({
      'friendIds': FieldValue.arrayUnion([friendUid]),
    });

    // Also add current user to friend's list
    await _firestore.collection('users').doc(friendUid).update({
      'friendIds': FieldValue.arrayUnion([currentUid]),
    });
  }

  // Get friends
  Future<List<UserProfile>> getFriends() async {
    final currentUid = currentUser?.uid;
    if (currentUid == null) return [];

    final profile = await getUserProfile(currentUid);
    if (profile == null || profile.friendIds.isEmpty) return [];

    final friendProfiles = <UserProfile>[];
    for (final friendId in profile.friendIds) {
      final friendProfile = await getUserProfile(friendId);
      if (friendProfile != null) {
        friendProfiles.add(friendProfile);
      }
    }

    return friendProfiles;
  }
}
