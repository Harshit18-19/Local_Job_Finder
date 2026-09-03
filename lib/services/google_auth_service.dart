import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static bool _initialized = false;
  static StreamSubscription<GoogleSignInAuthenticationEvent>? _events;
  static final ValueNotifier<bool> signedIn = ValueNotifier(false);

  static Future<void> initialize() async {
    if (_initialized) return;
    final signIn = GoogleSignIn.instance;
    await signIn.initialize();
    _events ??= signIn.authenticationEvents.listen((event) {
      if (event case GoogleSignInAuthenticationEventSignIn(user: final user)) {
        unawaited(_completeSignIn(user));
      }
    });
    _initialized = true;
  }

  static Future<void> signIn() async {
    final signIn = GoogleSignIn.instance;
    await initialize();

    if (!signIn.supportsAuthenticate()) {
      return;
    }

    final account = await signIn.authenticate();
    await _completeSignIn(account);
  }

  static Future<void> _completeSignIn(GoogleSignInAccount account) async {
    await AuthService.signInWithGoogle(
      account.displayName?.trim().isNotEmpty == true
          ? account.displayName!.trim()
          : account.email.split('@').first,
      account.email,
    );
    signedIn.value = !signedIn.value;
  }
}
