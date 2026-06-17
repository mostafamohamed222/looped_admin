import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';
import 'package:looped_admin/feature/auth/widget/login_input_decorations.dart';

class LoginPasswordField extends StatelessWidget {
  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'login_password_label'.tr(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: LoginColors.labelGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('login_reset_snackbar'.tr())),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: LoginColors.linkBlue,
              ),
              child: Text(
                'login_forgot_password'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscurePassword,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmit(),
          style: const TextStyle(
            color: LoginColors.navy,
            fontWeight: FontWeight.w500,
          ),
          decoration: LoginInputDecorations.base(
            theme: theme,
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: Colors.grey.shade500,
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey.shade500,
                size: 22,
              ),
              onPressed: onToggleObscure,
            ),
          ),
          validator: (v) {
            final p = v ?? '';
            return switch (p) {
              _ when p.isEmpty => 'login_validation_password_empty'.tr(),
              _ when p.length < 6 => 'login_validation_password_short'.tr(),
              _ => null,
            };
          },
        ),
      ],
    );
  }
}
