import 'dart:async' show unawaited;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/core/di/injection.dart';
import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/WarehouseTransfer/data/warehouse_transfer_repository_impl.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_transfers.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_picking_summary.dart';
import 'package:looped_admin/feature/WarehouseTransfer/presentation/warehouse_picking_detail_screen.dart';
import 'package:looped_admin/feature/WarehouseTransfer/widget/stock_picking_card.dart';
import 'package:looped_admin/feature/WarehouseTransfer/widget/stock_request_card.dart';

class WarehouseRequestTransfersScreen extends StatefulWidget {
  const WarehouseRequestTransfersScreen({
    super.key,
    required this.requestOrderId,
    this.requestName,
  });

  final int requestOrderId;
  final String? requestName;

  @override
  State<WarehouseRequestTransfersScreen> createState() =>
      _WarehouseRequestTransfersScreenState();
}

class _WarehouseRequestTransfersScreenState
    extends State<WarehouseRequestTransfersScreen> {
  StockRequestTransfers? _data;
  bool _loading = true;
  String? _error;
  bool _dataChanged = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _errorMessage(String? raw) {
    const fallback = 'transfer_request_transfers_generic_error';
    if (raw == null || raw.isEmpty) return fallback.tr();
    final trimmed = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (trimmed.startsWith('transfer_')) return trimmed.tr();
    if (trimmed.startsWith('FormatException: ')) {
      final inner = trimmed.replaceFirst('FormatException: ', '').trim();
      if (inner.startsWith('transfer_')) return inner.tr();
    }
    return fallback.tr();
  }

  Future<void> _openPickingDetail(
    BuildContext context,
    StockPickingSummary picking,
  ) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => WarehousePickingDetailScreen(
          transferId: picking.id,
          pickingName: picking.name,
        ),
      ),
    );
    if (!mounted) return;
    if (changed == true) _dataChanged = true;
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>());
      final result = await repo.fetchRequestTransfers(
        requestOrderId: widget.requestOrderId,
      );
      if (!mounted) return;
      setState(() {
        _data = result;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requestName = widget.requestName?.trim();
    final titleName = (requestName != null && requestName.isNotEmpty)
        ? requestName
        : ( _data?.requestOrder.name ?? '');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_dataChanged);
      },
      child: Scaffold(
      backgroundColor: InventoryColors.pageBackground,
      appBar: AppBar(
        backgroundColor: InventoryColors.pageBackground,
        foregroundColor: InventoryColors.primaryNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'transfer_request_transfers_title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: InventoryColors.primaryNavy,
              ),
            ),
            if (titleName.isNotEmpty)
              Text(
                titleName,
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
      return _TransfersErrorState(
        message: _error!,
        onRetry: _load,
      );
    }
    final data = _data!;
    if (data.transfers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'transfer_request_transfers_empty'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: InventoryColors.subtitleGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final stateStyle =
        TransferStateStyle.forState(data.requestOrder.state);

    return RefreshIndicator(
      onRefresh: _load,
      color: InventoryColors.accentBlue,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: InventoryColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: InventoryColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'transfer_request_transfers_count'.tr(
                      namedArgs: {'count': '${data.pickingCount}'},
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: InventoryColors.primaryNavy,
                    ),
                  ),
                ),
                TransferStatusChip(
                  label: data.requestOrder.state.isEmpty
                      ? '—'
                      : data.requestOrder.state,
                  style: stateStyle,
                  compact: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...data.transfers.map(
            (picking) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StockPickingCard(
                item: picking,
                onTap: () => unawaited(_openPickingDetail(context, picking)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransfersErrorState extends StatelessWidget {
  const _TransfersErrorState({
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
