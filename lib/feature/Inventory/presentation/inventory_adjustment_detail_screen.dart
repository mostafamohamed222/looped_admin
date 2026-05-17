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
    super.dispose();
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
                const SizedBox(height: 16),
                Text(
                  'inventory_adjustment_lines_heading'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: InventoryColors.primaryNavy,
                  ),
                ),
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
                else
                  ...List.generate(r.lines.length, (i) {
                    final line = r.lines[i];
                    final counted = _parseCounted(i);
                    final diff = line.differenceForCounted(counted);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _LineCard(
                        line: line,
                        theme: theme,
                        countedController: _countedControllers[i],
                        onCountedChanged: () => setState(() {}),
                        difference: diff,
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
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            Text(
              'inventory_adjustment_id_label'.tr(
                namedArgs: {'id': '${result.inventoryId}'},
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: InventoryColors.subtitleGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
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
  });

  final InventoryAdjustmentLine line;
  final ThemeData theme;
  final TextEditingController countedController;
  final VoidCallback onCountedChanged;
  final double difference;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: InventoryColors.cardSurface,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              line.productName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: InventoryColors.primaryNavy,
                height: 1.25,
              ),
            ),
            if (line.productUomName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                line.productUomName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: InventoryColors.subtitleGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 14),
            _QtyRow(
              label: 'inventory_label_theoretical_qty'.tr(),
              valueText: _formatQty(line.theoreticalQty),
              theme: theme,
              valueColor: InventoryColors.primaryNavy,
            ),
            const SizedBox(height: 12),
            Text(
              'inventory_label_product_qty'.tr(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: InventoryColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: countedController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,-]')),
              ],
              onChanged: (_) => onCountedChanged(),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: InventoryColors.pageBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: InventoryColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 12),
            _QtyRow(
              label: 'inventory_label_difference'.tr(),
              valueText: _formatQty(difference),
              theme: theme,
              valueColor: _differenceColor(difference),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyRow extends StatelessWidget {
  const _QtyRow({
    required this.label,
    required this.valueText,
    required this.theme,
    required this.valueColor,
  });

  final String label;
  final String valueText;
  final ThemeData theme;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: InventoryColors.subtitleGrey,
            ),
          ),
        ),
        Text(
          valueText,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
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
