import 'package:flutter/material.dart';
import 'google_login_button_platform.dart'
    if (dart.library.js_interop) 'google_login_button_web.dart';

class GoogleLoginButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;

  const GoogleLoginButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformGoogleLoginButton(loading: loading, onPressed: onPressed);
  }
}

class GoogleLoginButtonStyle extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const GoogleLoginButtonStyle(
      {super.key, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(color: Colors.grey.withValues(alpha: .35)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleMark(),
                  SizedBox(width: 12),
                  Text('Continue with Google',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Text('G',
        style: TextStyle(
            color: const Color(0xFF4285F4),
            fontWeight: FontWeight.w900,
            fontSize: 21,
            shadows: [
              Shadow(
                  color: const Color(0xFFEA4335).withValues(alpha: .35),
                  offset: const Offset(-1, 0)),
            ]));
  }
}
