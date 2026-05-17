import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_adjustment_summary.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/WarehouseTransfer/widget/stock_request_card.dart';

class InventoryAdjustmentCard extends StatelessWidget {
  const InventoryAdjustmentCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final InventoryAdjustmentSummary item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateStyle = InventoryAdjustmentStateStyle.forState(item.state);

    final card = Container(
      decoration: BoxDecoration(
        color: InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InventoryColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: InventoryColors.primaryNavy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  stateStyle.accent,
                  stateStyle.accent.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            stateStyle.accent.withValues(alpha: 0.18),
                            stateStyle.background,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: stateStyle.accent.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 19,
                        color: stateStyle.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: InventoryColors.primaryNavy,
                              height: 1.2,
                              fontSize: 15,
                            ),
                          ),
                          if (item.companyName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: InventoryColors.subtitleGrey,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    TransferStatusChip(
                      label: item.state.isEmpty ? '—' : item.state,
                      style: stateStyle,
                      compact: true,
                    ),
                  ],
                ),
                if (item.date.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _AdjustmentInfoRow(
                    icon: Icons.event_outlined,
                    iconColor: InventoryColors.accentBlue,
                    iconBg: InventoryColors.accentBlueSoft,
                    label: StockRequestCard.formatExpectedDate(item.date),
                  ),
                ],
                if (item.locationName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _AdjustmentInfoRow(
                    icon: Icons.warehouse_outlined,
                    iconColor:
                        InventoryColors.primaryNavy.withValues(alpha: 0.75),
                    iconBg: InventoryColors.tonalIconBg,
                    label: item.locationName,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _AdjustmentMetaChip(
                      icon: Icons.format_list_numbered_rounded,
                      label: 'inventory_adjustments_lines_count'.tr(
                        namedArgs: {'count': '${item.linesCount}'},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: card,
      ),
    );
  }
}

/// State colors for inventory adjustment list cards (`confirm` is distinct from `done`).
abstract final class InventoryAdjustmentStateStyle {
  static TransferStateStyle forState(String state) {
    final key = state.toLowerCase().trim();
    if (key.contains('confirm')) {
      return const TransferStateStyle(
        background: InventoryColors.accentBlueSoft,
        accent: InventoryColors.accentBlue,
        foreground: Color(0xFF1D4ED8),
      );
    }
    if (key.contains('open') || key.contains('progress')) {
      return const TransferStateStyle(
        background: InventoryColors.accentBlueSoft,
        accent: InventoryColors.accentBlue,
        foreground: Color(0xFF1D4ED8),
      );
    }
    if (key.contains('done') || key.contains('close')) {
      return const TransferStateStyle(
        background: InventoryColors.successTint,
        accent: InventoryColors.successText,
        foreground: InventoryColors.successText,
      );
    }
    if (key.contains('cancel') || key.contains('reject')) {
      return const TransferStateStyle(
        background: InventoryColors.dangerTint,
        accent: InventoryColors.dangerText,
        foreground: InventoryColors.dangerText,
      );
    }
    if (key.contains('draft') || key.contains('wait')) {
      return const TransferStateStyle(
        background: Color(0xFFF1F5F9),
        accent: InventoryColors.subtitleGrey,
        foreground: InventoryColors.subtitleGrey,
      );
    }
    return const TransferStateStyle(
      background: Color(0xFFF8FAFC),
      accent: InventoryColors.primaryNavy,
      foreground: InventoryColors.primaryNavy,
    );
  }
}

class _AdjustmentInfoRow extends StatelessWidget {
  const _AdjustmentInfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: InventoryColors.primaryNavy.withValues(alpha: 0.88),
                fontWeight: FontWeight.w600,
                height: 1.3,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdjustmentMetaChip extends StatelessWidget {
  const _AdjustmentMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: InventoryColors.pageBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: InventoryColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: InventoryColors.subtitleGrey),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: InventoryColors.primaryNavy.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
