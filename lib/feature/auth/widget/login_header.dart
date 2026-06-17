import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_locale_button.dart';
import 'package:looped_admin/feature/auth/widget/looped_wordmark.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.localeSwitchLabel,
    required this.onLocalePressed,
  });

  final String localeSwitchLabel;
  final VoidCallback onLocalePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: LoopedWordmark(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: LoginLocaleButton(
            label: localeSwitchLabel,
            onPressed: onLocalePressed,
          ),
        ),
      ],
    );
  }
}
