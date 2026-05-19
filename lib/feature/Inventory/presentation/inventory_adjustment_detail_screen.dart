import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_adjustment_result.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_count_repository.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';

/// Review lines returned after creating an inventory adjustment; edit counted qty locally.
class InventoryAdjustmentDetailScreen extends StatefulWidget {
  const InventoryAdjustmentDetailScreen({
    super.key,
    required this.result,
    required this.repository,
  });

  final InventoryAdjustmentResult result;
  final InventoryCountRepository repository;

  @override
  State<InventoryAdjustmentDetailScreen> createState() =>
      _InventoryAdjustmentDetailScreenState();
}

class _InventoryAdjustmentDetailScreenState
    extends State<InventoryAdjustmentDetailScreen> {
  late final List<TextEditingController> _countedControllers;
  final TextEditingController _productLookupController = TextEditingController();
  String _productLookupQuery = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _countedControllers = widget.result.lines
        .map(
          (l) => TextEditingController(
            text: _formatQty(l.productQty),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final c in _countedControllers) {
      c.dispose();
    }
    _productLookupController.dispose();
    super.dispose();
  }

  List<int> _filteredLineIndices(List<InventoryAdjustmentLine> lines) {
    final q = _productLookupQuery.trim().toLowerCase();
    if (q.isEmpty) {
      return List<int>.generate(lines.length, (i) => i);
    }
    return [
      for (var i = 0; i < lines.length; i++)
        if (_lineMatchesQuery(lines[i], q)) i,
    ];
  }

  bool _lineMatchesQuery(InventoryAdjustmentLine line, String q) {
    if (line.productName.toLowerCase().contains(q)) return true;
    if (line.productId.toString().contains(q)) return true;
    return false;
  }

  double _parseCounted(int index) {
    final raw = _countedControllers[index].text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return widget.result.lines[index].productQty;
    return double.tryParse(raw) ?? widget.result.lines[index].productQty;
  }

  dynamic _productQtyForApi(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt();
    return qty;
  }

  Future<void> _saveChanges() async {
    if (_isSaving || widget.result.lines.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final payload = <Map<String, dynamic>>[
        for (var i = 0; i < widget.result.lines.length; i++)
          <String, dynamic>{
            'line_id': widget.result.lines[i].lineId,
            'product_qty': _productQtyForApi(_parseCounted(i)),
          },
      ];
      await widget.repository.updateInventoryLines(payload);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('inventory_save_lines_success'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(_saveErrorMessage(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _saveErrorMessage(Object e) {
    final raw = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (raw.startsWith('inventory_')) return raw.tr();
    return 'inventory_save_lines_error'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = widget.result;
    final hasLines = r.lines.isNotEmpty;
    final filteredIndices = _filteredLineIndices(r.lines);
    final hasLookup = _productLookupQuery.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: InventoryColors.pageBackground,
      appBar: AppBar(
        backgroundColor: InventoryColors.cardSurface,
        foregroundColor: InventoryColors.primaryNavy,
        elevation: 0,
        title: Text(
          'inventory_adjustment_detail_title'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: InventoryColors.primaryNavy,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SummaryCard(result: r, theme: theme),
                const SizedBox(height: 14),
                Text(
                  'inventory_adjustment_lines_heading'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: InventoryColors.primaryNavy,
                  ),
                ),
                if (hasLines) ...[
                  const SizedBox(height: 8),
                  _CompactProductLookupField(
                    controller: _productLookupController,
                    query: _productLookupQuery,
                    matchCount: filteredIndices.length,
                    totalCount: r.lines.length,
                    onChanged: (value) =>
                        setState(() => _productLookupQuery = value),
                    onClear: () {
                      _productLookupController.clear();
                      setState(() => _productLookupQuery = '');
                    },
                  ),
                ],
                const SizedBox(height: 10),
                if (!hasLines)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'inventory_adjustment_empty_lines'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: InventoryColors.subtitleGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (filteredIndices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'inventory_detail_product_lookup_empty'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: InventoryColors.subtitleGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  ...filteredIndices.map((i) {
                    final line = r.lines[i];
                    final counted = _parseCounted(i);
                    final diff = line.differenceForCounted(counted);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _LineCard(
                        line: line,
                        theme: theme,
                        countedController: _countedControllers[i],
                        onCountedChanged: () => setState(() {}),
                        difference: diff,
                        highlighted: hasLookup,
                      ),
                    );
                  }),
              ],
            ),
          ),
          Material(
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            color: InventoryColors.cardSurface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: InventoryColors.borderSubtle,
                  ),
                  onPressed: hasLines && !_isSaving ? _saveChanges : null,
                  child: _isSaving
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          'inventory_save_lines'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: hasLines
                                ? Colors.white
                                : InventoryColors.subtitleGrey,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact search row (same visual language as warehouse picker).
class _CompactProductLookupField extends StatelessWidget {
  const _CompactProductLookupField({
    required this.controller,
    required this.query,
    required this.matchCount,
    required this.totalCount,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final int matchCount;
  final int totalCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasQuery = query.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: InventoryColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasQuery
              ? InventoryColors.accentBlue.withValues(alpha: 0.32)
              : InventoryColors.borderSubtle.withValues(alpha: 0.85),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: hasQuery
                  ? InventoryColors.accentBlueSoft
                  : InventoryColors.tonalIconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.tag_outlined,
              size: 18,
              color: hasQuery
                  ? InventoryColors.accentBlue
                  : InventoryColors.subtitleGrey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: InventoryColors.primaryNavy,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'inventory_detail_product_lookup_hint'.tr(),
                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                    color: InventoryColors.subtitleGrey,
                    fontSize: 12.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          if (hasQuery) ...[
            Text(
              '$matchCount/$totalCount',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: InventoryColors.accentBlue,
                fontSize: 10,
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(Icons.close_rounded, size: 16),
              color: InventoryColors.subtitleGrey,
              onPressed: onClear,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result, required this.theme});

  final InventoryAdjustmentResult result;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: InventoryColors.cardSurface,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.reference,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: InventoryColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'inventory_adjustment_id_label'.tr(
                namedArgs: {'id': '${result.inventoryId}'},
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: InventoryColors.subtitleGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              result.locationName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: InventoryColors.subtitleGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.line,
    required this.theme,
    required this.countedController,
    required this.onCountedChanged,
    required this.difference,
    this.highlighted = false,
  });

  final InventoryAdjustmentLine line;
  final ThemeData theme;
  final TextEditingController countedController;
  final VoidCallback onCountedChanged;
  final double difference;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final diffColor = _differenceColor(difference);

    return Material(
      color: highlighted
          ? InventoryColors.accentBlueSoft.withValues(alpha: 0.35)
          : InventoryColors.cardSurface,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted
                ? InventoryColors.accentBlue.withValues(alpha: 0.28)
                : InventoryColors.borderSubtle.withValues(alpha: 0.9),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: InventoryColors.tonalIconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 17,
                    color: InventoryColors.accentBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: InventoryColors.primaryNavy,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _ProductIdBadge(productId: line.productId),
                          if (line.productUomName.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                line.productUomName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: InventoryColors.subtitleGrey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _InlineQtyInput(
                  controller: countedController,
                  onChanged: onCountedChanged,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _CompactStatPill(
                    label: 'inventory_label_theoretical_qty'.tr(),
                    value: _formatQty(line.theoreticalQty),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _CompactStatPill(
                    label: 'inventory_label_difference'.tr(),
                    value: _formatQty(difference),
                    valueColor: diffColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductIdBadge extends StatelessWidget {
  const _ProductIdBadge({required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: InventoryColors.tonalIconBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: InventoryColors.borderSubtle.withValues(alpha: 0.8),
        ),
      ),
      child: Text(
        '#$productId',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: InventoryColors.primaryNavy.withValues(alpha: 0.75),
              fontSize: 10,
            ),
      ),
    );
  }
}

class _CompactStatPill extends StatelessWidget {
  const _CompactStatPill({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: InventoryColors.pageBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: InventoryColors.borderSubtle.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: InventoryColors.subtitleGrey,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor ?? InventoryColors.primaryNavy,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Narrow counted-qty field beside the product name.
class _InlineQtyInput extends StatelessWidget {
  const _InlineQtyInput({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'inventory_label_product_qty'.tr(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: InventoryColors.subtitleGrey,
              fontSize: 8.5,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: InventoryColors.pageBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: InventoryColors.accentBlue.withValues(alpha: 0.32),
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,-]')),
              ],
              onChanged: (_) => onChanged(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: InventoryColors.primaryNavy,
                fontSize: 15,
                height: 1.1,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 6),
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _differenceColor(double v) {
  if (v > 0) return const Color(0xFF0D7A3E);
  if (v < 0) return InventoryColors.dangerText;
  return InventoryColors.subtitleGrey;
}

String _formatQty(double v) {
  if (v == v.roundToDouble()) return '${v.round()}';
  return v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}
