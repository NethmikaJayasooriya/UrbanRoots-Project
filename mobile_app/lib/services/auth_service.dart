import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_app/core/api_constants.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '459040907750-3hmh8t0rr61p6n6dq3f42d323otsjccf.apps.googleusercontent.com',
  );

  // api base
  static String get _baseUrl => ApiConstants.baseUrl;

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
      final normalizedPhone = phone?.trim();
      final normalizedProvider = authProvider?.trim();
      final normalizedProfilePic = profilePic?.trim();

      final response = await http.post(
        Uri.parse('$_baseUrl/user/setup-profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          if (normalizedPhone != null && normalizedPhone.isNotEmpty)
            'phone': normalizedPhone,
          if (normalizedProvider != null && normalizedProvider.isNotEmpty)
            'authProvider': normalizedProvider,
          if (normalizedProfilePic != null && normalizedProfilePic.isNotEmpty)
            'profilePic': normalizedProfilePic,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Profile setup timed out. The server may be starting up.'),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("Backend mapping error: ${response.body}");
        throw Exception('Failed to setup profile on backend: ${response.body}');
      }
      debugPrint("Profile setup successful via backend.");
    } catch (e) {
      debugPrint("Error calling setupProfile: $e");
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
      debugPrint("Error checking onboarding status: $e");
      // edge case: fallback to setup on permission denial
      return false;
    }
  }

  static Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'last_login': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating last login: $e");
    }
  }

  // google strategy
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
      debugPrint("Google Sign-In Error: $e");
      rethrow;
    }
  }

  // auth teardown
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
  }
}
