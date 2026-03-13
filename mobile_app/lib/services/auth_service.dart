import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '459040907750-3hmh8t0rr61p6n6dq3f42d323otsjccf.apps.googleusercontent.com',
  );

  // ─── Firestore User Records ───────────────────────────────────────────────
  static Future<void> saveUserRecord(
    User user,
    Map<String, dynamic> data,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);

      final docSnapshot = await userRef.get();
      if (!docSnapshot.exists) {
        data['created_at'] = FieldValue.serverTimestamp();
      }
      data['last_login'] = FieldValue.serverTimestamp();

      await userRef.set(data, SetOptions(merge: true));
      print("User record saved/updated successfully.");
    } catch (e) {
      print("Error saving user record: $e");
    }
  }

  static Future<bool> checkIsOnboarded(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.data()!['is_onboaded'] == true;
      }
      return false;
    } catch (e) {
      print("Error checking onboarding status: $e");
      return false;
    }
  }

  static Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'last_login': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating last login: $e");
    }
  }

  // ─── Google ───────────────────────────────────────────────────────────────
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Sign out error: $e");
    }
  }
}
