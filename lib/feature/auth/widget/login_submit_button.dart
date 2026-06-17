import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';

class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: LoginColors.navyButton,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              LoginColors.navyButton.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'login_button'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.login_rounded, size: 22),
                ],
              ),
      ),
    );
  }
}
