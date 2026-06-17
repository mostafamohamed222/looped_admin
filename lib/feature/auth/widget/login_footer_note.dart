import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';

class LoginFooterNote extends StatelessWidget {
  const LoginFooterNote({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'login_footer_note'.tr(),
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: LoginColors.muted.withValues(alpha: 0.9),
        height: 1.5,
      ),
    );
  }
}
