import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_count_type.dart';
import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/feature/Inventory/presentation/cubit/inventory_count_cubit.dart';
import 'package:looped_admin/feature/Inventory/presentation/cubit/inventory_count_state.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_barcode_scanner_screen.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';

/// Product search, barcode entry point, and catalog picker for single-product flow.
class ProductCountSection extends StatefulWidget {
  const ProductCountSection({super.key});

  @override
  State<ProductCountSection> createState() => _ProductCountSectionState();
}

class _ProductCountSectionState extends State<ProductCountSection> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(InventoryCountCubit cubit, String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      cubit.loadProducts(query: value);
    });
  }

  Future<void> _openBarcodeSheet(BuildContext context) async {
    final cubit = context.read<InventoryCountCubit>();
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const InventoryBarcodeScannerScreen(),
      ),
    );
    if (code != null && code.trim().isNotEmpty) {
      await cubit.onBarcodeScanned(code.trim());
    }
  }

  String _formatError(String? message) {
    if (message == null || message.isEmpty) return '';
    if (message.startsWith('inventory_')) return message.tr();
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<InventoryCountCubit, InventoryCountState>(
      listenWhen: (p, c) =>
          p.selectedProduct?.id != c.selectedProduct?.id ||
          p.productSearchQuery != c.productSearchQuery,
      listener: (context, state) {
        if (state.selectedType != InventoryCountType.singleProduct) {
          if (_searchController.text.isNotEmpty) {
            _searchController.clear();
          }
          return;
        }
        final p = state.selectedProduct;
        if (p != null && _searchController.text != p.name) {
          _searchController.text = p.name;
        }
      },
      builder: (context, state) {
        final cubit = context.read<InventoryCountCubit>();
        final visible = state.selectedType == InventoryCountType.singleProduct;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: !visible
              ? const SizedBox.shrink(key: ValueKey('hidden'))
              : Column(
                  key: const ValueKey('visible'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'inventory_section_product'.tr(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: InventoryColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => _onSearchChanged(cubit, v),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (v) => cubit.loadProducts(query: v),
                            decoration: InputDecoration(
                              hintText: 'inventory_product_search_hint'.tr(),
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
                        const SizedBox(width: 10),
                        Semantics(
                          button: true,
                          label: 'inventory_product_scan'.tr(),
                          child: Material(
                            color: InventoryColors.accentBlue,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: state.barcodeLookupInProgress
                                  ? null
                                  : () => _openBarcodeSheet(context),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: state.barcodeLookupInProgress
                                    ? const Padding(
                                        padding: EdgeInsets.all(14),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.6,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.qr_code_scanner_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (state.selectedProduct != null) ...[
                      const SizedBox(height: 12),
                      _SelectedProductChip(
                        product: state.selectedProduct!,
                        onClear: () {
                          _searchController.clear();
                          cubit.selectProduct(null);
                          cubit.loadProducts(query: '');
                        },
                      ),
                    ],
                    if (state.productErrorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _formatError(state.productErrorMessage),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: InventoryColors.dangerText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (state.productLoadStatus == ProductLoadStatus.loading &&
                        state.products.isEmpty) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.6),
                      ),
                    ],
                    if (state.productLoadStatus == ProductLoadStatus.success &&
                        state.products.isEmpty &&
                        state.productSearchQuery.isEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'inventory_product_empty'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _SelectedProductChip extends StatelessWidget {
  const _SelectedProductChip({
    required this.product,
    required this.onClear,
  });

  final ProductOption product;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: InventoryColors.successTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: InventoryColors.successBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: InventoryColors.successText),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: InventoryColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.sku,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: InventoryColors.subtitleGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
            ),
          ],
        ),
      ),
    );
  }
}
