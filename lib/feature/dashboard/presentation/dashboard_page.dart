import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/feature/dashboard/widget/dashboard_ai_assistant_card.dart';
import 'package:looped_admin/feature/dashboard/widget/dashboard_colors.dart';
import 'package:looped_admin/feature/nav_bar/cubit/app_shell_nav_cubit.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_app_bar.dart';

/// لوحة التحكم — ترحيب، شريط الحالة، وحدات سريعة، والمساعد الذكي.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: DashboardColors.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccountSettingsAppBar(
              onMenuTap: () {},
              onHelpTap: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'dashboard_greeting_title'.tr(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: DashboardColors.primaryNavy,
                              height: 1.15,
                              letterSpacing: -0.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'dashboard_greeting_subtitle'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: DashboardColors.subtitleGrey,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: _SystemsStatusBanner(),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ModulesHubCard(
                        actions: [
                          _ModuleActionData(
                            icon: Icons.account_tree_rounded,
                            iconBg: DashboardColors.accentBlueSoft,
                            iconColor: DashboardColors.accentBlue,
                            label: 'dashboard_card_orders_title'.tr(),
                            hint: 'dashboard_card_orders_desc'.tr(),
                            onTap: () => context
                                .read<AppShellNavCubit>()
                                .selectTab(AppShellNavCubit.requestsTab),
                          ),
                          _ModuleActionData(
                            icon: Icons.archive_rounded,
                            iconBg: DashboardColors.accentTealSoft,
                            iconColor: DashboardColors.accentTeal,
                            label: 'dashboard_card_reports_title'.tr(),
                            hint: 'dashboard_card_reports_desc'.tr(),
                            onTap: () {},
                          ),
                          _ModuleActionData(
                            icon: Icons.show_chart_rounded,
                            iconBg: DashboardColors.accentVioletSoft,
                            iconColor: DashboardColors.accentViolet,
                            label: 'dashboard_card_stats_title'.tr(),
                            hint: 'dashboard_card_stats_desc'.tr(),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
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

class _SystemsStatusBanner extends StatelessWidget {
  const _SystemsStatusBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: DashboardColors.statusBannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardColors.statusBannerBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: DashboardColors.statusBannerIconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dashboard_systems_ok'.tr(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: DashboardColors.primaryNavy,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'dashboard_systems_ok_hint'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DashboardColors.subtitleGrey,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
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

class _ModulesHubCard extends StatelessWidget {
  const _ModulesHubCard({required this.actions});

  final List<_ModuleActionData> actions;

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
              color: DashboardColors.sectionHeaderBg,
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
                      Icons.dashboard_customize_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'dashboard_modules_title'.tr(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'dashboard_modules_subtitle'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: DashboardColors.divider,
                  indent: 72,
                ),
              _ModuleActionTile(data: actions[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModuleActionData {
  const _ModuleActionData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String hint;
  final VoidCallback onTap;
}

class _ModuleActionTile extends StatelessWidget {
  const _ModuleActionTile({required this.data});

  final _ModuleActionData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  data.icon,
                  size: 22,
                  color: data.iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: DashboardColors.primaryNavy,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.hint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: DashboardColors.subtitleGrey,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.navigate_next_rounded,
                color: DashboardColors.subtitleGrey.withValues(alpha: 0.85),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
