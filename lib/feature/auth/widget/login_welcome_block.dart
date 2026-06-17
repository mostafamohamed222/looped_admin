import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';

class LoginWelcomeBlock extends StatelessWidget {
  const LoginWelcomeBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'login_welcome'.tr(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: LoginColors.navy,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'login_subtitle'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: LoginColors.muted,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
