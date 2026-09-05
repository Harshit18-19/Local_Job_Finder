import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Keeps the app usable until a Firebase project has been configured, while
/// making application submission fail clearly instead of silently saving local data.
class FirebaseBackendService {
  // Initial employer/reviewer Firebase Auth account. Additional reviewers should
  // receive the `reviewer` custom claim through the Firebase Admin SDK.
  static const _initialReviewerUid = 'kruxRHEHvzcJHNjnRXO7fB9XbZy2';
  static bool isReady = false;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await ensureSignedIn();
      isReady = true;
    } catch (_) {
      isReady = false;
    }
  }

  static Future<User> ensureSignedIn() async {
    if (!isReady && Firebase.apps.isEmpty) {
      throw StateError(
        'Firebase is not configured. Add your Firebase app configuration first.',
      );
    }
    final existing = FirebaseAuth.instance.currentUser;
    if (existing != null) return existing;
    return (await FirebaseAuth.instance.signInAnonymously()).user!;
  }

  static Future<bool> isReviewer() async {
    if (!isReady) return false;
    final user = await ensureSignedIn();
    if (user.uid == _initialReviewerUid) return true;
    final token = await user.getIdTokenResult(true);
    return token.claims?['role'] == 'reviewer';
  }
}
