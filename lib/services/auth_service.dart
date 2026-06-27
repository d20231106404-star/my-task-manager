import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== AUTHENTICATION =====

  // Register new user
  static Future<bool> register(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'name': '',
        'avatar': '',
      });

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return false; // User already exists
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Login user
  static Future<bool> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return false; // Invalid credentials
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  // Get current user email
  static String? getCurrentUser() {
    return FirebaseAuth.instance.currentUser?.email;
  }

  // Get current user UID
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Get current user (full object)
  static User? getCurrentUserObject() {
    return FirebaseAuth.instance.currentUser;
  }

  // ===== USER PROFILE =====

  // Get user profile data from Firestore
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    await _firestore.collection('users').doc(userId).update(data);
  }

  // Update user name
  static Future<void> updateUserName(String name) async {
    await updateUserProfile({'name': name});
  }

  // Update user avatar
  static Future<void> updateUserAvatar(String avatarUrl) async {
    await updateUserProfile({'avatar': avatarUrl});
  }
}
