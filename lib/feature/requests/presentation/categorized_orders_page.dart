import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/app_routes.dart';
import 'package:looped_admin/feature/requests/widget/categorized_orders_colors.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_app_bar.dart';

class CategorizedOrdersPage extends StatelessWidget {
  const CategorizedOrdersPage({super.key});

  static const int _pendingCount = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: CategorizedOrdersColors.pageBackground,
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
                            'orders_page_title'.tr(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: CategorizedOrdersColors.primaryNavy,
                              height: 1.15,
                              letterSpacing: -0.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'orders_page_subtitle'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: CategorizedOrdersColors.subtitleGrey,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _StatusBanner(pendingCount: _pendingCount),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SupplyChainHubCard(
                        actions: [
                          _OrderActionData(
                            icon: Icons.swap_horiz_rounded,
                            iconBg: CategorizedOrdersColors.accentTealSoft,
                            iconColor: CategorizedOrdersColors.accentTeal,
                            label: 'orders_action_transfer'.tr(),
                            hint: 'orders_action_transfer_hint'.tr(),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.warehouseTransferMainScreen,
                              );
                            },
                          ),
                          _OrderActionData(
                            icon: Icons.fact_check_outlined,
                            iconBg: CategorizedOrdersColors.accentBlueSoft,
                            iconColor: CategorizedOrdersColors.accentBlue,
                            label: 'orders_action_inventory'.tr(),
                            hint: 'orders_action_inventory_hint'.tr(),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.inventoryMainScreen,
                              );
                            },
                          ),
                          _OrderActionData(
                            icon: Icons.shopping_cart_outlined,
                            iconBg: CategorizedOrdersColors.accentAmberSoft,
                            iconColor: CategorizedOrdersColors.accentAmber,
                            label: 'orders_action_purchase'.tr(),
                            hint: 'orders_action_purchase_hint'.tr(),
                            enabled: false,
                            onTap: () {},
                          ),
                        ],
                      ),
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

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: CategorizedOrdersColors.statusBannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CategorizedOrdersColors.statusBannerBorder),
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
                color: CategorizedOrdersColors.statusBannerIconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.pending_actions_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'orders_pending'.tr(
                      namedArgs: {'count': pendingCount.toString()},
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: CategorizedOrdersColors.primaryNavy,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'orders_last_update'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: CategorizedOrdersColors.subtitleGrey,
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

class _SupplyChainHubCard extends StatelessWidget {
  const _SupplyChainHubCard({required this.actions});

  final List<_OrderActionData> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: CategorizedOrdersColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CategorizedOrdersColors.borderSubtle),
        boxShadow: CategorizedOrdersColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              color: CategorizedOrdersColors.sectionHeaderBg,
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
                      Icons.inventory_2_outlined,
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
                          'orders_supply_title'.tr(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'orders_supply_subtitle'.tr(),
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
                  color: CategorizedOrdersColors.divider,
                  indent: 72,
                ),
              _OrderActionTile(data: actions[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderActionData {
  const _OrderActionData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.hint,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String hint;
  final VoidCallback onTap;
  final bool enabled;
}

class _OrderActionTile extends StatelessWidget {
  const _OrderActionTile({required this.data});

  final _OrderActionData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = data.enabled ? 1.0 : 0.55;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.enabled ? data.onTap : null,
        child: Opacity(
          opacity: opacity,
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
                          color: CategorizedOrdersColors.primaryNavy,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.hint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: CategorizedOrdersColors.subtitleGrey,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.navigate_next_rounded,
                  color: CategorizedOrdersColors.subtitleGrey
                      .withValues(alpha: 0.85),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
