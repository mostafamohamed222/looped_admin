import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';

class LoginLocaleButton extends StatelessWidget {
  const LoginLocaleButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.language_rounded,
        size: 18,
        color: LoginColors.labelGrey.withValues(alpha: 0.9),
      ),
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: LoginColors.labelGrey,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: LoginColors.labelGrey,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: const StadiumBorder(),
      ),
    );
  }
}
