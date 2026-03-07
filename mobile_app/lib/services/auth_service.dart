import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:async';

// Conditional import
import 'facebook_web_stub.dart'
    if (dart.library.js) 'facebook_web.dart' as fb_web;

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '459040907750-3hmh8t0rr61p6n6dq3f42d323otsjccf.apps.googleusercontent.com',
  );

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

  static Future<UserCredential?> signInWithFacebook() async {
    if (kIsWeb) {
      return fb_web.signInWithFacebookWeb(_auth);
    } else {
      return _facebookNative();
    }
  }

  static Future<UserCredential?> _facebookNative() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        print('FB native failed: ${result.status} - ${result.message}');
        return null;
      }

      final token = result.accessToken!.token;
      return await _auth
          .signInWithCredential(FacebookAuthProvider.credential(token));
    } catch (e) {
      print('Facebook native login error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      if (!kIsWeb) await FacebookAuth.instance.logOut();
      await _auth.signOut();
    } catch (e) {
      print("Sign out error: $e");
    }
  }
}