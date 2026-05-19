import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/Inventory/domain/warehouse_option.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';

/// Opens a searchable bottom sheet to pick a warehouse.
class SearchableWarehouseField extends StatelessWidget {
  const SearchableWarehouseField({
    super.key,
    required this.warehouses,
    required this.selected,
    required this.onSelected,
    required this.enabled,
    this.isLoading = false,
    this.compact = false,
  });

  final List<WarehouseOption> warehouses;
  final WarehouseOption? selected;
  final ValueChanged<WarehouseOption> onSelected;
  final bool enabled;
  final bool isLoading;
  final bool compact;

  Future<void> _openSheet(BuildContext context) async {
    if (!enabled || isLoading) return;
    final picked = await showModalBottomSheet<WarehouseOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: InventoryColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _WarehousePickerSheet(warehouses: warehouses, compact: compact);
      },
    );
    if (picked != null) onSelected(picked);
  }

  String? _warehouseSubtitle(WarehouseOption w) {
    final parts = <String>[];
    if (w.code != null && w.code!.trim().isNotEmpty) {
      parts.add(w.code!.trim());
    } else if (w.warehouseName != null && w.warehouseName!.trim().isNotEmpty) {
      parts.add(w.warehouseName!.trim());
    }
    if (w.companyName != null && w.companyName!.trim().isNotEmpty) {
      parts.add(w.companyName!.trim());
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildStandard(context);
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);
    final wh = selected;
    final hasSelection = wh != null;
    final subtitle = hasSelection ? _warehouseSubtitle(wh) : null;

    return Material(
      color: hasSelection
          ? InventoryColors.accentBlueSoft.withValues(alpha: 0.45)
          : InventoryColors.pageBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasSelection
                  ? InventoryColors.accentBlue.withValues(alpha: 0.32)
                  : InventoryColors.borderSubtle.withValues(alpha: 0.85),
              width: hasSelection ? 1.15 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: hasSelection
                      ? InventoryColors.cardSurface
                      : InventoryColors.tonalIconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : Icon(
                        Icons.warehouse_outlined,
                        size: 18,
                        color: hasSelection
                            ? InventoryColors.accentBlue
                            : InventoryColors.subtitleGrey,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasSelection
                          ? wh.name
                          : 'inventory_warehouse_hint'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: hasSelection
                            ? InventoryColors.primaryNavy
                            : InventoryColors.subtitleGrey,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.5,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (hasSelection)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: InventoryColors.cardSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: InventoryColors.accentBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 14,
                        color: InventoryColors.accentBlue.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'inventory_warehouse_change'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: InventoryColors.accentBlue,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(
                  Icons.expand_more_rounded,
                  size: 22,
                  color: enabled
                      ? InventoryColors.subtitleGrey
                      : InventoryColors.subtitleGrey.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandard(BuildContext context) {
    final theme = Theme.of(context);
    final label = selected?.name ?? 'inventory_warehouse_hint'.tr();

    return Material(
      color: InventoryColors.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: enabled
              ? InventoryColors.borderSubtle
              : InventoryColors.borderSubtle.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openSheet(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: InventoryColors.tonalIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Icon(
                        Icons.warehouse_outlined,
                        color: InventoryColors.primaryNavy,
                        size: 26,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'inventory_section_warehouse'.tr(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: InventoryColors.subtitleGrey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: selected == null
                            ? InventoryColors.subtitleGrey
                            : InventoryColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled
                    ? InventoryColors.primaryNavy
                    : InventoryColors.subtitleGrey,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarehousePickerSheet extends StatefulWidget {
  const _WarehousePickerSheet({
    required this.warehouses,
    this.compact = false,
  });

  final List<WarehouseOption> warehouses;
  final bool compact;

  @override
  State<_WarehousePickerSheet> createState() => _WarehousePickerSheetState();
}

class _WarehousePickerSheetState extends State<_WarehousePickerSheet> {
  late final TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final filtered = widget.warehouses.where((w) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return w.name.toLowerCase().contains(q) ||
          (w.code?.toLowerCase().contains(q) ?? false) ||
          (w.warehouseName?.toLowerCase().contains(q) ?? false) ||
          (w.companyName?.toLowerCase().contains(q) ?? false);
    }).toList();

    final sheetHeight = widget.compact ? mq.size.height * 0.62 : mq.size.height * 0.72;

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, widget.compact ? 8 : 12),
              child: Text(
                'inventory_modal_warehouse_title'.tr(),
                style: (widget.compact
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.titleLarge)
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: InventoryColors.primaryNavy,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: widget.compact ? 40 : null,
                child: TextField(
                  controller: _controller,
                  onChanged: (v) => setState(() => _query = v),
                  style: widget.compact
                      ? theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )
                      : null,
                  decoration: InputDecoration(
                    isDense: widget.compact,
                    hintText: 'inventory_warehouse_search_hint'.tr(),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: widget.compact ? 18 : 24,
                    ),
                    prefixIconConstraints: widget.compact
                        ? const BoxConstraints(minWidth: 36, minHeight: 36)
                        : null,
                    filled: true,
                    fillColor: InventoryColors.pageBackground,
                    contentPadding: widget.compact
                        ? const EdgeInsets.symmetric(vertical: 8)
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        widget.compact ? 11 : 14,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'inventory_warehouse_empty'.tr(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: InventoryColors.subtitleGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          SizedBox(height: widget.compact ? 6 : 8),
                      itemBuilder: (context, index) {
                        final w = filtered[index];
                        return _WarehousePickerTile(
                          warehouse: w,
                          compact: widget.compact,
                          onTap: () => Navigator.pop(context, w),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarehousePickerTile extends StatelessWidget {
  const _WarehousePickerTile({
    required this.warehouse,
    required this.compact,
    required this.onTap,
  });

  final WarehouseOption warehouse;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleParts = <String>[];
    if (warehouse.warehouseName != null &&
        warehouse.warehouseName!.trim().isNotEmpty) {
      subtitleParts.add(warehouse.warehouseName!.trim());
    } else if (warehouse.code != null && warehouse.code!.trim().isNotEmpty) {
      subtitleParts.add(warehouse.code!.trim());
    }
    if (warehouse.companyName != null &&
        warehouse.companyName!.trim().isNotEmpty) {
      subtitleParts.add(warehouse.companyName!.trim());
    }
    final subtitle =
        subtitleParts.isEmpty ? null : subtitleParts.join(' · ');

    return Material(
      color: InventoryColors.pageBackground,
      borderRadius: BorderRadius.circular(compact ? 11 : 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 11 : 14),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 9 : 14,
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 32 : 40,
                height: compact ? 32 : 40,
                decoration: BoxDecoration(
                  color: InventoryColors.accentBlueSoft,
                  borderRadius: BorderRadius.circular(compact ? 8 : 10),
                ),
                child: Icon(
                  Icons.store_mall_directory_outlined,
                  size: compact ? 17 : 22,
                  color: InventoryColors.accentBlue,
                ),
              ),
              SizedBox(width: compact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouse.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: (compact
                              ? theme.textTheme.bodyMedium
                              : theme.textTheme.titleSmall)
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: InventoryColors.primaryNavy,
                        fontSize: compact ? 13 : null,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: compact ? 1 : 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: compact ? 10.5 : 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: compact ? 20 : 24,
                color: InventoryColors.subtitleGrey.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
