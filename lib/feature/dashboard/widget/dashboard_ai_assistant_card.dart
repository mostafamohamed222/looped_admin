import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/dashboard/widget/dashboard_colors.dart';

/// بطاقة المساعد الذكي — الواجهة الثانية في لوحة التحكم.
class DashboardAiAssistantCard extends StatelessWidget {
  const DashboardAiAssistantCard({
    super.key,
    this.onForecastTap,
    this.onRisksTap,
  });

  final VoidCallback? onForecastTap;
  final VoidCallback? onRisksTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: DashboardColors.aiCardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: DashboardColors.aiCardBorder,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 38),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: DashboardColors.aiIconBackground,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'dashboard_ai_title'.tr(),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: DashboardColors.aiTitleColor,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'dashboard_ai_message'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                      color: DashboardColors.aiBodyText,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SuggestionButton(
                    label: 'dashboard_ai_btn_forecast'.tr(),
                    onTap: onForecastTap ?? () {},
                  ),
                  const SizedBox(height: 12),
                  _SuggestionButton(
                    label: 'dashboard_ai_btn_risks'.tr(),
                    onTap: onRisksTap ?? () {},
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: IgnorePointer(
              child: Text(
                'dashboard_ai_watermark'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: DashboardColors.aiWatermark.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionButton extends StatelessWidget {
  const _SuggestionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DashboardColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardColors.aiButtonBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: DashboardColors.aiTitleColor,
                height: 1.35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
