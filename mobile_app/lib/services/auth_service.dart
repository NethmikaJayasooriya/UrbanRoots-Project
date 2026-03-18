import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '459040907750-3hmh8t0rr61p6n6dq3f42d323otsjccf.apps.googleusercontent.com',
  );

  // ─── Backend API endpoints ───────────────────────────────────────────────
  static const String _baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  static Future<void> setupProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? authProvider,
    String? profilePic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/setup-profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          if (phone != null) 'phone': phone,
          if (authProvider != null) 'authProvider': authProvider,
          if (profilePic != null) 'profilePic': profilePic,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("Backend mapping error: ${response.body}");
        throw Exception('Failed to setup profile on backend');
      }
      print("Profile setup successful via backend.");
    } catch (e) {
      print("Error calling setupProfile: $e");
      rethrow;
    }
  }

  static Future<bool> checkIsOnboarded(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.data()!['is_onboarded'] == true;
      }
      return false;
    } catch (e) {
      print("Error checking onboarding status: $e");
      // If permission denied, assume not onboarded so they go to SetupProfileScreen
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
