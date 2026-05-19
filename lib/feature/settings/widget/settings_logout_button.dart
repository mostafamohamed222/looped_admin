import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/core/res/app_routes.dart';
import 'package:looped_admin/feature/auth/presentation/cubit/auth_cubit.dart';

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key});

  static const Color _danger = Color(0xFFDC2626);
  static const Color _dangerSoft = Color(0xFFFEE2E2);

  Future<void> _confirmAndLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('settings_logout_confirm_title'.tr()),
          content: Text('settings_logout_confirm_message'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('settings_logout_cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: _danger),
              child: Text('settings_logout'.tr()),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    await context.read<AuthCubit>().logout();
    if (!context.mounted) return;
    navigatorManager.navigateAndFinish(Routes.loginCompanyScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmAndLogout(context),
            icon: const Icon(Icons.logout_rounded, size: 22),
            label: Text(
              'settings_logout'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _danger,
              backgroundColor: _dangerSoft,
              side: const BorderSide(color: Color(0xFFFECACA)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
