import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as google_web;

class PlatformGoogleLoginButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const PlatformGoogleLoginButton(
      {super.key, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const SizedBox(
          height: 52,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    return SizedBox(
      height: 52,
      child: Center(child: google_web.renderButton()),
    );
  }
}
