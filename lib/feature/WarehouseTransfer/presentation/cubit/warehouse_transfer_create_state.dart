import 'package:equatable/equatable.dart';
import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_location_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_warehouse_option.dart';

enum TransferWarehouseLoadStatus { initial, loading, success, failure }

enum TransferLocationLoadStatus { idle, loading, success, failure }

enum TransferProductsLoadStatus { idle, loading, success, failure }

enum TransferSubmitStatus { idle, loading, success, failure }

class WarehouseTransferCreateState extends Equatable {
  const WarehouseTransferCreateState({
    this.warehouseLoadStatus = TransferWarehouseLoadStatus.initial,
    this.warehouses = const [],
    this.warehouseErrorMessage,
    this.selectedWarehouse,
    this.locationLoadStatus = TransferLocationLoadStatus.idle,
    this.locations = const [],
    this.locationErrorMessage,
    this.selectedLocation,
    this.productsLoadStatus = TransferProductsLoadStatus.idle,
    this.catalogProducts = const [],
    this.productsErrorMessage,
    this.productQuantities = const <String, double>{},
    this.submitStatus = TransferSubmitStatus.idle,
    this.submitErrorMessage,
  });

  final TransferWarehouseLoadStatus warehouseLoadStatus;
  final List<StockWarehouseOption> warehouses;
  final String? warehouseErrorMessage;
  final StockWarehouseOption? selectedWarehouse;

  final TransferLocationLoadStatus locationLoadStatus;
  final List<StockLocationOption> locations;
  final String? locationErrorMessage;
  final StockLocationOption? selectedLocation;

  final TransferProductsLoadStatus productsLoadStatus;
  final List<ProductOption> catalogProducts;
  final String? productsErrorMessage;
  /// Selected product id → requested quantity.
  final Map<String, double> productQuantities;

  final TransferSubmitStatus submitStatus;
  final String? submitErrorMessage;

  Set<String> get selectedProductIds => productQuantities.keys.toSet();

  List<ProductOption> selectedProductsInOrder(List<ProductOption> catalog) {
    return catalog.where((p) => productQuantities.containsKey(p.id)).toList();
  }

  bool get isWarehouseLoading =>
      warehouseLoadStatus == TransferWarehouseLoadStatus.loading;

  bool get isLocationLoading =>
      locationLoadStatus == TransferLocationLoadStatus.loading;

  bool get isProductsLoading =>
      productsLoadStatus == TransferProductsLoadStatus.loading;

  bool get canPickLocation => selectedWarehouse != null;

  bool get canPickProducts =>
      selectedWarehouse != null && selectedLocation != null;

  bool get isSubmitting => submitStatus == TransferSubmitStatus.loading;

  bool get hasValidLineItems => productQuantities.entries.any(
        (e) => e.value > 0,
      );

  bool get canSubmit =>
      selectedWarehouse != null &&
      selectedLocation != null &&
      hasValidLineItems &&
      !isSubmitting;

  WarehouseTransferCreateState copyWith({
    TransferWarehouseLoadStatus? warehouseLoadStatus,
    List<StockWarehouseOption>? warehouses,
    String? warehouseErrorMessage,
    bool clearWarehouseError = false,
    StockWarehouseOption? selectedWarehouse,
    bool clearSelectedWarehouse = false,
    TransferLocationLoadStatus? locationLoadStatus,
    List<StockLocationOption>? locations,
    String? locationErrorMessage,
    bool clearLocationError = false,
    StockLocationOption? selectedLocation,
    bool clearSelectedLocation = false,
    TransferProductsLoadStatus? productsLoadStatus,
    List<ProductOption>? catalogProducts,
    String? productsErrorMessage,
    bool clearProductsError = false,
    Map<String, double>? productQuantities,
    bool clearProductQuantities = false,
    TransferSubmitStatus? submitStatus,
    String? submitErrorMessage,
    bool clearSubmitError = false,
  }) {
    return WarehouseTransferCreateState(
      warehouseLoadStatus:
          warehouseLoadStatus ?? this.warehouseLoadStatus,
      warehouses: warehouses ?? this.warehouses,
      warehouseErrorMessage: clearWarehouseError
          ? null
          : (warehouseErrorMessage ?? this.warehouseErrorMessage),
      selectedWarehouse: clearSelectedWarehouse
          ? null
          : (selectedWarehouse ?? this.selectedWarehouse),
      locationLoadStatus: locationLoadStatus ?? this.locationLoadStatus,
      locations: locations ?? this.locations,
      locationErrorMessage: clearLocationError
          ? null
          : (locationErrorMessage ?? this.locationErrorMessage),
      selectedLocation: clearSelectedLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
      productsLoadStatus: productsLoadStatus ?? this.productsLoadStatus,
      catalogProducts: catalogProducts ?? this.catalogProducts,
      productsErrorMessage: clearProductsError
          ? null
          : (productsErrorMessage ?? this.productsErrorMessage),
      productQuantities: clearProductQuantities
          ? const <String, double>{}
          : (productQuantities ?? this.productQuantities),
      submitStatus: submitStatus ?? this.submitStatus,
      submitErrorMessage: clearSubmitError
          ? null
          : (submitErrorMessage ?? this.submitErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        warehouseLoadStatus,
        warehouses,
        warehouseErrorMessage,
        selectedWarehouse,
        locationLoadStatus,
        locations,
        locationErrorMessage,
        selectedLocation,
        productsLoadStatus,
        catalogProducts,
        productsErrorMessage,
        productQuantities,
        submitStatus,
        submitErrorMessage,
      ];
}
