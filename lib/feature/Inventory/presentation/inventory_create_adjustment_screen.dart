import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/core/di/injection.dart';
import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/feature/Inventory/data/inventory_count_repository_impl.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_count_type.dart';
import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/feature/Inventory/presentation/cubit/inventory_count_cubit.dart';
import 'package:looped_admin/feature/Inventory/presentation/cubit/inventory_count_state.dart';
import 'package:looped_admin/feature/Inventory/presentation/inventory_adjustment_detail_screen.dart';
import 'package:looped_admin/feature/Inventory/widget/full_count_zero_stock_options.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_gradient_action_button.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_type_selector.dart';
import 'package:looped_admin/feature/Inventory/widget/searchable_warehouse_field.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_app_bar.dart';

/// Create a new inventory adjustment (name, warehouse, count type, optional products).
class InventoryCreateAdjustmentScreen extends StatelessWidget {
  const InventoryCreateAdjustmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InventoryCountCubit(
        repository: InventoryCountRepositoryImpl(dio: getIt<DioConsumer>()),
      )..loadWarehouses()
        ..loadInventoryCatalog(),
      child: const _InventoryCreateAdjustmentView(),
    );
  }
}

class _InventoryCreateAdjustmentView extends StatelessWidget {
  const _InventoryCreateAdjustmentView();

  String _warehouseError(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.startsWith('inventory_')) return raw.tr();
    return 'inventory_warehouse_error'.tr();
  }

  String _adjustmentErrorMessage(String? raw) {
    if (raw == null || raw.isEmpty) return 'inventory_create_error'.tr();
    final trimmed = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (trimmed.startsWith('inventory_')) return trimmed.tr();
    return trimmed;
  }

  Future<void> _onContinue(BuildContext context) async {
    final cubit = context.read<InventoryCountCubit>();
    final created = await cubit.submitAdjustment();
    if (!context.mounted) return;
    final after = cubit.state;
    final messenger = ScaffoldMessenger.of(context);
    if (after.adjustmentSubmitStatus == AdjustmentSubmitStatus.success &&
        created != null) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => InventoryAdjustmentDetailScreen(
            result: created,
            repository: InventoryCountRepositoryImpl(
              dio: getIt<DioConsumer>(),
            ),
          ),
        ),
      );
      if (!context.mounted) return;
      cubit.clearAdjustmentSubmitFeedback();
    } else if (after.adjustmentSubmitStatus == AdjustmentSubmitStatus.success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('inventory_create_success'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      cubit.clearAdjustmentSubmitFeedback();
    } else if (after.adjustmentSubmitStatus == AdjustmentSubmitStatus.failure) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_adjustmentErrorMessage(after.adjustmentErrorMessage)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      cubit.clearAdjustmentSubmitFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InventoryColors.pageBackground,
      body: SafeArea(
        child: BlocBuilder<InventoryCountCubit, InventoryCountState>(
          builder: (context, state) {
            final showSubmitBar = state.warehouseLoadStatus !=
                    WarehouseLoadStatus.loading ||
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
                    onContinue: () => _onContinue(context),
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
    InventoryCountState state,
  ) {
    final theme = Theme.of(context);
    final cubit = context.read<InventoryCountCubit>();

    if (state.warehouseLoadStatus == WarehouseLoadStatus.loading &&
        state.warehouses.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2.8),
          ),
        ),
      ];
    }

    if (state.warehouseLoadStatus == WarehouseLoadStatus.failure &&
        state.warehouses.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CreateErrorState(
            message: _warehouseError(state.warehouseErrorMessage),
            onRetry: cubit.retryWarehouses,
          ),
        ),
      ];
    }

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
                title: 'inventory_section_request_name'.tr(),
                icon: Icons.edit_note_outlined,
                child: _CreateModernTextField(
                  initialValue: state.requestName,
                  hint: 'inventory_request_name_hint'.tr(),
                  icon: Icons.badge_outlined,
                  onChanged: cubit.setRequestName,
                ),
              ),
              const SizedBox(height: 14),
              _CreateStepCard(
                step: 2,
                title: 'inventory_section_warehouse'.tr(),
                icon: Icons.warehouse_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SearchableWarehouseField(
                      warehouses: state.warehouses,
                      selected: state.selectedWarehouse,
                      onSelected: cubit.selectWarehouse,
                      enabled: state.isWarehouseReady,
                      isLoading: state.isWarehouseLoading,
                      compact: true,
                    ),
                    if (state.warehouseLoadStatus == WarehouseLoadStatus.failure &&
                        state.warehouses.isNotEmpty)
                      _InlineRetryError(
                        message: _warehouseError(state.warehouseErrorMessage),
                        onRetry: cubit.retryWarehouses,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _CreateStepCard(
                step: 3,
                title: 'inventory_section_count_type'.tr(),
                icon: Icons.inventory_2_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InventoryTypeSelector(
                      selected: state.selectedType,
                      onChanged: cubit.selectCountType,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: state.selectedType == InventoryCountType.full
                          ? Padding(
                              key: const ValueKey('full-zero-options'),
                              padding: const EdgeInsets.only(top: 10),
                              child: FullCountZeroStockOptions(
                                includeZeroQuantityProducts:
                                    state.includeZeroQuantityInFullCount,
                                onChanged:
                                    cubit.setIncludeZeroQuantityInFullCount,
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('no-full-zero')),
                    ),
                    if (state.selectedType == InventoryCountType.singleProduct) ...[
                      const SizedBox(height: 10),
                      Text(
                        'inventory_section_manual_products'.tr(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: InventoryColors.subtitleGrey,
                          letterSpacing: 0.2,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _CreateManualProductPicker(theme: theme, state: state),
                    ],
                  ],
                ),
              ),
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
    required this.onContinue,
  });

  final InventoryCountState state;
  final VoidCallback onContinue;

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
          label: 'inventory_continue'.tr(),
          icon: Icons.check_rounded,
          onPressed: onContinue,
          enabled: state.canContinue,
          isLoading: state.isSubmittingAdjustment,
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
              Icons.inventory_2_outlined,
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
                  'inventory_title'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'inventory_subtitle'.tr(),
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
  });

  final int step;
  final String title;
  final IconData icon;
  final Widget child;

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

class _CreateModernTextField extends StatelessWidget {
  const _CreateModernTextField({
    required this.initialValue,
    required this.hint,
    required this.icon,
    required this.onChanged,
  });

  final String initialValue;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: InventoryColors.primaryNavy,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: InventoryColors.subtitleGrey,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, size: 20, color: InventoryColors.accentBlue),
        filled: true,
        fillColor: InventoryColors.pageBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: InventoryColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: InventoryColors.accentBlue,
            width: 1.4,
          ),
        ),
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

class _CreateManualProductPicker extends StatelessWidget {
  const _CreateManualProductPicker({
    required this.theme,
    required this.state,
  });

  final ThemeData theme;
  final InventoryCountState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InventoryCountCubit>();

    if (state.catalogStatus == InventoryCatalogStatus.loading &&
        state.catalogProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.6),
        ),
      );
    }

    if (state.catalogStatus == InventoryCatalogStatus.failure) {
      return _InlineRetryError(
        message: _catalogErrorLabel(state.catalogErrorMessage),
        onRetry: cubit.retryInventoryCatalog,
      );
    }

    if (state.catalogProducts.isEmpty) {
      return Text(
        'inventory_catalog_empty'.tr(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: InventoryColors.subtitleGrey,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final summary = _selectionSummary(state);
    final hasSelection = state.selectedManualProductIds.isNotEmpty;
    final selectedProducts = state.catalogProducts
        .where((p) => state.selectedManualProductIds.contains(p.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: hasSelection
              ? InventoryColors.accentBlueSoft
              : InventoryColors.pageBackground,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openManualProductSheet(context, cubit),
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
                      summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
        ),
        if (hasSelection) ...[
          const SizedBox(height: 14),
          _SelectedManualProductsList(
            theme: theme,
            products: selectedProducts,
            onRemove: cubit.toggleManualProductSelection,
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: InventoryColors.subtitleGrey.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'inventory_validation_manual_products'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: InventoryColors.subtitleGrey,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _selectionSummary(InventoryCountState state) {
    if (state.selectedManualProductIds.isEmpty) {
      return 'inventory_manual_products_hint'.tr();
    }
    return 'inventory_manual_products_selected_count'.tr(
      namedArgs: {'count': '${state.selectedManualProductIds.length}'},
    );
  }

  Future<void> _openManualProductSheet(
    BuildContext context,
    InventoryCountCubit cubit,
  ) {
    return showModalBottomSheet<void>(
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
              return _CreateManualProductsPickerSheet(
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

  String _catalogErrorLabel(String? raw) {
    if (raw == null || raw.isEmpty) return 'inventory_catalog_error'.tr();
    final trimmed = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (trimmed.startsWith('inventory_')) return trimmed.tr();
    return trimmed;
  }
}

class _SelectedManualProductsList extends StatelessWidget {
  const _SelectedManualProductsList({
    required this.theme,
    required this.products,
    required this.onRemove,
  });

  final ThemeData theme;
  final List<ProductOption> products;
  final ValueChanged<String> onRemove;

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
            child: _SelectedManualProductLine(
              product: p,
              theme: theme,
              onRemove: () => onRemove(p.id),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedManualProductLine extends StatelessWidget {
  const _SelectedManualProductLine({
    required this.product,
    required this.theme,
    required this.onRemove,
  });

  final ProductOption product;
  final ThemeData theme;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final title = (product.displayName ?? product.name).trim();

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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: InventoryColors.primaryNavy,
                    height: 1.2,
                  ),
                ),
                if (product.sku.isNotEmpty)
                  Text(
                    product.sku,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: InventoryColors.subtitleGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'transfer_remove_product'.tr(),
              onPressed: onRemove,
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

class _CreateManualProductsPickerSheet extends StatefulWidget {
  const _CreateManualProductsPickerSheet({
    required this.theme,
    required this.scrollController,
    required this.sheetContext,
  });

  final ThemeData theme;
  final ScrollController scrollController;
  final BuildContext sheetContext;

  @override
  State<_CreateManualProductsPickerSheet> createState() =>
      _CreateManualProductsPickerSheetState();
}

class _CreateManualProductsPickerSheetState
    extends State<_CreateManualProductsPickerSheet> {
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
    final cubit = context.read<InventoryCountCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            'inventory_section_manual_products'.tr(),
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
          child: BlocBuilder<InventoryCountCubit, InventoryCountState>(
            builder: (context, sheetState) {
              if (sheetState.catalogProducts.isEmpty) {
                return Center(
                  child: Text(
                    'inventory_catalog_empty'.tr(),
                    style: widget.theme.textTheme.bodyLarge?.copyWith(
                      color: InventoryColors.subtitleGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              final filtered =
                  sheetState.catalogProducts.where(_matchesSearch).toList();
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
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  final selected =
                      sheetState.selectedManualProductIds.contains(p.id);
                  final title = (p.displayName ?? p.name).trim();
                  return _ProductPickerTile(
                    title: title,
                    sku: p.sku,
                    selected: selected,
                    onTap: () => cubit.toggleManualProductSelection(p.id),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: InventoryGradientActionButton(
              label: 'inventory_done'.tr(),
              icon: Icons.check_rounded,
              onPressed: () => Navigator.of(widget.sheetContext).pop(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductPickerTile extends StatelessWidget {
  const _ProductPickerTile({
    required this.title,
    required this.sku,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String sku;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? InventoryColors.accentBlueSoft
          : InventoryColors.pageBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? InventoryColors.accentBlue.withValues(alpha: 0.4)
                  : InventoryColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected
                      ? InventoryColors.cardSurface
                      : InventoryColors.tonalIconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: selected
                      ? InventoryColors.accentBlue
                      : InventoryColors.subtitleGrey,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: InventoryColors.primaryNavy,
                        height: 1.2,
                      ),
                    ),
                    if (sku.isNotEmpty)
                      Text(
                        sku,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: selected
                    ? InventoryColors.accentBlue
                    : InventoryColors.subtitleGrey.withValues(alpha: 0.6),
                size: 24,
              ),
            ],
          ),
        ),
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
