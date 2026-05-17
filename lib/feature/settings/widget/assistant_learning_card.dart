import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_colors.dart';

class AssistantLearningCard extends StatelessWidget {
  const AssistantLearningCard({
    super.key,
    required this.onCustomizeData,
    required this.onChatHistory,
    required this.onHelpFab,
  });

  final VoidCallback onCustomizeData;
  final VoidCallback onChatHistory;
  final VoidCallback onHelpFab;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          decoration: BoxDecoration(
            color: AccountSettingsColors.assistantCardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AccountSettingsColors.assistantBadgeBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'assistant_badge'.tr(),
                    style: const TextStyle(
                      color: ColorManager.whiteColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'assistant_title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ColorManager.whiteColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'assistant_body'.tr(),
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: AccountSettingsColors.assistantBodyText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onCustomizeData,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            AccountSettingsColors.assistantPrimaryCyan,
                        foregroundColor: AccountSettingsColors.assistantCardBg,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'assistant_btn_customize'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onChatHistory,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorManager.whiteColor,
                        side: const BorderSide(
                          color: Color(0x66FFFFFF),
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'assistant_btn_history'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 10,
          bottom: -6,
          child: Material(
            color: AccountSettingsColors.assistantCardBg,
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onHelpFab,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ColorManager.whiteColor.withValues(alpha: 0.45),
                  ),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: ColorManager.whiteColor,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
