import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/color_manager.dart';
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('Looped', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ColorManager.blackColor, letterSpacing: 0.2),),
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
