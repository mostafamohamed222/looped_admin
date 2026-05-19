import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_picking_summary.dart';
import 'package:looped_admin/feature/WarehouseTransfer/widget/stock_request_card.dart';

/// State colors for stock pickings / transfers list only.
abstract final class PickingTransferStateStyle {
  static TransferStateStyle forPicking({
    required String state,
    String stateLabel = '',
  }) {
    final stateKey = state.toLowerCase().trim();
    final labelKey = stateLabel.toLowerCase().trim();
    if (labelKey.contains('ready') || stateKey.contains('ready')) {
      return const TransferStateStyle(
        background: Color(0xFFD1FAE5),
        accent: Color(0xFF15803D),
        foreground: Color(0xFF14532D),
      );
    }
    return TransferStateStyle.forState(state);
  }
}

class StockPickingCard extends StatelessWidget {
  const StockPickingCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final StockPickingSummary item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateStyle = PickingTransferStateStyle.forPicking(
      state: item.state,
      stateLabel: item.stateLabel,
    );

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
                          if (item.pickingTypeName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.pickingTypeName,
                              maxLines: 2,
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
                      label: item.displayState.isEmpty ? '—' : item.displayState,
                      style: stateStyle,
                      compact: true,
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: InventoryColors.subtitleGrey,
                      ),
                    ],
                  ],
                ),
                if (item.scheduledDate.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _PickingInfoRow(
                    icon: Icons.event_outlined,
                    label: 'transfer_picking_label_scheduled'.tr(),
                    value: item.scheduledDate,
                  ),
                ],
                if (item.sourceLocationName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _PickingInfoRow(
                    icon: Icons.call_made_outlined,
                    label: 'transfer_picking_label_source'.tr(),
                    value: item.sourceLocationName,
                  ),
                ],
                if (item.destinationLocationName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _PickingInfoRow(
                    icon: Icons.call_received_outlined,
                    label: 'transfer_picking_label_destination'.tr(),
                    value: item.destinationLocationName,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _PickingMetaChip(
                      icon: Icons.format_list_numbered_rounded,
                      label: 'transfer_lines_count'.tr(
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

class _PickingInfoRow extends StatelessWidget {
  const _PickingInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: InventoryColors.subtitleGrey),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.labelSmall?.copyWith(
                color: InventoryColors.subtitleGrey,
                fontWeight: FontWeight.w600,
                height: 1.35,
                fontSize: 11,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: InventoryColors.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PickingMetaChip extends StatelessWidget {
  const _PickingMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    const bg = InventoryColors.primaryNavy;
    final chipBg = bg.withValues(alpha: 0.06);
    const fg = InventoryColors.primaryNavy;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: fg.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: fg,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
