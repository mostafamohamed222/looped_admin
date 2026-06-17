import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';
import 'package:looped_admin/feature/auth/widget/login_input_decorations.dart';

class LoginEmailField extends StatelessWidget {
  const LoginEmailField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'login_username_label'.tr(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: LoginColors.labelGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            color: LoginColors.navy,
            fontWeight: FontWeight.w500,
          ),
          decoration: LoginInputDecorations.base(
            theme: theme,
            hintText: 'login_email_hint'.tr(),
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: Colors.grey.shade500,
              size: 22,
            ),
          ),
          validator: (v) {
            final t = v?.trim() ?? '';
            return switch (t) {
              '' => 'login_validation_email_empty'.tr(),
              _ when !t.contains('@') => 'login_validation_email_invalid'.tr(),
              _ => null,
            };
          },
        ),
      ],
    );
  }
}
