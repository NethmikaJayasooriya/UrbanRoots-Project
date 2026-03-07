import 'dart:js' as js;
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential?> signInWithFacebookWeb(FirebaseAuth auth) async {
  final completer = Completer<UserCredential?>();
  final fb = js.context['FB'];
  if (fb == null) return null;

  fb.callMethod('login', [
    js.allowInterop((dynamic response) {
      final status = response['status'];
      if (status == 'connected') {
        final token = response['authResponse']['accessToken'] as String;
        auth
            .signInWithCredential(FacebookAuthProvider.credential(token))
            .then((uc) => completer.complete(uc))
            .catchError((e) => completer.completeError(e));
      } else {
        completer.complete(null);
      }
    }),
    js.JsObject.jsify({'scope': 'email,public_profile'})
  ]);

  return completer.future;
}