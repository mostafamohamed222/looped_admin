import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_colors.dart';

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({
    super.key,
    required this.emailEnabled,
    required this.browserEnabled,
    required this.aiReportsEnabled,
    required this.onEmailChanged,
    required this.onBrowserChanged,
    required this.onAiReportsChanged,
    required this.onResetAll,
  });

  final bool emailEnabled;
  final bool browserEnabled;
  final bool aiReportsEnabled;
  final ValueChanged<bool> onEmailChanged;
  final ValueChanged<bool> onBrowserChanged;
  final ValueChanged<bool> onAiReportsChanged;
  final VoidCallback onResetAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: ColorManager.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AccountSettingsColors.notifyCardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 26,
                color: AccountSettingsColors.langTealDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'notify_section_title'.tr(),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ColorManager.blackColor,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onResetAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AccountSettingsColors.langTealDark,
                  side: const BorderSide(
                    color: AccountSettingsColors.langTealDark,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'notify_reset_all'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _NotificationToggleRow(
            value: emailEnabled,
            onChanged: onEmailChanged,
            title: 'notify_email_title'.tr(),
            subtitle: 'notify_email_subtitle'.tr(),
          ),
          const SizedBox(height: 18),
          _NotificationToggleRow(
            value: browserEnabled,
            onChanged: onBrowserChanged,
            title: 'notify_browser_title'.tr(),
            subtitle: 'notify_browser_subtitle'.tr(),
          ),
          const SizedBox(height: 18),
          _NotificationToggleRow(
            value: aiReportsEnabled,
            onChanged: onAiReportsChanged,
            title: 'notify_ai_title'.tr(),
            subtitle: 'notify_ai_subtitle'.tr(),
          ),
        ],
      ),
    );
  }
}

class _NotificationToggleRow extends StatelessWidget {
  const _NotificationToggleRow({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.blackColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: AccountSettingsColors.subtitleGrey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _TealSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _TealSwitch extends StatelessWidget {
  const _TealSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      activeThumbColor: ColorManager.whiteColor,
      activeTrackColor: AccountSettingsColors.langTealDark,
      inactiveTrackColor: AccountSettingsColors.notifySwitchTrackOff,
      inactiveThumbColor: AccountSettingsColors.notifySwitchThumbOff,
    );
  }
}
