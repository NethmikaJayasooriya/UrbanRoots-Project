import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Web client ID from google-services.json (oauth_client with client_type: 3)
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '459040907750-3hmh8t0rr61p6n6dq3f42d323otsjccf.apps.googleusercontent.com',
  );

  /// Signs in with Google and returns the Firebase [UserCredential].
  ///
  /// Returns `null` if the user cancels the sign-in flow.
  /// Throws on network or Firebase errors.
  static Future<UserCredential?> signInWithGoogle() async {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // User cancelled the sign-in
    if (googleUser == null) return null;

    // Obtain the auth details from the Google Sign-In
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential for Firebase
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    return await _auth.signInWithCredential(credential);
  }

  /// Signs out from both Google and Firebase.
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
