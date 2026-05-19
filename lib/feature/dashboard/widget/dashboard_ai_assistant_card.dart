import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/dashboard/widget/dashboard_colors.dart';

/// بطاقة المساعد الذكي — متوافقة مع أسلوب بطاقات التطبيق.
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
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: DashboardColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashboardColors.borderSubtle),
        boxShadow: DashboardColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    DashboardColors.primaryNavy,
                    Color(0xFF1E3A5F),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'dashboard_ai_title'.tr(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: DashboardColors.aiAccentSoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: DashboardColors.aiAccentBorder,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'dashboard_ai_message'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: DashboardColors.primaryNavy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SuggestionChip(
                    label: 'dashboard_ai_btn_forecast'.tr(),
                    onTap: onForecastTap ?? () {},
                  ),
                  const SizedBox(height: 10),
                  _SuggestionChip(
                    label: 'dashboard_ai_btn_risks'.tr(),
                    onTap: onRisksTap ?? () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: DashboardColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DashboardColors.borderSubtle),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DashboardColors.primaryNavy,
                      height: 1.35,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: DashboardColors.linkText.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
