import 'package:flutter/material.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_colors.dart';

class AccountSettingsTitleBlock extends StatelessWidget {
  const AccountSettingsTitleBlock({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: AccountSettingsColors.pageBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AccountSettingsColors.navy,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AccountSettingsColors.subtitleGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
