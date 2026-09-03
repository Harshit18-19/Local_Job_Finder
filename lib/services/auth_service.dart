import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyLoggedIn = 'is_logged_in';
  static const _keyName = 'user_name';
  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';
  static const _keyOnboardingComplete = 'onboarding_complete';

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<String?> signUp(
      String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyEmail);
    if (existing != null && existing == email) {
      return 'Email already registered';
    }
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keyLoggedIn, true);
    return null;
  }

  static Future<String?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_keyEmail);
    final storedPassword = prefs.getString(_keyPassword);
    if (storedEmail == null) return 'No account found. Please sign up first.';
    if (storedEmail != email) return 'Email not found';
    if (storedPassword != password) return 'Incorrect password';
    await prefs.setBool(_keyLoggedIn, true);
    return null;
  }

  static Future<void> signInWithGoogle(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setBool(_keyLoggedIn, true);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
  }
}
