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
  });

  final List<WarehouseOption> warehouses;
  final WarehouseOption? selected;
  final ValueChanged<WarehouseOption> onSelected;
  final bool enabled;
  final bool isLoading;

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
        return _WarehousePickerSheet(warehouses: warehouses);
      },
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
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
  const _WarehousePickerSheet({required this.warehouses});

  final List<WarehouseOption> warehouses;

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

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SizedBox(
        height: mq.size.height * 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'inventory_modal_warehouse_title'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: InventoryColors.primaryNavy,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'inventory_warehouse_search_hint'.tr(),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: InventoryColors.pageBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
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
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: InventoryColors.subtitleGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final w = filtered[index];
                        return Material(
                          color: InventoryColors.pageBackground,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.pop(context, w),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.store_mall_directory_outlined,
                                    color: InventoryColors.accentBlue,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          w.name,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: InventoryColors.primaryNavy,
                                          ),
                                        ),
                                        if ((w.warehouseName != null &&
                                                w.warehouseName!.isNotEmpty) ||
                                            (w.code != null && w.code!.isNotEmpty)) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            (w.warehouseName != null &&
                                                    w.warehouseName!.isNotEmpty)
                                                ? w.warehouseName!
                                                : w.code!,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: InventoryColors.subtitleGrey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                        if (w.companyName != null &&
                                            w.companyName!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            w.companyName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: InventoryColors.subtitleGrey
                                                  .withValues(alpha: 0.9),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded),
                                ],
                              ),
                            ),
                          ),
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
