import 'package:flutter/material.dart';
import 'google_login_button.dart';

class PlatformGoogleLoginButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const PlatformGoogleLoginButton(
      {super.key, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) =>
      GoogleLoginButtonStyle(loading: loading, onPressed: onPressed);
}
