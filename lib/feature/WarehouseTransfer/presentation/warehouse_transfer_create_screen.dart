import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/core/di/injection.dart';
import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_gradient_action_button.dart';
import 'package:looped_admin/feature/WarehouseTransfer/data/warehouse_transfer_repository_impl.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_location_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_warehouse_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/presentation/cubit/warehouse_transfer_create_cubit.dart';
import 'package:looped_admin/feature/WarehouseTransfer/presentation/cubit/warehouse_transfer_create_state.dart';
import 'package:looped_admin/feature/WarehouseTransfer/widget/transfer_searchable_picker_field.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_app_bar.dart';

/// Create transfer request: warehouse → location → products → submit.
class WarehouseTransferCreateScreen extends StatelessWidget {
  const WarehouseTransferCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WarehouseTransferCreateCubit(
        repository: WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>()),
      )..loadWarehouses(),
      child: const _WarehouseTransferCreateView(),
    );
  }
}

class _WarehouseTransferCreateView extends StatelessWidget {
  const _WarehouseTransferCreateView();

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

  Future<void> _onSubmit(BuildContext context) async {
    final cubit = context.read<WarehouseTransferCreateCubit>();
    final created = await cubit.submitRequest();
    if (!context.mounted) return;
    final after = cubit.state;
    final messenger = ScaffoldMessenger.of(context);

    if (after.submitStatus == TransferSubmitStatus.success && created != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'transfer_create_success'.tr(
              namedArgs: {'id': '${created.requestOrderId}'},
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      cubit.clearSubmitFeedback();
      Navigator.of(context).pop(true);
      return;
    }

    if (after.submitStatus == TransferSubmitStatus.failure) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_submitError(after.submitErrorMessage)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      cubit.clearSubmitFeedback();
    }
  }

  String _submitError(String? raw) {
    if (raw == null || raw.isEmpty) return 'transfer_create_generic_error'.tr();
    final trimmed = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (trimmed.startsWith('transfer_')) return trimmed.tr();
    if (trimmed.startsWith('FormatException: ')) {
      final inner = trimmed.replaceFirst('FormatException: ', '').trim();
      if (inner.startsWith('transfer_')) return inner.tr();
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InventoryColors.pageBackground,
      body: SafeArea(
        child: BlocBuilder<WarehouseTransferCreateCubit,
            WarehouseTransferCreateState>(
          builder: (context, state) {
            final showSubmitBar = state.warehouseLoadStatus ==
                    TransferWarehouseLoadStatus.success ||
                state.warehouses.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(
                        child: AccountSettingsAppBar(
                          onMenuTap: () => Navigator.of(context).maybePop(),
                          onHelpTap: () {},
                        ),
                      ),
                      ..._buildSlivers(context, state),
                      if (showSubmitBar)
                        const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    ],
                  ),
                ),
                if (showSubmitBar)
                  _CreateSubmitBar(
                    state: state,
                    onSubmit: () => _onSubmit(context),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(
    BuildContext context,
    WarehouseTransferCreateState state,
  ) {
    final theme = Theme.of(context);

    if (state.warehouseLoadStatus == TransferWarehouseLoadStatus.loading &&
        state.warehouses.isEmpty) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2.8),
          ),
        ),
      ];
    }

    if (state.warehouseLoadStatus == TransferWarehouseLoadStatus.failure &&
        state.warehouses.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CreateErrorState(
            message: _transferError(
              state.warehouseErrorMessage,
              'transfer_warehouses_generic_error',
            ),
            onRetry: () =>
                context.read<WarehouseTransferCreateCubit>().retryWarehouses(),
          ),
        ),
      ];
    }

    final cubit = context.read<WarehouseTransferCreateCubit>();

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          _CreateHeroHeader(theme: theme),
          const SizedBox(height: 18),
          _CreateStepCard(
            step: 1,
            title: 'transfer_create_step_destination'.tr(),
            icon: Icons.local_shipping_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TransferSearchablePickerField<StockWarehouseOption>(
                  compact: true,
                  sectionLabel: 'transfer_pick_warehouse'.tr(),
                  hint: 'transfer_warehouse_hint'.tr(),
                  modalTitle: 'transfer_modal_warehouse_title'.tr(),
                  searchHint: 'transfer_warehouse_search_hint'.tr(),
                  emptyMessage: 'transfer_warehouse_empty'.tr(),
                  items: state.warehouses,
                  selected: state.selectedWarehouse,
                  onSelected: cubit.selectWarehouse,
                  enabled: state.warehouseLoadStatus ==
                      TransferWarehouseLoadStatus.success,
                  isLoading: state.isWarehouseLoading,
                  displayName: (w) => w.name,
                  icon: Icons.warehouse_outlined,
                ),
                if (state.warehouseLoadStatus ==
                        TransferWarehouseLoadStatus.failure &&
                    state.warehouses.isNotEmpty)
                  _InlineRetryError(
                    message: _transferError(
                      state.warehouseErrorMessage,
                      'transfer_warehouses_generic_error',
                    ),
                    onRetry: cubit.retryWarehouses,
                  ),
                const SizedBox(height: 10),
                if (!state.canPickLocation)
                  _HintChip(text: 'transfer_location_disabled_hint'.tr()),
                TransferSearchablePickerField<StockLocationOption>(
                  compact: true,
                  sectionLabel: 'transfer_pick_location'.tr(),
                  hint: 'transfer_location_hint'.tr(),
                  modalTitle: 'transfer_modal_location_title'.tr(),
                  searchHint: 'transfer_location_search_hint'.tr(),
                  emptyMessage: 'transfer_location_empty'.tr(),
                  items: state.locations,
                  selected: state.selectedLocation,
                  onSelected: cubit.selectLocation,
                  enabled: state.canPickLocation &&
                      state.locationLoadStatus !=
                          TransferLocationLoadStatus.loading,
                  isLoading: state.isLocationLoading,
                  displayName: (l) => l.name,
                  icon: Icons.place_outlined,
                ),
                if (state.canPickLocation &&
                    state.locationLoadStatus ==
                        TransferLocationLoadStatus.failure)
                  _InlineRetryError(
                    message: _transferError(
                      state.locationErrorMessage,
                      'transfer_locations_generic_error',
                    ),
                    onRetry: cubit.retryLocations,
                  ),
              ],
            ),
          ),
              if (state.canPickProducts) ...[
                const SizedBox(height: 14),
                _CreateStepCard(
                  step: 2,
                  title: 'transfer_section_products'.tr(),
                  icon: Icons.inventory_2_outlined,
                  trailing: state.productQuantities.isEmpty
                      ? null
                      : _CountBadge(count: state.productQuantities.length),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.isProductsLoading &&
                          state.catalogProducts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                            ),
                          ),
                        )
                      else if (state.productsLoadStatus ==
                              TransferProductsLoadStatus.failure &&
                          state.catalogProducts.isEmpty)
                        _InlineProductsError(
                          message: _transferError(
                            state.productsErrorMessage,
                            'transfer_products_generic_error',
                          ),
                          onRetry: cubit.retryProducts,
                        )
                      else ...[
                        _AddProductsButton(
                          theme: theme,
                          state: state,
                        ),
                        if (state.productQuantities.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _SelectedProductsList(
                            theme: theme,
                            products: state.selectedProductsInOrder(
                              state.catalogProducts,
                            ),
                            quantities: state.productQuantities,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ];
  }
}

class _CreateSubmitBar extends StatelessWidget {
  const _CreateSubmitBar({
    required this.state,
    required this.onSubmit,
  });

  final WarehouseTransferCreateState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        child: InventoryGradientActionButton(
          label: 'transfer_create_submit'.tr(),
          icon: Icons.check_rounded,
          onPressed: onSubmit,
          enabled: state.canSubmit,
          isLoading: state.isSubmitting,
        ),
      ),
    );
  }
}

class _CreateHeroHeader extends StatelessWidget {
  const _CreateHeroHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            InventoryColors.primaryNavy,
            InventoryColors.primaryNavy.withValues(alpha: 0.88),
            const Color(0xFF1E3A6E),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: InventoryColors.primaryNavy.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'transfer_create_title'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'transfer_create_subtitle'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateStepCard extends StatelessWidget {
  const _CreateStepCard({
    required this.step,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final int step;
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InventoryColors.borderSubtle.withValues(alpha: 0.95),
        ),
        boxShadow: [
          BoxShadow(
            color: InventoryColors.primaryNavy.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: InventoryColors.accentBlueSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$step',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: InventoryColors.accentBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, size: 18, color: InventoryColors.accentBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: InventoryColors.primaryNavy,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: InventoryColors.primaryNavy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: InventoryColors.primaryNavy,
            ),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: InventoryColors.subtitleGrey.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: InventoryColors.subtitleGrey,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineRetryError extends StatelessWidget {
  const _InlineRetryError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: InventoryColors.dangerText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text('inventory_retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _AddProductsButton extends StatelessWidget {
  const _AddProductsButton({
    required this.theme,
    required this.state,
  });

  final ThemeData theme;
  final WarehouseTransferCreateState state;

  String _summary() {
    if (state.productQuantities.isEmpty) {
      return 'transfer_products_add_cta'.tr();
    }
    final count = state.productQuantities.length;
    return 'transfer_products_selected_count'.tr(
      namedArgs: {'count': '$count'},
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final cubit = context.read<WarehouseTransferCreateCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: InventoryColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.55,
            minChildSize: 0.35,
            maxChildSize: 0.92,
            builder: (_, scrollController) {
              return _CreateProductsPickerSheet(
                theme: theme,
                scrollController: scrollController,
                sheetContext: sheetContext,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = state.productQuantities.isNotEmpty;

    return Material(
      color: hasSelection
          ? InventoryColors.accentBlueSoft
          : InventoryColors.pageBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: state.catalogProducts.isEmpty
            ? null
            : () => _openSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasSelection
                  ? InventoryColors.accentBlue.withValues(alpha: 0.35)
                  : InventoryColors.borderSubtle,
              width: hasSelection ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: hasSelection
                      ? InventoryColors.cardSurface
                      : InventoryColors.tonalIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasSelection
                      ? Icons.edit_outlined
                      : Icons.add_rounded,
                  size: 20,
                  color: InventoryColors.accentBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _summary(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: hasSelection
                        ? InventoryColors.primaryNavy
                        : InventoryColors.subtitleGrey,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: InventoryColors.primaryNavy.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateProductsPickerSheet extends StatefulWidget {
  const _CreateProductsPickerSheet({
    required this.theme,
    required this.scrollController,
    required this.sheetContext,
  });

  final ThemeData theme;
  final ScrollController scrollController;
  final BuildContext sheetContext;

  @override
  State<_CreateProductsPickerSheet> createState() =>
      _CreateProductsPickerSheetState();
}

class _CreateProductsPickerSheetState extends State<_CreateProductsPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WarehouseTransferCreateCubit>();
    final bottom = MediaQuery.of(widget.sheetContext).padding.bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            'transfer_section_products'.tr(),
            style: widget.theme.textTheme.titleLarge?.copyWith(
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
        Expanded(
          child: BlocBuilder<WarehouseTransferCreateCubit,
              WarehouseTransferCreateState>(
            builder: (context, sheetState) {
              if (sheetState.catalogProducts.isEmpty) {
                return Center(
                  child: Text(
                    'transfer_products_empty'.tr(),
                    style: widget.theme.textTheme.bodyLarge?.copyWith(
                      color: InventoryColors.subtitleGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              final filtered = sheetState.catalogProducts
                  .where(_matchesSearch)
                  .toList();
              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'inventory_product_empty'.tr(),
                      textAlign: TextAlign.center,
                      style: widget.theme.textTheme.bodyLarge?.copyWith(
                        color: InventoryColors.subtitleGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  final selected =
                      sheetState.productQuantities.containsKey(p.id);
                  final title = (p.displayName ?? p.name).trim();
                  return Material(
                    color: selected
                        ? InventoryColors.accentBlueSoft
                        : InventoryColors.pageBackground,
                    borderRadius: BorderRadius.circular(12),
                    child: CheckboxListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      value: selected,
                      onChanged: (_) => cubit.toggleProductSelection(p.id),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        title,
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: InventoryColors.primaryNavy,
                        ),
                      ),
                      subtitle: p.sku.isNotEmpty
                          ? Text(
                              p.sku,
                              style: widget.theme.textTheme.bodySmall?.copyWith(
                                color: InventoryColors.subtitleGrey,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            )
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
          child: InventoryGradientActionButton(
            label: 'inventory_done'.tr(),
            icon: Icons.check_rounded,
            onPressed: () => Navigator.pop(widget.sheetContext),
          ),
        ),
      ],
    );
  }
}

class _SelectedProductsList extends StatelessWidget {
  const _SelectedProductsList({
    required this.theme,
    required this.products,
    required this.quantities,
  });

  final ThemeData theme;
  final List<ProductOption> products;
  final Map<String, double> quantities;

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
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _CompactProductLineCard(
              key: ValueKey(p.id),
              product: p,
              quantity: quantities[p.id] ?? 1,
              theme: theme,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactProductLineCard extends StatefulWidget {
  const _CompactProductLineCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.theme,
  });

  final ProductOption product;
  final double quantity;
  final ThemeData theme;

  @override
  State<_CompactProductLineCard> createState() =>
      _CompactProductLineCardState();
}

class _CompactProductLineCardState extends State<_CompactProductLineCard> {
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: _formatQty(widget.quantity));
  }

  @override
  void didUpdateWidget(covariant _CompactProductLineCard oldWidget) {
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

  String _formatQty(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  double _parseQty(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return 0;
    return double.tryParse(normalized) ?? 0;
  }

  void _commitQuantity() {
    context.read<WarehouseTransferCreateCubit>().setProductQuantity(
          widget.product.id,
          _parseQty(_qtyController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.product.displayName ?? widget.product.name).trim();
    final cubit = context.read<WarehouseTransferCreateCubit>();

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
                  borderSide: BorderSide(
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
              onPressed: () => cubit.removeProduct(widget.product.id),
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

class _InlineProductsError extends StatelessWidget {
  const _InlineProductsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 36,
            color: InventoryColors.subtitleGrey.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: InventoryColors.primaryNavy,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text('inventory_retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _CreateErrorState extends StatelessWidget {
  const _CreateErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: InventoryColors.subtitleGrey.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: InventoryColors.primaryNavy,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text('inventory_retry'.tr()),
          ),
        ],
      ),
    );
  }
}
