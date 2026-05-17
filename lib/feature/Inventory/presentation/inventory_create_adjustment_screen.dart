import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/core/di/injection.dart';
import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/feature/Inventory/data/inventory_count_repository_impl.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_count_type.dart';
import 'package:looped_admin/feature/Inventory/presentation/cubit/inventory_count_cubit.dart';
import 'package:looped_admin/feature/Inventory/presentation/cubit/inventory_count_state.dart';
import 'package:looped_admin/feature/Inventory/presentation/inventory_adjustment_detail_screen.dart';
import 'package:looped_admin/feature/Inventory/widget/full_count_zero_stock_options.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_type_selector.dart';
import 'package:looped_admin/feature/Inventory/widget/searchable_warehouse_field.dart';
import 'package:looped_admin/feature/Inventory/widget/warehouse_summary_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: InventoryColors.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccountSettingsAppBar(
              onMenuTap: () => Navigator.of(context).maybePop(),
              onHelpTap: () {},
            ),
            Expanded(
              child: BlocBuilder<InventoryCountCubit, InventoryCountState>(
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _buildBody(context, theme, state),
                  );
                },
              ),
            ),
            BlocBuilder<InventoryCountCubit, InventoryCountState>(
              builder: (context, state) {
                return Material(
                  elevation: 12,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  color: InventoryColors.cardSurface,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      12 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            disabledBackgroundColor:
                                InventoryColors.borderSubtle,
                          ),
                          onPressed: state.canContinue &&
                                  !state.isSubmittingAdjustment
                              ? () => _onContinue(context)
                              : null,
                          child: state.isSubmittingAdjustment
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.6,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  'inventory_continue'.tr(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: state.canContinue &&
                                            !state.isSubmittingAdjustment
                                        ? Colors.white
                                        : InventoryColors.subtitleGrey,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    InventoryCountState state,
  ) {
    if (state.warehouseLoadStatus == WarehouseLoadStatus.loading &&
        state.warehouses.isEmpty) {
      return const Center(
        key: ValueKey('wh-loading'),
        child: CircularProgressIndicator(strokeWidth: 2.8),
      );
    }

    if (state.warehouseLoadStatus == WarehouseLoadStatus.failure &&
        state.warehouses.isEmpty) {
      return _CreateErrorState(
        key: const ValueKey('wh-error'),
        message: _warehouseError(state.warehouseErrorMessage),
        onRetry: () => context.read<InventoryCountCubit>().retryWarehouses(),
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('content'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'inventory_title'.tr(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: InventoryColors.primaryNavy,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'inventory_subtitle'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: InventoryColors.subtitleGrey,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'inventory_section_request_name'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: InventoryColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: state.requestName,
            onChanged: (value) =>
                context.read<InventoryCountCubit>().setRequestName(value),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'inventory_request_name_hint'.tr(),
              prefixIcon: const Icon(
                Icons.edit_note_outlined,
                color: InventoryColors.primaryNavy,
              ),
              filled: true,
              fillColor: InventoryColors.pageBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'inventory_section_warehouse'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: InventoryColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          SearchableWarehouseField(
            warehouses: state.warehouses,
            selected: state.selectedWarehouse,
            onSelected: (w) =>
                context.read<InventoryCountCubit>().selectWarehouse(w),
            enabled: state.isWarehouseReady,
            isLoading: state.isWarehouseLoading,
          ),
          if (state.warehouseLoadStatus == WarehouseLoadStatus.failure &&
              state.warehouses.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _warehouseError(state.warehouseErrorMessage),
              style: theme.textTheme.bodySmall?.copyWith(
                color: InventoryColors.dangerText,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  context.read<InventoryCountCubit>().retryWarehouses(),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text('inventory_retry'.tr()),
            ),
          ],
          if (state.selectedWarehouse != null) ...[
            const SizedBox(height: 14),
            WarehouseSummaryCard(warehouse: state.selectedWarehouse!),
          ],
          const SizedBox(height: 22),
          Text(
            'inventory_section_count_type'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: InventoryColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          InventoryTypeSelector(
            selected: state.selectedType,
            onChanged: (t) =>
                context.read<InventoryCountCubit>().selectCountType(t),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: state.selectedType == InventoryCountType.full
                ? Padding(
                    key: const ValueKey('full-zero-options'),
                    padding: const EdgeInsets.only(top: 18),
                    child: FullCountZeroStockOptions(
                      includeZeroQuantityProducts:
                          state.includeZeroQuantityInFullCount,
                      onChanged: context
                          .read<InventoryCountCubit>()
                          .setIncludeZeroQuantityInFullCount,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-full-zero')),
          ),
          if (state.selectedType == InventoryCountType.singleProduct) ...[
            const SizedBox(height: 22),
            Text(
              'inventory_section_manual_products'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: InventoryColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 10),
            _CreateManualProductPicker(theme: theme, state: state),
          ],
        ],
      ),
    );
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
      await Navigator.of(context).push<void>(
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
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.6),
        ),
      );
    }

    if (state.catalogStatus == InventoryCatalogStatus.failure) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _catalogErrorLabel(state.catalogErrorMessage),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: InventoryColors.dangerText,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton.icon(
            onPressed: cubit.retryInventoryCatalog,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text('inventory_retry'.tr()),
          ),
        ],
      );
    }

    if (state.catalogProducts.isEmpty) {
      return Text(
        'inventory_catalog_empty'.tr(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: InventoryColors.subtitleGrey,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final summary = _selectionSummary(state);
    final hasSelection = state.selectedManualProductIds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: InventoryColors.pageBackground,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _openManualProductSheet(context, cubit),
            child: InputDecorator(
              decoration: InputDecoration(
                filled: true,
                fillColor: InventoryColors.pageBackground,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: InventoryColors.primaryNavy,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              ),
              child: Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasSelection
                      ? InventoryColors.primaryNavy
                      : InventoryColors.subtitleGrey,
                ),
              ),
            ),
          ),
        ),
        if (!hasSelection)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'inventory_validation_manual_products'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: InventoryColors.subtitleGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  String _selectionSummary(InventoryCountState state) {
    if (state.selectedManualProductIds.isEmpty) {
      return 'inventory_manual_products_hint'.tr();
    }
    final selected = state.catalogProducts
        .where((p) => state.selectedManualProductIds.contains(p.id))
        .toList();
    if (selected.isEmpty) {
      return 'inventory_manual_products_hint'.tr();
    }
    if (selected.length == 1) {
      return (selected.single.displayName ?? selected.single.name).trim();
    }
    return 'inventory_manual_products_selected_count'.tr(
      namedArgs: {'count': '${selected.length}'},
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Text(
                      'inventory_section_manual_products'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: InventoryColors.primaryNavy,
                      ),
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<InventoryCountCubit, InventoryCountState>(
                      builder: (context, sheetState) {
                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          itemCount: sheetState.catalogProducts.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final p = sheetState.catalogProducts[index];
                            final selected =
                                sheetState.selectedManualProductIds.contains(p.id);
                            final title = (p.displayName ?? p.name).trim();
                            return Material(
                              color: InventoryColors.pageBackground,
                              borderRadius: BorderRadius.circular(14),
                              child: CheckboxListTile(
                                value: selected,
                                onChanged: (_) =>
                                    cubit.toggleManualProductSelection(p.id),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                title: Text(
                                  title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: InventoryColors.primaryNavy,
                                  ),
                                ),
                                subtitle: p.sku.isNotEmpty
                                    ? Text(
                                        p.sku,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: InventoryColors.subtitleGrey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : null,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text('inventory_done'.tr()),
                      ),
                    ),
                  ),
                ],
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

class _CreateErrorState extends StatelessWidget {
  const _CreateErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: InventoryColors.subtitleGrey.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: InventoryColors.primaryNavy,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('inventory_retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
