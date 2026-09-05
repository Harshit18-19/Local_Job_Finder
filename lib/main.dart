import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/job_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_backend_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBackendService.initialize();
  final loggedIn = await AuthService.isLoggedIn();
  final onboardingComplete = await AuthService.hasCompletedOnboarding();
  runApp(LocalJobApp(
    loggedIn: loggedIn,
    onboardingComplete: onboardingComplete,
  ));
}

class LocalJobApp extends StatelessWidget {
  final bool loggedIn;
  final bool onboardingComplete;

  const LocalJobApp({
    super.key,
    required this.loggedIn,
    required this.onboardingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'Local Job Finder',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        home: onboardingComplete
            ? (loggedIn ? const JobListScreen() : const LoginScreen())
            : const OnboardingScreen(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: base,
      brightness: brightness,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }
}
