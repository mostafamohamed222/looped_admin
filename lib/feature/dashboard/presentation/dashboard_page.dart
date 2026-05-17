import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/dashboard/widget/dashboard_ai_assistant_card.dart';
import 'package:looped_admin/feature/dashboard/widget/dashboard_app_bar.dart';
import 'package:looped_admin/feature/dashboard/widget/dashboard_colors.dart';

/// لوحة التحكم — ترحيب، شريط الحالة، بطاقات الدخول، وبطاقة المساعد الذكي.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DashboardColors.pageBackground,
      child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardAppBar(
                onMenuTap: () {},
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'dashboard_greeting_title'.tr(),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: DashboardColors.titleText,
                                height: 1.28,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'dashboard_greeting_subtitle'.tr(),
                              style: TextStyle(
                                fontSize: 15.5,
                                height: 1.55,
                                color: DashboardColors.subtitleGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: DashboardColors.statusBannerBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: DashboardColors.statusBannerBorder,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: DashboardColors.statusBannerIconBg,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'dashboard_systems_ok'.tr(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: DashboardColors.titleText,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          children: [
                            _FeatureCard(
                              iconBg: DashboardColors.ordersIconBg,
                              icon: Icons.account_tree_rounded,
                              iconColor: Colors.white,
                              title: 'dashboard_card_orders_title'.tr(),
                              description:
                                  'dashboard_card_orders_desc'.tr(),
                              onMoreTap: () {},
                            ),
                            const SizedBox(height: 16),
                            _FeatureCard(
                              iconBg: DashboardColors.reportsIconBg,
                              icon: Icons.archive_rounded,
                              iconColor: Colors.white,
                              title: 'dashboard_card_reports_title'.tr(),
                              description:
                                  'dashboard_card_reports_desc'.tr(),
                              onMoreTap: () {},
                            ),
                            const SizedBox(height: 16),
                            _FeatureCard(
                              iconBg: DashboardColors.statisticsIconBg,
                              icon: Icons.show_chart_rounded,
                              iconColor: DashboardColors.statisticsChartIcon,
                              title: 'dashboard_card_stats_title'.tr(),
                              description:
                                  'dashboard_card_stats_desc'.tr(),
                              onMoreTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: DashboardAiAssistantCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onMoreTap,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onMoreTap;

  static const double _iconSize = 52;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DashboardColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: DashboardColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Container(
                width: _iconSize,
                height: _iconSize,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DashboardColors.titleText,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: DashboardColors.subtitleGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onMoreTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'dashboard_show_more'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DashboardColors.linkText,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_left_rounded,
                          size: 22,
                          color: DashboardColors.linkText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
