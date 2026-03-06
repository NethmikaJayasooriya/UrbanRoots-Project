import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:js' as js;
import 'dart:async';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '459040907750-3hmh8t0rr61p6n6dq3f42d323otsjccf.apps.googleusercontent.com',
  );

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

  // ─── Facebook (router) ────────────────────────────────────────────────────
  static Future<UserCredential?> signInWithFacebook() async {
    if (kIsWeb) {
      return _facebookWeb();
    } else {
      return _facebookNative();
    }
  }

  // ─── Facebook Web — calls window.FB directly via dart:js ─────────────────
  static Future<UserCredential?> _facebookWeb() async {
    final completer = Completer<UserCredential?>();

    // Confirm FB object exists in the JS global scope
    final fb = js.context['FB'];
    if (fb == null) {
      print('ERROR: window.FB is null — SDK script did not load');
      return null;
    }

    print('window.FB found ✅ — calling FB.login()');

    fb.callMethod('login', [
      js.allowInterop((dynamic response) {
        final status = response['status'];
        print('FB.login callback — status: $status');

        if (status == 'connected') {
          final token =
              response['authResponse']['accessToken'] as String;
          print('FB access token received, signing into Firebase...');

          _auth
              .signInWithCredential(FacebookAuthProvider.credential(token))
              .then((uc) {
            print('Firebase Facebook login success: ${uc.user?.email}');
            completer.complete(uc);
          }).catchError((e) {
            print('Firebase signInWithCredential error: $e');
            completer.completeError(e);
          });
        } else {
          // User cancelled or denied
          print('FB login not connected. Status: $status');
          completer.complete(null);
        }
      }),
      // Request email + public_profile permissions
      js.JsObject.jsify({'scope': 'email,public_profile'})
    ]);

    return completer.future;
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