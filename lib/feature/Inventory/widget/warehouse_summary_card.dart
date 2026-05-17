import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/Inventory/domain/warehouse_option.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';

class WarehouseSummaryCard extends StatelessWidget {
  const WarehouseSummaryCard({
    super.key,
    required this.warehouse,
  });

  final WarehouseOption warehouse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Material(
        key: ValueKey(warehouse.id),
        color: InventoryColors.cardSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: InventoryColors.borderSubtle),
        ),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: InventoryColors.accentBlueSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.warehouse_rounded,
                    color: InventoryColors.accentBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'inventory_summary_title'.tr(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        warehouse.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: InventoryColors.primaryNavy,
                          height: 1.2,
                        ),
                      ),
                      if (warehouse.warehouseName != null &&
                          warehouse.warehouseName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${'inventory_summary_warehouse_label'.tr()}: ${warehouse.warehouseName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: InventoryColors.subtitleGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (warehouse.companyName != null &&
                          warehouse.companyName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${'inventory_summary_company_label'.tr()}: ${warehouse.companyName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: InventoryColors.subtitleGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if ((warehouse.warehouseName == null ||
                              warehouse.warehouseName!.isEmpty) &&
                          warehouse.code != null &&
                          warehouse.code!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${'inventory_summary_code_label'.tr()}: ${warehouse.code}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: InventoryColors.subtitleGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: InventoryColors.accentBlue,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
    );
  }
}
