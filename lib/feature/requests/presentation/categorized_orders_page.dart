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
    return ColoredBox(
      color: CategorizedOrdersColors.pageBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccountSettingsAppBar(
                onMenuTap: () {},
                onHelpTap: () {},
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'orders_page_title'.tr(),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: CategorizedOrdersColors.primaryNavy,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'orders_page_subtitle'.tr(),
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                color: CategorizedOrdersColors.subtitleGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Material(
                          color: CategorizedOrdersColors.cardSurface,
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: CategorizedOrdersColors.primaryNavy,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.inventory_2_outlined,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'orders_supply_title'.tr(),
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: CategorizedOrdersColors
                                                  .primaryNavy,
                                              height: 1.25,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'orders_supply_subtitle'.tr(),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: CategorizedOrdersColors
                                                  .subtitleGrey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _ActionTile(
                                  icon: Icons.swap_horiz_rounded,
                                  label: 'orders_action_transfer'.tr(),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.warehouseTransferMainScreen,
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                _ActionTile(
                                  icon: Icons.fact_check_outlined,
                                  label: 'orders_action_inventory'.tr(),
                                  onTap: () {
                                    Navigator.pushNamed(context, Routes.inventoryMainScreen);
                                  },
                                ),
                                const SizedBox(height: 12),
                                _ActionTile(
                                  icon: Icons.shopping_cart_outlined,
                                  label: 'orders_action_purchase'.tr(),
                                  onTap: () {},
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'orders_last_update'.tr(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: CategorizedOrdersColors
                                              .subtitleGrey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Material(
                                          color: CategorizedOrdersColors.fabNavy,
                                          shape: const CircleBorder(),
                                          elevation: 2,
                                          shadowColor: Colors.black
                                              .withValues(alpha: 0.12),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () {},
                                            child: const SizedBox(
                                              width: 44,
                                              height: 44,
                                              child: Icon(
                                                Icons.help_outline_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: CategorizedOrdersColors
                                                .accentTeal,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            'orders_pending'.tr(
                                              namedArgs: {
                                                'count':
                                                    _pendingCount.toString(),
                                              },
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CategorizedOrdersColors.innerCardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: CategorizedOrdersColors.actionIconTint,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CategorizedOrdersColors.primaryNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
