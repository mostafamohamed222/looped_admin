import 'dart:async' show unawaited;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:looped_admin/core/di/injection.dart';
import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_gradient_action_button.dart';
import 'package:looped_admin/feature/WarehouseTransfer/data/warehouse_transfer_repository_impl.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_detail.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_line.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_route_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/widget/stock_request_card.dart';
import 'package:looped_admin/feature/WarehouseTransfer/widget/transfer_searchable_picker_field.dart';

/// Returned via [Navigator.pop] after a successful detail action.
enum WarehouseTransferDetailResult {
  submitted,
  routeSaved,
  confirmed,
  linesAdded,
}

class WarehouseTransferDetailScreen extends StatefulWidget {
  const WarehouseTransferDetailScreen({super.key, required this.detail});

  final StockRequestDetail detail;

  @override
  State<WarehouseTransferDetailScreen> createState() =>
      _WarehouseTransferDetailScreenState();
}

class _WarehouseTransferDetailScreenState
    extends State<WarehouseTransferDetailScreen> {
  late StockRequestDetail _detail;
  bool _actionLoading = false;
  List<StockRouteOption> _routes = [];
  StockRouteOption? _selectedRoute;
  bool _routesLoading = false;
  String? _routesError;
  bool _routeWasSaved = false;
  List<ProductOption> _catalogProducts = [];
  bool _productsLoading = false;
  String? _productsError;
  bool _linesWereUpdated = false;
  Map<String, double> _pendingProductQuantities = {};
  List<ProductOption> _pendingProducts = [];

  @override
  void initState() {
    super.initState();
    _detail = widget.detail;
    if (_isSubmitted && _detail.id > 0) {
      unawaited(_loadRoutes());
    }
    if (_canEditRequestLines) {
      unawaited(_loadProducts());
    }
  }

  Set<int> get _existingProductIds =>
      _detail.lines.map((line) => line.productId).toSet();

  void _applyPendingSelection(
    Map<String, double> quantities,
    List<ProductOption> sourceProducts,
  ) {
    final nextQuantities = Map<String, double>.from(quantities)
      ..removeWhere((_, qty) => qty <= 0);
    final nextProducts = sourceProducts
        .where((p) => nextQuantities.containsKey(p.id))
        .toList();
    setState(() {
      _pendingProductQuantities = nextQuantities;
      _pendingProducts = nextProducts;
    });
  }

  void _setPendingQuantity(String productId, double quantity) {
    if (!_pendingProductQuantities.containsKey(productId)) return;
    setState(() {
      if (quantity <= 0) {
        _pendingProductQuantities.remove(productId);
        _pendingProducts.removeWhere((p) => p.id == productId);
      } else {
        _pendingProductQuantities[productId] = quantity;
      }
    });
  }

  void _removePendingProduct(String productId) {
    if (!_pendingProductQuantities.containsKey(productId)) return;
    setState(() {
      _pendingProductQuantities.remove(productId);
      _pendingProducts.removeWhere((p) => p.id == productId);
    });
  }

  bool get _isSubmitted {
    final key = _detail.state.toLowerCase().trim();
    return key == 'submitted' || key.contains('submitted');
  }

  /// Request still accepts product lines (API no longer uses `draft` only).
  bool get _canEditRequestLines {
    if (_detail.id <= 0 || _isSubmitted) return false;
    final key = _detail.state.toLowerCase().trim();
    if (key.isEmpty) return true;
    if (key.contains('confirm') ||
        key.contains('done') ||
        key.contains('close') ||
        key.contains('cancel') ||
        key.contains('reject')) {
      return false;
    }
    return true;
  }

  StockRouteOption? _routeMatchingDetail(List<StockRouteOption> routes) {
    if (_detail.routeId <= 0) return null;
    for (final route in routes) {
      if (route.id == _detail.routeId) return route;
    }
    if (_detail.routeName.isNotEmpty) {
      for (final route in routes) {
        if (route.label == _detail.routeName) return route;
      }
    }
    return null;
  }

  Future<void> _loadProducts() async {
    setState(() {
      _productsLoading = true;
      _productsError = null;
    });
    try {
      final repo = WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>());
      final products = await repo.fetchProductsCatalog();
      if (!mounted) return;
      setState(() {
        _catalogProducts = products;
        _productsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _productsLoading = false;
        _productsError =
            _transferError(e.toString(), 'transfer_products_generic_error');
      });
    }
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _routesLoading = true;
      _routesError = null;
    });
    try {
      final repo = WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>());
      final routes =
          await repo.fetchRoutes(requestOrderId: _detail.id);
      if (!mounted) return;
      setState(() {
        _routes = routes;
        _selectedRoute = _routeMatchingDetail(routes) ?? _selectedRoute;
        _routesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _routesLoading = false;
        _routesError =
            _transferError(e.toString(), 'transfer_routes_generic_error');
      });
    }
  }

  bool get _isBusy => _actionLoading;

  bool get _canSubmit => _detail.id > 0 && !_isBusy;

  /// Request already has a route assigned (`route_id` from server).
  bool get _hasRouteAssigned => _detail.routeId > 0;

  bool get _showDualSubmittedActions => _isSubmitted && _hasRouteAssigned;

  bool get _canSaveRoute =>
      _isSubmitted &&
      _detail.id > 0 &&
      !_isBusy &&
      !_routesLoading &&
      _routesError == null &&
      _selectedRoute != null;

  bool get _canConfirm =>
      _showDualSubmittedActions && _detail.id > 0 && !_isBusy;

  String _transferError(String? raw, String fallbackKey) {
    if (raw == null || raw.isEmpty) return fallbackKey.tr();
    final trimmed = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (trimmed.startsWith('transfer_')) return trimmed.tr();
    if (trimmed.startsWith('FormatException: ')) {
      final inner = trimmed.replaceFirst('FormatException: ', '').trim();
      if (inner.startsWith('transfer_')) return inner.tr();
    }
    return fallbackKey.tr();
  }

  Future<void> _onSubmit() async {
    if (!_canSubmit) return;
    setState(() => _actionLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>());
      if (_pendingProductQuantities.isNotEmpty) {
        final items = _buildAddLinesPayload(_pendingProductQuantities);
        if (items.isNotEmpty) {
          await repo.addRequestLines(
            requestOrderId: _detail.id,
            items: items,
          );
          if (!mounted) return;
          final updated =
              await repo.fetchRequestDetails(requestOrderId: _detail.id);
          setState(() {
            _detail = updated;
            _pendingProductQuantities = {};
            _pendingProducts = [];
            _linesWereUpdated = true;
          });
        } else {
          setState(() {
            _pendingProductQuantities = {};
            _pendingProducts = [];
          });
        }
      }
      await repo.submitRequest(requestOrderId: _detail.id);
      if (!mounted) return;
      Navigator.of(context).pop(WarehouseTransferDetailResult.submitted);
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(_transferError(e.toString(), 'transfer_submit_generic_error')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onAddRequestLines(
    Map<String, double> quantities, {
    List<ProductOption>? sourceProducts,
  }) async {
    final items = _buildAddLinesPayload(quantities);
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('transfer_add_lines_no_selection'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _actionLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>());
      await repo.addRequestLines(
        requestOrderId: _detail.id,
        items: items,
      );
      final updated =
          await repo.fetchRequestDetails(requestOrderId: _detail.id);
      if (!mounted) return;
      setState(() {
        _detail = updated;
        _pendingProductQuantities = {};
        _pendingProducts = [];
        _actionLoading = false;
        _linesWereUpdated = true;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text('transfer_detail_add_lines_success'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      if (sourceProducts != null) {
        _applyPendingSelection(quantities, sourceProducts);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _transferError(e.toString(), 'transfer_add_lines_generic_error'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onConfirm() async {
    if (!_canConfirm) return;
    setState(() => _actionLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>());
      await repo.confirmRequest(requestOrderId: _detail.id);
      if (!mounted) return;
      Navigator.of(context).pop(WarehouseTransferDetailResult.confirmed);
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _transferError(e.toString(), 'transfer_confirm_generic_error'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _buildAddLinesPayload(
    Map<String, double> quantities,
  ) {
    final items = <Map<String, dynamic>>[];
    for (final product in _catalogProducts) {
      final qty = quantities[product.id];
      if (qty == null || qty <= 0) continue;
      if (_existingProductIds.contains(product.odooProductId)) continue;
      items.add(<String, dynamic>{
        'product_id': product.odooProductId,
        'quantity': qty,
      });
    }
    return items;
  }

  Future<void> _openAddProductsSheet() async {
    if (_isBusy || _productsLoading) return;
    if (_productsError != null) {
      await _loadProducts();
      if (!mounted || _productsError != null) return;
    }
    final available = _catalogProducts
        .where((p) => !_existingProductIds.contains(p.odooProductId))
        .toList();
    if (!mounted) return;
    final quantities = await showModalBottomSheet<Map<String, double>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: InventoryColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return _DraftAddProductsSheet(
              sheetContext: sheetContext,
              scrollController: scrollController,
              products: available,
              initialQuantities: _pendingProductQuantities,
              isCatalogLoading: _productsLoading,
              catalogError: _productsError,
              onRetryCatalog: _loadProducts,
            );
          },
        );
      },
    );
    if (!mounted || quantities == null) return;
    final hasSelection = quantities.values.any((qty) => qty > 0);
    if (!hasSelection) {
      setState(() {
        _pendingProductQuantities = {};
        _pendingProducts = [];
      });
      return;
    }
    await _onAddRequestLines(quantities, sourceProducts: available);
  }

  Future<void> _onSaveRoute() async {
    final route = _selectedRoute;
    if (!_canSaveRoute || route == null) return;
    setState(() => _actionLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>());
      await repo.setRoute(
        requestOrderId: _detail.id,
        routeId: route.id,
      );
      final updated =
          await repo.fetchRequestDetails(requestOrderId: _detail.id);
      if (!mounted) return;
      setState(() {
        _detail = updated;
        _selectedRoute = _routeMatchingDetail(_routes) ?? route;
        _actionLoading = false;
        _routeWasSaved = true;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text('transfer_route_save_success'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _transferError(e.toString(), 'transfer_set_route_generic_error'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _pop() {
    if (_isBusy) return;
    if (_routeWasSaved) {
      Navigator.of(context).pop(WarehouseTransferDetailResult.routeSaved);
      return;
    }
    if (_linesWereUpdated) {
      Navigator.of(context).pop(WarehouseTransferDetailResult.linesAdded);
      return;
    }
    Navigator.of(context).pop();
  }

  bool get _showBottomAction =>
      _detail.id > 0 && (_canEditRequestLines || _isSubmitted);

  double get _listBottomInset {
    if (!_showBottomAction) return 0;
    if (_canEditRequestLines) return 100;
    return 88;
  }

  bool get _canOpenAddProducts =>
      _canEditRequestLines && !_isBusy && _productsError == null;

  Widget? _buildBottomBar(double bottomInset) {
    if (!_showBottomAction) return null;

    Widget actions;
    if (_isBusy) {
      actions = const SizedBox(
        height: 56,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.8),
        ),
      );
    } else if (_canEditRequestLines) {
      actions = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InventoryGradientActionButton(
              label: 'transfer_detail_add_products'.tr(),
              icon: Icons.add_rounded,
              onPressed: _openAddProductsSheet,
              enabled: _canOpenAddProducts,
              compact: true,
              variant: InventoryActionButtonVariant.secondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InventoryGradientActionButton(
              label: 'transfer_detail_submit'.tr(),
              icon: Icons.send_rounded,
              onPressed: _onSubmit,
              enabled: _canSubmit,
              compact: true,
            ),
          ),
        ],
      );
    } else if (_showDualSubmittedActions) {
      actions = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InventoryGradientActionButton(
              label: 'transfer_detail_change_route'.tr(),
              icon: Icons.alt_route_rounded,
              onPressed: _onSaveRoute,
              enabled: _canSaveRoute,
              compact: true,
              variant: InventoryActionButtonVariant.secondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InventoryGradientActionButton(
              label: 'transfer_detail_confirm'.tr(),
              icon: Icons.check_rounded,
              onPressed: _onConfirm,
              enabled: _canConfirm,
              compact: true,
              variant: InventoryActionButtonVariant.primaryBlue,
            ),
          ),
        ],
      );
    } else {
      actions = InventoryGradientActionButton(
        label: 'transfer_detail_register_route'.tr(),
        icon: Icons.alt_route_rounded,
        onPressed: _onSaveRoute,
        enabled: _canSaveRoute,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: InventoryColors.cardSurface,
        border: Border(
          top: BorderSide(
            color: InventoryColors.borderSubtle.withValues(alpha: 0.9),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: InventoryColors.primaryNavy.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
        child: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateStyle = TransferStateStyle.forState(_detail.state);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: !_isBusy,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _isBusy) return;
        _pop();
      },
      child: Scaffold(
        backgroundColor: InventoryColors.pageBackground,
        appBar: AppBar(
          backgroundColor: InventoryColors.pageBackground,
          foregroundColor: InventoryColors.primaryNavy,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: _isBusy ? null : _pop,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: Text(
            'transfer_detail_title'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: InventoryColors.primaryNavy,
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(bottomInset),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            28 + _listBottomInset,
          ),
          children: [
            _RequestSummaryCard(detail: _detail, stateStyle: stateStyle),
            if (_isSubmitted && _detail.id > 0) ...[
              const SizedBox(height: 20),
              _SubmittedRouteSection(
                routes: _routes,
                selectedRoute: _selectedRoute,
                isLoading: _routesLoading,
                errorMessage: _routesError,
                onRetry: _loadRoutes,
                onSelected: (route) =>
                    setState(() => _selectedRoute = route),
              ),
            ],
            const SizedBox(height: 24),
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
                    '${_detail.lines.length + _pendingProductQuantities.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: InventoryColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_canEditRequestLines) ...[
              _DraftAddProductsBanner(
                isLoading: _productsLoading,
                errorMessage: _productsError,
                pendingCount: _pendingProductQuantities.length,
                onRetry: _loadProducts,
                onAdd: _openAddProductsSheet,
                enabled: _canOpenAddProducts,
              ),
              const SizedBox(height: 12),
            ],
            if (_pendingProducts.isNotEmpty) ...[
              _DetailPendingProductsList(
                theme: theme,
                products: _pendingProducts,
                quantities: _pendingProductQuantities,
                onQuantityChanged: _setPendingQuantity,
                onRemove: _removePendingProduct,
              ),
              const SizedBox(height: 12),
            ],
            if (_detail.lines.isEmpty && _pendingProductQuantities.isEmpty)
              const _EmptyLinesPlaceholder()
            else
              ..._detail.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ProductLineTile(line: line),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DraftAddProductsBanner extends StatelessWidget {
  const _DraftAddProductsBanner({
    required this.isLoading,
    required this.errorMessage,
    required this.pendingCount,
    required this.onRetry,
    required this.onAdd,
    required this.enabled,
  });

  final bool isLoading;
  final String? errorMessage;
  final int pendingCount;
  final VoidCallback onRetry;
  final VoidCallback onAdd;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: InventoryColors.dangerTint,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: InventoryColors.dangerText.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: InventoryColors.dangerText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('inventory_retry'.tr()),
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: InventoryColors.accentBlueSoft,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onAdd : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              else
                const Icon(
                  Icons.add_circle_outline_rounded,
                  color: InventoryColors.accentBlue,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pendingCount == 0
                      ? 'transfer_detail_add_products'.tr()
                      : 'transfer_products_selected_count'.tr(
                          namedArgs: {'count': '$pendingCount'},
                        ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: InventoryColors.primaryNavy,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: InventoryColors.primaryNavy.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DraftAddProductsSheet extends StatefulWidget {
  const _DraftAddProductsSheet({
    required this.sheetContext,
    required this.scrollController,
    required this.products,
    required this.initialQuantities,
    required this.isCatalogLoading,
    required this.catalogError,
    required this.onRetryCatalog,
  });

  final BuildContext sheetContext;
  final ScrollController scrollController;
  final List<ProductOption> products;
  final Map<String, double> initialQuantities;
  final bool isCatalogLoading;
  final String? catalogError;
  final VoidCallback onRetryCatalog;

  @override
  State<_DraftAddProductsSheet> createState() => _DraftAddProductsSheetState();
}

class _DraftAddProductsSheetState extends State<_DraftAddProductsSheet> {
  late final Map<String, double> _quantities;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _quantities = Map<String, double>.from(widget.initialQuantities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(ProductOption product) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    final title = (product.displayName ?? product.name).toLowerCase();
    final sku = product.sku.toLowerCase();
    final barcode = (product.barcode ?? '').toLowerCase();
    return title.contains(q) || sku.contains(q) || barcode.contains(q);
  }

  List<ProductOption> get _filteredProducts =>
      widget.products.where(_matchesSearch).toList();

  void _toggleProduct(ProductOption product) {
    setState(() {
      if (_quantities.containsKey(product.id)) {
        _quantities.remove(product.id);
      } else {
        _quantities[product.id] = 1;
      }
    });
  }

  void _setQuantity(String productId, double quantity) {
    if (!_quantities.containsKey(productId)) return;
    setState(() {
      _quantities[productId] = quantity < 0 ? 0 : quantity;
    });
  }

  void _done() {
    final selected = Map<String, double>.from(_quantities)
      ..removeWhere((_, qty) => qty <= 0);
    Navigator.pop<Map<String, double>>(widget.sheetContext, selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            'transfer_detail_add_products'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: InventoryColors.primaryNavy,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'inventory_product_search_hint'.tr(),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
              filled: true,
              fillColor: InventoryColors.pageBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(child: _buildBody(theme, widget.scrollController)),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
          child: InventoryGradientActionButton(
            label: 'inventory_done'.tr(),
            icon: Icons.check_rounded,
            onPressed: _done,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme, ScrollController scrollController) {
    if (widget.catalogError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.catalogError!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: InventoryColors.dangerText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: widget.onRetryCatalog,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('inventory_retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }
    if (widget.isCatalogLoading && widget.products.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.6));
    }
    if (widget.products.isEmpty) {
      return Center(
        child: Text(
          'transfer_products_empty'.tr(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: InventoryColors.subtitleGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final filtered = _filteredProducts;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'inventory_product_empty'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: InventoryColors.subtitleGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final product = filtered[index];
        final selected = _quantities.containsKey(product.id);
        final title = (product.displayName ?? product.name).trim();
        return Material(
          color: selected
              ? InventoryColors.accentBlueSoft
              : InventoryColors.pageBackground,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              CheckboxListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                value: selected,
                onChanged: (_) => _toggleProduct(product),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: InventoryColors.primaryNavy,
                  ),
                ),
                subtitle: product.sku.isNotEmpty
                    ? Text(
                        product.sku,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _DraftSheetQtyRow(
                    key: ValueKey(product.id),
                    quantity: _quantities[product.id] ?? 1,
                    onChanged: (qty) => _setQuantity(product.id, qty),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailPendingProductsList extends StatelessWidget {
  const _DetailPendingProductsList({
    required this.theme,
    required this.products,
    required this.quantities,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final ThemeData theme;
  final List<ProductOption> products;
  final Map<String, double> quantities;
  final void Function(String productId, double quantity) onQuantityChanged;
  final void Function(String productId) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'transfer_selected_products_heading'.tr(),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: InventoryColors.subtitleGrey,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        ...products.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _DetailPendingProductCard(
              key: ValueKey(product.id),
              theme: theme,
              product: product,
              quantity: quantities[product.id] ?? 1,
              onQuantityChanged: onQuantityChanged,
              onRemove: onRemove,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailPendingProductCard extends StatefulWidget {
  const _DetailPendingProductCard({
    super.key,
    required this.theme,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final ThemeData theme;
  final ProductOption product;
  final double quantity;
  final void Function(String productId, double quantity) onQuantityChanged;
  final void Function(String productId) onRemove;

  @override
  State<_DetailPendingProductCard> createState() =>
      _DetailPendingProductCardState();
}

class _DetailPendingProductCardState extends State<_DetailPendingProductCard> {
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: _formatQty(widget.quantity));
  }

  @override
  void didUpdateWidget(covariant _DetailPendingProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity &&
        _parseQty(_qtyController.text) != widget.quantity) {
      _qtyController.text = _formatQty(widget.quantity);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  String _formatQty(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  double _parseQty(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return 0;
    return double.tryParse(normalized) ?? 0;
  }

  void _commitQuantity() {
    widget.onQuantityChanged(widget.product.id, _parseQty(_qtyController.text));
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.product.displayName ?? widget.product.name).trim();

    return Container(
      decoration: BoxDecoration(
        color: InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: InventoryColors.borderSubtle.withValues(alpha: 0.9),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: InventoryColors.accentBlueSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: InventoryColors.accentBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: InventoryColors.primaryNavy,
                    height: 1.2,
                  ),
                ),
                if (widget.product.sku.isNotEmpty)
                  Text(
                    widget.product.sku,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: widget.theme.textTheme.labelSmall?.copyWith(
                      color: InventoryColors.subtitleGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            height: 36,
            child: TextField(
              controller: _qtyController,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: (_) => _commitQuantity(),
              onEditingComplete: _commitQuantity,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: InventoryColors.primaryNavy,
                height: 1.1,
              ),
              decoration: InputDecoration(
                hintText: '0',
                isDense: true,
                filled: true,
                fillColor: InventoryColors.pageBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: InventoryColors.borderSubtle,
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
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'transfer_remove_product'.tr(),
              onPressed: () => widget.onRemove(widget.product.id),
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: InventoryColors.subtitleGrey.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftSheetQtyRow extends StatefulWidget {
  const _DraftSheetQtyRow({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  final double quantity;
  final ValueChanged<double> onChanged;

  @override
  State<_DraftSheetQtyRow> createState() => _DraftSheetQtyRowState();
}

class _DraftSheetQtyRowState extends State<_DraftSheetQtyRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatSheetQty(widget.quantity));
  }

  @override
  void didUpdateWidget(covariant _DraftSheetQtyRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final parsed = _parseQty(_controller.text);
    if (oldWidget.quantity != widget.quantity && parsed != widget.quantity) {
      _controller.text = _formatSheetQty(widget.quantity);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatSheetQty(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  double _parseQty(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return 0;
    return double.tryParse(normalized) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
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
          width: 88,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            onChanged: (raw) => widget.onChanged(_parseQty(raw)),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: InventoryColors.cardSurface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: InventoryColors.borderSubtle),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmittedRouteSection extends StatelessWidget {
  const _SubmittedRouteSection({
    required this.routes,
    required this.selectedRoute,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onSelected,
  });

  final List<StockRouteOption> routes;
  final StockRouteOption? selectedRoute;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<StockRouteOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'transfer_pick_route'.tr(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: InventoryColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 10),
        if (errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: InventoryColors.dangerTint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: InventoryColors.dangerText.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: InventoryColors.dangerText,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('inventory_retry'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ] else
          TransferSearchablePickerField<StockRouteOption>(
            sectionLabel: 'transfer_pick_route'.tr(),
            hint: 'transfer_route_hint'.tr(),
            modalTitle: 'transfer_modal_route_title'.tr(),
            searchHint: 'transfer_route_search_hint'.tr(),
            emptyMessage: 'transfer_routes_empty'.tr(),
            items: routes,
            selected: selectedRoute,
            onSelected: onSelected,
            enabled: !isLoading && routes.isNotEmpty,
            isLoading: isLoading,
            icon: Icons.alt_route_rounded,
            displayName: (route) => route.label,
            filterItem: (route, query) {
              final q = query.toLowerCase().trim();
              if (q.isEmpty) return true;
              return route.label.toLowerCase().contains(q) ||
                  route.name.toLowerCase().contains(q);
            },
          ),
      ],
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({
    required this.detail,
    required this.stateStyle,
  });

  final StockRequestDetail detail;
  final TransferStateStyle stateStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InventoryColors.borderSubtle.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: InventoryColors.primaryNavy.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        stateStyle.accent.withValues(alpha: 0.18),
                        stateStyle.background,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: stateStyle.accent.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    size: 22,
                    color: stateStyle.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: InventoryColors.primaryNavy,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'transfer_detail_id_label'.tr(
                          namedArgs: {'id': '${detail.id}'},
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (detail.expectedDate.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          StockRequestCard.formatExpectedDate(
                            detail.expectedDate,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: InventoryColors.subtitleGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TransferStatusChip(
                  label: detail.state.isEmpty ? '—' : detail.state,
                  style: stateStyle,
                ),
              ],
            ),
          ),
          _InfoPanel(detail: detail, embedded: true),
        ],
      ),
    );
  }
}

class _InfoEntry {
  const _InfoEntry({
    required this.icon,
    required this.title,
    this.label,
    this.subtitle,
  });

  final IconData icon;
  final String? label;
  final String title;
  final String? subtitle;
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.detail, this.embedded = false});

  final StockRequestDetail detail;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final entries = <_InfoEntry>[];
    if (detail.warehouseName.isNotEmpty || detail.locationName.isNotEmpty) {
      entries.add(
        _InfoEntry(
          icon: Icons.warehouse_outlined,
          title: detail.warehouseName.isNotEmpty
              ? detail.warehouseName
              : detail.locationName,
          subtitle: detail.warehouseName.isNotEmpty &&
                  detail.locationName.isNotEmpty
              ? detail.locationName
              : null,
        ),
      );
    }
    if (detail.routeName.isNotEmpty) {
      entries.add(
        _InfoEntry(icon: Icons.alt_route_rounded, title: detail.routeName),
      );
    }
    if (detail.companyName.isNotEmpty) {
      entries.add(
        _InfoEntry(icon: Icons.business_outlined, title: detail.companyName),
      );
    }
    if (detail.requestedByName.isNotEmpty) {
      entries.add(
        _InfoEntry(
          icon: Icons.person_outline_rounded,
          label: 'transfer_label_requested_by'.tr(),
          title: detail.requestedByName,
        ),
      );
    }
    if (detail.branchName.isNotEmpty) {
      entries.add(
        _InfoEntry(
          icon: Icons.storefront_outlined,
          label: 'transfer_label_branch'.tr(),
          title: detail.branchName,
        ),
      );
    }
    if (entries.isEmpty) return const SizedBox.shrink();

    final tiles = Column(
      children: [
        Divider(
          height: 1,
          thickness: 1,
          color: InventoryColors.borderSubtle.withValues(alpha: 0.7),
        ),
        for (var i = 0; i < entries.length; i++)
          _InfoTile(
            icon: entries[i].icon,
            label: entries[i].label,
            title: entries[i].title,
            subtitle: entries[i].subtitle,
            isLast: i == entries.length - 1,
          ),
      ],
    );

    if (embedded) return tiles;

    return Container(
      decoration: BoxDecoration(
        color: InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InventoryColors.borderSubtle.withValues(alpha: 0.9),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: tiles,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    this.label,
    this.subtitle,
    this.isLast = false,
  });

  final IconData icon;
  final String? label;
  final String title;
  final String? subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: InventoryColors.tonalIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: InventoryColors.primaryNavy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label != null) ...[
                      Text(
                        label!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: InventoryColors.primaryNavy,
                        height: 1.35,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 62,
            color: InventoryColors.borderSubtle.withValues(alpha: 0.7),
          ),
      ],
    );
  }
}

class _EmptyLinesPlaceholder extends StatelessWidget {
  const _EmptyLinesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
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
            'transfer_detail_empty_lines'.tr(),
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

class _ProductLineTile extends StatelessWidget {
  const _ProductLineTile({required this.line});

  final StockRequestLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qty = _formatQty(line.productUomQty);
    final uom = line.productUomName.isEmpty ? '—' : line.productUomName;
    final lineStateStyle = TransferStateStyle.forState(line.state);

    return Container(
      decoration: BoxDecoration(
        color: InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InventoryColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (line.state.isNotEmpty)
            Container(
              height: 3,
              color: lineStateStyle.accent.withValues(alpha: 0.85),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        line.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: InventoryColors.primaryNavy,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (line.state.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      TransferStatusChip(
                        label: line.state,
                        style: lineStateStyle,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      uom,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: InventoryColors.subtitleGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: InventoryColors.accentBlueSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        qty,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: InventoryColors.accentBlue,
                        ),
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
  }
}

String _formatQty(double v) {
  if (v == v.roundToDouble()) return '${v.round()}';
  return v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}
