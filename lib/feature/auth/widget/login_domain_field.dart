import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';
import 'package:looped_admin/feature/auth/widget/login_input_decorations.dart';

class LoginDomainField extends StatelessWidget {
  const LoginDomainField({
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
          'login_domain_label'.tr(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: LoginColors.labelGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            color: LoginColors.navy,
            fontWeight: FontWeight.w500,
          ),
          decoration: LoginInputDecorations.base(
            theme: theme,
            hintText: 'login_domain_hint'.tr(),
            prefixIcon: Icon(
              Icons.public_rounded,
              color: Colors.grey.shade500,
              size: 22,
            ),
          ),
          validator: (value) {
            final raw = value?.trim() ?? '';
            if (raw.isEmpty) {
              return 'login_validation_domain_empty'.tr();
            }
            if (AuthCubit.normalizeTenantDomain(raw).isEmpty) {
              return 'login_validation_domain_invalid'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}
