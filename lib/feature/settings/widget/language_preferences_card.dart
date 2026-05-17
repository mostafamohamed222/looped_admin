import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_colors.dart';

class LanguagePreferencesCard extends StatelessWidget {
  const LanguagePreferencesCard({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AccountSettingsColors.langSectionBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.public_rounded,
                size: 28,
                color: AccountSettingsColors.langTeal,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'lang_section_title'.tr(),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AccountSettingsColors.navy,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _LanguageOptionTile(
            selected: selectedIndex == 0,
            title: 'lang_ar_title'.tr(),
            subtitle: 'lang_ar_subtitle'.tr(),
            onTap: () => onSelect(0),
          ),
          const SizedBox(height: 10),
          _LanguageOptionTile(
            selected: selectedIndex == 1,
            title: 'lang_en_title'.tr(),
            subtitle: 'lang_en_subtitle'.tr(),
            onTap: () => onSelect(1),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorManager.whiteColor,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AccountSettingsColors.langTealDark
                  : const Color(0xFFE2E8F0),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
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
                        color: AccountSettingsColors.subtitleGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              selected
                  ? const _LangSelectedIndicator()
                  : const _LangUnselectedIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangSelectedIndicator extends StatelessWidget {
  const _LangSelectedIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AccountSettingsColors.langTeal,
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 16,
        color: ColorManager.whiteColor,
      ),
    );
  }
}

class _LangUnselectedIndicator extends StatelessWidget {
  const _LangUnselectedIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AccountSettingsColors.langRadioEmpty,
          width: 2,
        ),
      ),
    );
  }
}
