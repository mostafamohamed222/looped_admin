import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_adjustment_result.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_count_repository.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_count_type.dart';
import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/feature/Inventory/domain/warehouse_option.dart';
import 'package:looped_admin/feature/Inventory/presentation/cubit/inventory_count_state.dart';

class InventoryCountCubit extends Cubit<InventoryCountState> {
  InventoryCountCubit({required InventoryCountRepository repository})
      : _repository = repository,
        super(const InventoryCountState());

  final InventoryCountRepository _repository;

  Future<void> loadWarehouses() async {
    emit(
      state.copyWith(
        warehouseLoadStatus: WarehouseLoadStatus.loading,
        clearWarehouseError: true,
      ),
    );
    try {
      final list = await _repository.fetchWarehouses();
      emit(
        state.copyWith(
          warehouseLoadStatus: WarehouseLoadStatus.success,
          warehouses: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          warehouseLoadStatus: WarehouseLoadStatus.failure,
          warehouseErrorMessage: e.toString(),
        ),
      );
    }
  }

  void selectWarehouse(WarehouseOption? warehouse) {
    emit(
      state.copyWith(
        selectedWarehouse: warehouse,
        clearSelectedWarehouse: warehouse == null,
        clearSelectedProduct: true,
        productLoadStatus: ProductLoadStatus.idle,
        products: const [],
        clearProductError: true,
        productSearchQuery: '',
        adjustmentSubmitStatus: AdjustmentSubmitStatus.idle,
        clearAdjustmentError: true,
        clearManualProductSelection: true,
      ),
    );
  }

  void selectCountType(InventoryCountType type) {
    emit(
      state.copyWith(
        selectedType: type,
        clearSelectedProduct: true,
        productLoadStatus: ProductLoadStatus.idle,
        products: const [],
        clearProductError: true,
        productSearchQuery: '',
        includeZeroQuantityInFullCount:
            type == InventoryCountType.full
                ? state.includeZeroQuantityInFullCount
                : false,
        adjustmentSubmitStatus: AdjustmentSubmitStatus.idle,
        clearAdjustmentError: true,
        clearManualProductSelection: type == InventoryCountType.full,
      ),
    );
  }

  Future<void> loadInventoryCatalog() async {
    emit(
      state.copyWith(
        catalogStatus: InventoryCatalogStatus.loading,
        clearCatalogError: true,
      ),
    );
    try {
      final list = await _repository.fetchInventoryCatalog();
      emit(
        state.copyWith(
          catalogStatus: InventoryCatalogStatus.success,
          catalogProducts: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          catalogStatus: InventoryCatalogStatus.failure,
          catalogErrorMessage: e.toString(),
        ),
      );
    }
  }

  void retryInventoryCatalog() => loadInventoryCatalog();

  void toggleManualProductSelection(String productId) {
    final next = {...state.selectedManualProductIds};
    if (next.contains(productId)) {
      next.remove(productId);
    } else {
      next.add(productId);
    }
    emit(
      state.copyWith(
        selectedManualProductIds: next,
        adjustmentSubmitStatus: AdjustmentSubmitStatus.idle,
        clearAdjustmentError: true,
      ),
    );
  }

  Future<void> loadProducts({String? query}) async {
    final wh = state.selectedWarehouse;
    if (wh == null) return;

    emit(
      state.copyWith(
        productLoadStatus: ProductLoadStatus.loading,
        clearProductError: true,
        productSearchQuery: query ?? state.productSearchQuery,
      ),
    );
    try {
      final list = await _repository.fetchProducts(
        warehouseId: wh.id.toString(),
        query: query ?? state.productSearchQuery,
      );
      emit(
        state.copyWith(
          productLoadStatus: ProductLoadStatus.success,
          products: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          productLoadStatus: ProductLoadStatus.failure,
          productErrorMessage: e.toString(),
        ),
      );
    }
  }

  void setProductSearchQuery(String q) {
    emit(state.copyWith(productSearchQuery: q));
  }

  void selectProduct(ProductOption? product) {
    emit(
      state.copyWith(
        selectedProduct: product,
        clearSelectedProduct: product == null,
      ),
    );
  }

  Future<void> onBarcodeScanned(String raw) async {
    final wh = state.selectedWarehouse;
    if (wh == null) return;

    emit(state.copyWith(barcodeLookupInProgress: true, clearProductError: true));
    try {
      final found = await _repository.lookupProductByBarcode(
        warehouseId: wh.id.toString(),
        barcode: raw,
      );
      if (found != null) {
        emit(
          state.copyWith(
            barcodeLookupInProgress: false,
            selectedProduct: found,
            productSearchQuery: found.name,
            clearProductError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            barcodeLookupInProgress: false,
            clearSelectedProduct: true,
            productErrorMessage: 'inventory_barcode_not_found',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          barcodeLookupInProgress: false,
          productErrorMessage: e.toString(),
        ),
      );
    }
  }

  void retryWarehouses() => loadWarehouses();

  void retryProducts() => loadProducts();

  /// Pass through to API as `include_zero_quantity` (or your backend flag).
  void setIncludeZeroQuantityInFullCount(bool value) {
    emit(
      state.copyWith(
        includeZeroQuantityInFullCount: value,
        adjustmentSubmitStatus: AdjustmentSubmitStatus.idle,
        clearAdjustmentError: true,
      ),
    );
  }

  void setRequestName(String value) {
    emit(
      state.copyWith(
        requestName: value,
        adjustmentSubmitStatus: AdjustmentSubmitStatus.idle,
        clearAdjustmentError: true,
      ),
    );
  }

  /// Returns parsed adjustment payload on success; `null` if validation blocked or request failed.
  Future<InventoryAdjustmentResult?> submitAdjustment() async {
    if (!state.canContinue || state.isSubmittingAdjustment) return null;
    emit(
      state.copyWith(
        adjustmentSubmitStatus: AdjustmentSubmitStatus.loading,
        clearAdjustmentError: true,
      ),
    );
    try {
      final wh = state.selectedWarehouse!;
      final isFull = state.selectedType == InventoryCountType.full;
      final manualLines = isFull
          ? null
          : state.catalogProducts
              .where((p) => state.selectedManualProductIds.contains(p.id))
              .map(
                (p) => <String, dynamic>{
                  'product_id': p.odooProductId,
                },
              )
              .toList();
      final created = await _repository.createAdjustment(
        locationId: wh.id,
        inventoryReference: state.requestName.trim(),
        isFullCount: isFull,
        exhausted: state.includeZeroQuantityInFullCount,
        manualLines: manualLines,
      );
      emit(state.copyWith(adjustmentSubmitStatus: AdjustmentSubmitStatus.success));
      return created;
    } catch (e) {
      emit(
        state.copyWith(
          adjustmentSubmitStatus: AdjustmentSubmitStatus.failure,
          adjustmentErrorMessage: e.toString(),
        ),
      );
      return null;
    }
  }

  void clearAdjustmentSubmitFeedback() {
    emit(
      state.copyWith(
        adjustmentSubmitStatus: AdjustmentSubmitStatus.idle,
        clearAdjustmentError: true,
      ),
    );
  }
}
