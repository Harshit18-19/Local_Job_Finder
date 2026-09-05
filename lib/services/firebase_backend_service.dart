import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Keeps the app usable until a Firebase project has been configured, while
/// making application submission fail clearly instead of silently saving local data.
class FirebaseBackendService {
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
    final token = await ensureSignedIn().then((user) => user.getIdTokenResult(true));
    return token.claims?['role'] == 'reviewer';
  }
}
