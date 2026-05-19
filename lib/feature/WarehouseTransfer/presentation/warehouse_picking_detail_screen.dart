import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:looped_admin/core/di/injection.dart';
import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_gradient_action_button.dart';
import 'package:looped_admin/feature/WarehouseTransfer/data/warehouse_transfer_repository_impl.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_picking_detail.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_picking_move_line.dart';
import 'package:looped_admin/feature/WarehouseTransfer/widget/stock_picking_card.dart';

class WarehousePickingDetailScreen extends StatefulWidget {
  const WarehousePickingDetailScreen({
    super.key,
    required this.transferId,
    this.pickingName,
  });

  final int transferId;
  final String? pickingName;

  @override
  State<WarehousePickingDetailScreen> createState() =>
      _WarehousePickingDetailScreenState();
}

class _WarehousePickingDetailScreenState
    extends State<WarehousePickingDetailScreen> {
  StockPickingDetail? _detail;
  bool _loading = true;
  bool _isProcessing = false;
  bool _dataChanged = false;
  String? _error;
  final Map<int, double> _quantities = <int, double>{};

  WarehouseTransferRepositoryImpl get _repo =>
      WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>());

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _errorMessage(String? raw, {String fallback = ''}) {
    final fb = fallback.isEmpty
        ? 'transfer_picking_detail_generic_error'
        : fallback;
    if (raw == null || raw.isEmpty) return fb.tr();
    final trimmed = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (trimmed.startsWith('transfer_')) return trimmed.tr();
    if (trimmed.startsWith('FormatException: ')) {
      final inner = trimmed.replaceFirst('FormatException: ', '').trim();
      if (inner.startsWith('transfer_')) return inner.tr();
    }
    return fb.tr();
  }

  double _defaultQuantity(StockPickingMoveLine line) {
    final remaining = line.demand - line.quantityDone;
    return remaining > 0 ? remaining : 0;
  }

  void _syncQuantitiesFromDetail(StockPickingDetail detail) {
    _quantities
      ..clear()
      ..addEntries(
        detail.moveLines.map(
          (line) => MapEntry(line.id, _defaultQuantity(line)),
        ),
      );
  }

  dynamic _quantityForApi(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt();
    return qty;
  }

  bool get _canProcess =>
      !_loading &&
      !_isProcessing &&
      _error == null &&
      _detail != null &&
      _detail!.moveLines.isNotEmpty &&
      _quantities.values.any((q) => q > 0);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail =
          await _repo.fetchTransferDetails(transferId: widget.transferId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _syncQuantitiesFromDetail(detail);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _errorMessage(e.toString());
      });
    }
  }

  Future<void> _processTransfer() async {
    final detail = _detail;
    if (detail == null || _isProcessing) return;

    final payload = <Map<String, dynamic>>[
      for (final line in detail.moveLines)
        if ((_quantities[line.id] ?? 0) > 0)
          <String, dynamic>{
            'move_id': line.id,
            'quantity': _quantityForApi(_quantities[line.id]!),
          },
    ];

    if (payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('transfer_picking_process_no_lines'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isProcessing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _repo.processTransfer(
        transferId: widget.transferId,
        lines: payload,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('transfer_picking_process_success'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _dataChanged = true);
      await _load();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _errorMessage(
              e.toString(),
              fallback: 'transfer_picking_process_generic_error',
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _handleBack() {
    if (_isProcessing) return;
    Navigator.of(context).pop(_dataChanged);
  }

  void _setLineQuantity(int moveId, double quantity) {
    setState(() {
      _quantities[moveId] = quantity < 0 ? 0 : quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleName = widget.pickingName?.trim();
    final loadedName = _detail?.summary.name ?? '';
    final showProcessBar = !_loading &&
        _error == null &&
        (_detail?.moveLines.isNotEmpty ?? false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _isProcessing) return;
        _handleBack();
      },
      child: Scaffold(
      backgroundColor: InventoryColors.pageBackground,
      appBar: AppBar(
        backgroundColor: InventoryColors.pageBackground,
        foregroundColor: InventoryColors.primaryNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: _isProcessing ? null : _handleBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'transfer_picking_detail_title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: InventoryColors.primaryNavy,
              ),
            ),
            if ((titleName != null && titleName.isNotEmpty) ||
                loadedName.isNotEmpty)
              Text(
                (titleName != null && titleName.isNotEmpty)
                    ? titleName
                    : loadedName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: InventoryColors.subtitleGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
      body: _buildBody(theme),
      bottomNavigationBar: showProcessBar ? _buildProcessBar() : null,
      ),
    );
  }

  Widget? _buildProcessBar() {
    return Material(
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: InventoryColors.cardSurface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: InventoryGradientActionButton(
            label: 'transfer_picking_process_button'.tr(),
            icon: Icons.check_rounded,
            onPressed: _processTransfer,
            enabled: _canProcess,
            isLoading: _isProcessing,
            variant: InventoryActionButtonVariant.primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2.8),
      );
    }
    if (_error != null) {
      return _PickingDetailErrorState(
        message: _error!,
        onRetry: _load,
      );
    }

    final detail = _detail!;

    return RefreshIndicator(
      onRefresh: _load,
      color: InventoryColors.accentBlue,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          _detail!.moveLines.isNotEmpty ? 100 : 24,
        ),
        children: [
          StockPickingCard(item: detail.summary),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'transfer_detail_lines_heading'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: InventoryColors.primaryNavy,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: InventoryColors.primaryNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${detail.moveLines.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: InventoryColors.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (detail.moveLines.isEmpty)
            _EmptyMoveLinesPlaceholder()
          else
            ...detail.moveLines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PickingMoveLineTile(
                  line: line,
                  quantity: _quantities[line.id] ?? 0,
                  onQuantityChanged: (qty) => _setLineQuantity(line.id, qty),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PickingMoveLineTile extends StatefulWidget {
  const _PickingMoveLineTile({
    required this.line,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final StockPickingMoveLine line;
  final double quantity;
  final ValueChanged<double> onQuantityChanged;

  @override
  State<_PickingMoveLineTile> createState() => _PickingMoveLineTileState();
}

class _PickingMoveLineTileState extends State<_PickingMoveLineTile> {
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: _formatQty(widget.quantity));
  }

  @override
  void didUpdateWidget(covariant _PickingMoveLineTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final parsed = _parseQty(_qtyController.text);
    if (oldWidget.quantity != widget.quantity && parsed != widget.quantity) {
      _qtyController.text = _formatQty(widget.quantity);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  String _formatQty(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  double _parseQty(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return 0;
    return double.tryParse(normalized) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = widget.line;
    final uom = line.productUomName.isEmpty ? '—' : line.productUomName;

    return Container(
      decoration: BoxDecoration(
        color: InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InventoryColors.borderSubtle),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.productName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: InventoryColors.primaryNavy,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _QtyBadge(
                label: 'transfer_picking_label_demand'.tr(),
                value: _formatQty(line.demand),
                uom: uom,
              ),
              const SizedBox(width: 8),
              _QtyBadge(
                label: 'transfer_picking_label_done'.tr(),
                value: _formatQty(line.quantityDone),
                uom: uom,
                highlighted: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'transfer_label_quantity'.tr(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: InventoryColors.subtitleGrey,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 96,
                child: TextField(
                  controller: _qtyController,
                  textAlign: TextAlign.center,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  onChanged: (raw) =>
                      widget.onQuantityChanged(_parseQty(raw)),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: InventoryColors.accentBlueSoft,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: InventoryColors.accentBlue.withValues(alpha: 0.35),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: InventoryColors.accentBlue.withValues(alpha: 0.35),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: InventoryColors.accentBlue,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  uom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: InventoryColors.subtitleGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBadge extends StatelessWidget {
  const _QtyBadge({
    required this.label,
    required this.value,
    required this.uom,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final String uom;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = highlighted
        ? InventoryColors.accentBlueSoft
        : InventoryColors.primaryNavy.withValues(alpha: 0.06);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: InventoryColors.subtitleGrey,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$value $uom',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: InventoryColors.primaryNavy,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMoveLinesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InventoryColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: InventoryColors.subtitleGrey.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text(
            'transfer_picking_detail_empty_lines'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: InventoryColors.subtitleGrey,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _PickingDetailErrorState extends StatelessWidget {
  const _PickingDetailErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: InventoryColors.dangerText.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: InventoryColors.primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text('inventory_retry'.tr()),
              style: FilledButton.styleFrom(
                backgroundColor: InventoryColors.accentBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
