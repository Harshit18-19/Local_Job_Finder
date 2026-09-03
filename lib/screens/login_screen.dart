import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../widgets/google_login_button.dart';
import 'signup_screen.dart';
import 'job_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    GoogleAuthService.initialize().catchError((_) {});
    GoogleAuthService.signedIn.addListener(_finishGoogleLogin);
  }

  void _finishGoogleLogin() {
    if (mounted) _goHome();
  }

  @override
  void dispose() {
    GoogleAuthService.signedIn.removeListener(_finishGoogleLogin);
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final err =
        await AuthService.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
    } else {
      _goHome();
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await GoogleAuthService.signIn();
    } catch (error) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = error.toString().replaceFirst('Unsupported operation: ', '');
        });
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const JobListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A0F1E), const Color(0xFF1A237E)]
                : [const Color(0xFF1565C0), const Color(0xFF0288D1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(Icons.work_rounded,
                            color: Colors.white, size: 38),
                      ),
                      const SizedBox(height: 16),
                      const Text('JobFinder',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Text('Find your dream job nearby',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 14)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(36)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome back 👋',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text('Sign in to continue',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 14)),
                            const SizedBox(height: 28),
                            if (_error != null)
                              FadeIn(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            Colors.red.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: Colors.red, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(_error!,
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) {
                                if (v!.trim().isEmpty)
                                  return 'Enter your email';
                                if (!v.contains('@'))
                                  return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon:
                                    const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? 'Enter your password' : null,
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Text('Sign In',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(children: [
                              Expanded(
                                  child: Divider(
                                      color:
                                          Colors.grey.withValues(alpha: .35))),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('OR',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Expanded(
                                  child: Divider(
                                      color:
                                          Colors.grey.withValues(alpha: .35))),
                            ]),
                            const SizedBox(height: 18),
                            GoogleLoginButton(
                                loading: _loading, onPressed: _googleLogin),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? ",
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 14)),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SignupScreen()),
                                  ),
                                  child: const Text('Sign Up',
                                      style: TextStyle(
                                          color: Color(0xFF1565C0),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
