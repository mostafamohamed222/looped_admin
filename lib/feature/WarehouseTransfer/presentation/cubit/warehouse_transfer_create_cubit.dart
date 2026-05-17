import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_create_request_result.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_location_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_warehouse_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/warehouse_transfer_repository.dart';
import 'package:looped_admin/feature/WarehouseTransfer/presentation/cubit/warehouse_transfer_create_state.dart';

class WarehouseTransferCreateCubit extends Cubit<WarehouseTransferCreateState> {
  WarehouseTransferCreateCubit({required WarehouseTransferRepository repository})
      : _repository = repository,
        super(const WarehouseTransferCreateState());

  final WarehouseTransferRepository _repository;

  Future<void> loadWarehouses() async {
    emit(
      state.copyWith(
        warehouseLoadStatus: TransferWarehouseLoadStatus.loading,
        clearWarehouseError: true,
      ),
    );
    try {
      final list = await _repository.fetchStockWarehouses();
      emit(
        state.copyWith(
          warehouseLoadStatus: TransferWarehouseLoadStatus.success,
          warehouses: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          warehouseLoadStatus: TransferWarehouseLoadStatus.failure,
          warehouseErrorMessage: e.toString(),
        ),
      );
    }
  }

  void retryWarehouses() => loadWarehouses();

  Future<void> selectWarehouse(StockWarehouseOption warehouse) async {
    emit(
      state.copyWith(
        selectedWarehouse: warehouse,
        clearSelectedLocation: true,
        locationLoadStatus: TransferLocationLoadStatus.loading,
        locations: const [],
        clearLocationError: true,
        productsLoadStatus: TransferProductsLoadStatus.idle,
        catalogProducts: const [],
        clearProductsError: true,
        clearProductQuantities: true,
        submitStatus: TransferSubmitStatus.idle,
        clearSubmitError: true,
      ),
    );
    await _loadLocations(warehouse.id);
  }

  Future<void> _loadLocations(int warehouseId) async {
    try {
      final list =
          await _repository.fetchStockLocations(warehouseId: warehouseId);
      emit(
        state.copyWith(
          locationLoadStatus: TransferLocationLoadStatus.success,
          locations: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          locationLoadStatus: TransferLocationLoadStatus.failure,
          locationErrorMessage: e.toString(),
        ),
      );
    }
  }

  void retryLocations() {
    final wh = state.selectedWarehouse;
    if (wh == null) return;
    emit(
      state.copyWith(
        locationLoadStatus: TransferLocationLoadStatus.loading,
        clearLocationError: true,
        clearSelectedLocation: true,
        productsLoadStatus: TransferProductsLoadStatus.idle,
        catalogProducts: const [],
        clearProductQuantities: true,
        submitStatus: TransferSubmitStatus.idle,
        clearSubmitError: true,
      ),
    );
    _loadLocations(wh.id);
  }

  Future<void> selectLocation(StockLocationOption location) async {
    emit(
      state.copyWith(
        selectedLocation: location,
        clearProductQuantities: true,
        submitStatus: TransferSubmitStatus.idle,
        clearSubmitError: true,
      ),
    );
    if (state.productsLoadStatus == TransferProductsLoadStatus.success &&
        state.catalogProducts.isNotEmpty) {
      return;
    }
    await loadProducts();
  }

  Future<void> loadProducts() async {
    emit(
      state.copyWith(
        productsLoadStatus: TransferProductsLoadStatus.loading,
        clearProductsError: true,
      ),
    );
    try {
      final list = await _repository.fetchProductsCatalog();
      emit(
        state.copyWith(
          productsLoadStatus: TransferProductsLoadStatus.success,
          catalogProducts: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          productsLoadStatus: TransferProductsLoadStatus.failure,
          productsErrorMessage: e.toString(),
        ),
      );
    }
  }

  void retryProducts() => loadProducts();

  void toggleProductSelection(String productId) {
    final next = Map<String, double>.from(state.productQuantities);
    if (next.containsKey(productId)) {
      next.remove(productId);
    } else {
      next[productId] = 1;
    }
    emit(
      state.copyWith(
        productQuantities: next,
        submitStatus: TransferSubmitStatus.idle,
        clearSubmitError: true,
      ),
    );
  }

  void removeProduct(String productId) {
    if (!state.productQuantities.containsKey(productId)) return;
    final next = Map<String, double>.from(state.productQuantities)
      ..remove(productId);
    emit(
      state.copyWith(
        productQuantities: next,
        submitStatus: TransferSubmitStatus.idle,
        clearSubmitError: true,
      ),
    );
  }

  void setProductQuantity(String productId, double quantity) {
    if (!state.productQuantities.containsKey(productId)) return;
    final clamped = quantity < 0 ? 0.0 : quantity;
    emit(
      state.copyWith(
        productQuantities: {
          ...state.productQuantities,
          productId: clamped,
        },
        submitStatus: TransferSubmitStatus.idle,
        clearSubmitError: true,
      ),
    );
  }

  List<Map<String, dynamic>> _buildItemsPayload() {
    final items = <Map<String, dynamic>>[];
    for (final product in state.catalogProducts) {
      final qty = state.productQuantities[product.id];
      if (qty == null || qty <= 0) continue;
      items.add(<String, dynamic>{
        'product_id': product.odooProductId,
        'quantity': qty,
      });
    }
    return items;
  }

  /// Returns created request on success; `null` if validation blocked or failed.
  Future<StockCreateRequestResult?> submitRequest() async {
    if (!state.canSubmit) return null;
    emit(
      state.copyWith(
        submitStatus: TransferSubmitStatus.loading,
        clearSubmitError: true,
      ),
    );
    try {
      final wh = state.selectedWarehouse!;
      final loc = state.selectedLocation!;
      final created = await _repository.createRequest(
        warehouseId: wh.id,
        locationId: loc.id,
        items: _buildItemsPayload(),
      );
      emit(state.copyWith(submitStatus: TransferSubmitStatus.success));
      return created;
    } catch (e) {
      emit(
        state.copyWith(
          submitStatus: TransferSubmitStatus.failure,
          submitErrorMessage: e.toString(),
        ),
      );
      return null;
    }
  }

  void clearSubmitFeedback() {
    emit(
      state.copyWith(
        submitStatus: TransferSubmitStatus.idle,
        clearSubmitError: true,
      ),
    );
  }
}
