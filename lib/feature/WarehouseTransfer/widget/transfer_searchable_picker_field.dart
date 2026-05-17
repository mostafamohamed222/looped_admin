import 'package:flutter/material.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';

/// Searchable bottom-sheet picker styled like inventory warehouse field.
class TransferSearchablePickerField<T> extends StatelessWidget {
  const TransferSearchablePickerField({
    super.key,
    required this.sectionLabel,
    required this.hint,
    required this.modalTitle,
    required this.searchHint,
    required this.emptyMessage,
    required this.items,
    required this.selected,
    required this.onSelected,
    required this.enabled,
    required this.displayName,
    this.isLoading = false,
    this.compact = false,
    this.icon = Icons.warehouse_outlined,
    this.filterItem,
    this.subtitleForItem,
  });

  final String sectionLabel;
  final String hint;
  final String modalTitle;
  final String searchHint;
  final String emptyMessage;
  final List<T> items;
  final T? selected;
  final ValueChanged<T> onSelected;
  final bool enabled;
  final String Function(T) displayName;
  final bool isLoading;
  final bool compact;
  final IconData icon;
  final bool Function(T item, String query)? filterItem;
  final String? Function(T item)? subtitleForItem;

  Future<void> _openSheet(BuildContext context) async {
    if (!enabled || isLoading) return;
    final picked = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: InventoryColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _TransferPickerSheet<T>(
          items: items,
          modalTitle: modalTitle,
          searchHint: searchHint,
          emptyMessage: emptyMessage,
          displayName: displayName,
          filterItem: filterItem,
          subtitleForItem: subtitleForItem,
        );
      },
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = selected != null ? displayName(selected as T) : hint;

    final iconSize = compact ? 40.0 : 48.0;
    final radius = compact ? 12.0 : 16.0;
    final vPad = compact ? 12.0 : 18.0;
    final hPad = compact ? 12.0 : 16.0;

    return Material(
      color: enabled
          ? InventoryColors.cardSurface
          : InventoryColors.pageBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: selected != null && enabled
              ? InventoryColors.accentBlue.withValues(alpha: 0.35)
              : (enabled
                  ? InventoryColors.borderSubtle
                  : InventoryColors.borderSubtle.withValues(alpha: 0.45)),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: enabled && !isLoading ? () => _openSheet(context) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: selected != null
                      ? InventoryColors.accentBlueSoft
                      : InventoryColors.tonalIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? Padding(
                        padding: EdgeInsets.all(iconSize * 0.25),
                        child: const CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : Icon(
                        icon,
                        color: selected != null
                            ? InventoryColors.accentBlue
                            : InventoryColors.primaryNavy,
                        size: compact ? 22 : 26,
                      ),
              ),
              SizedBox(width: compact ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sectionLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: InventoryColors.subtitleGrey,
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 11 : null,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: compact ? 3 : 6),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: (compact
                              ? theme.textTheme.titleSmall
                              : theme.textTheme.titleMedium)
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: selected == null
                            ? InventoryColors.subtitleGrey
                            : InventoryColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.unfold_more_rounded,
                color: enabled
                    ? InventoryColors.primaryNavy.withValues(alpha: 0.7)
                    : InventoryColors.subtitleGrey,
                size: compact ? 22 : 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferPickerSheet<T> extends StatefulWidget {
  const _TransferPickerSheet({
    required this.items,
    required this.modalTitle,
    required this.searchHint,
    required this.emptyMessage,
    required this.displayName,
    this.filterItem,
    this.subtitleForItem,
  });

  final List<T> items;
  final String modalTitle;
  final String searchHint;
  final String emptyMessage;
  final String Function(T) displayName;
  final bool Function(T item, String query)? filterItem;
  final String? Function(T item)? subtitleForItem;

  @override
  State<_TransferPickerSheet<T>> createState() =>
      _TransferPickerSheetState<T>();
}

class _TransferPickerSheetState<T> extends State<_TransferPickerSheet<T>> {
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

  List<T> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items.where((item) {
      if (widget.filterItem != null) {
        return widget.filterItem!(item, q);
      }
      return widget.displayName(item).toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final filtered = _filtered;

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
                widget.modalTitle,
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
                  hintText: widget.searchHint,
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
                          widget.emptyMessage,
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
                        final item = filtered[index];
                        final subtitle = widget.subtitleForItem?.call(item);
                        return Material(
                          color: InventoryColors.pageBackground,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.pop(context, item),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    color: InventoryColors.accentBlue,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.displayName(item),
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: InventoryColors.primaryNavy,
                                          ),
                                        ),
                                        if (subtitle != null &&
                                            subtitle.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            subtitle,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: InventoryColors
                                                  .subtitleGrey,
                                              fontWeight: FontWeight.w600,
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
