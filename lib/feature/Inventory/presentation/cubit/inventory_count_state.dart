import 'package:equatable/equatable.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_count_type.dart';
import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/feature/Inventory/domain/warehouse_option.dart';

enum WarehouseLoadStatus { initial, loading, success, failure }

enum ProductLoadStatus { idle, loading, success, failure }

enum InventoryCatalogStatus { idle, loading, success, failure }

enum AdjustmentSubmitStatus { idle, loading, success, failure }

class InventoryCountState extends Equatable {
  const InventoryCountState({
    this.warehouseLoadStatus = WarehouseLoadStatus.initial,
    this.warehouses = const [],
    this.warehouseErrorMessage,
    this.selectedWarehouse,
    this.selectedType,
    this.productLoadStatus = ProductLoadStatus.idle,
    this.products = const [],
    this.productErrorMessage,
    this.selectedProduct,
    this.productSearchQuery = '',
    this.barcodeLookupInProgress = false,
    this.includeZeroQuantityInFullCount = false,
    this.requestName = '',
    this.adjustmentSubmitStatus = AdjustmentSubmitStatus.idle,
    this.adjustmentErrorMessage,
    this.catalogStatus = InventoryCatalogStatus.idle,
    this.catalogProducts = const [],
    this.catalogErrorMessage,
    this.selectedManualProductIds = const <String>{},
  });

  final WarehouseLoadStatus warehouseLoadStatus;
  final List<WarehouseOption> warehouses;
  final String? warehouseErrorMessage;
  final WarehouseOption? selectedWarehouse;
  final InventoryCountType? selectedType;
  final ProductLoadStatus productLoadStatus;
  final List<ProductOption> products;
  final String? productErrorMessage;
  final ProductOption? selectedProduct;
  final String productSearchQuery;
  final bool barcodeLookupInProgress;

  /// Used only when [selectedType] is [InventoryCountType.full].
  /// `true` = API should return / count lines with zero on-hand quantity.
  final bool includeZeroQuantityInFullCount;

  /// User-defined label for this count request (sent to API when wired).
  final String requestName;

  final AdjustmentSubmitStatus adjustmentSubmitStatus;
  final String? adjustmentErrorMessage;

  final InventoryCatalogStatus catalogStatus;
  final List<ProductOption> catalogProducts;
  final String? catalogErrorMessage;
  final Set<String> selectedManualProductIds;

  bool get isSubmittingAdjustment =>
      adjustmentSubmitStatus == AdjustmentSubmitStatus.loading;

  bool get isWarehouseLoading =>
      warehouseLoadStatus == WarehouseLoadStatus.loading;

  bool get isWarehouseReady =>
      warehouseLoadStatus == WarehouseLoadStatus.success;

  bool get isProductLoading =>
      productLoadStatus == ProductLoadStatus.loading ||
      barcodeLookupInProgress;

  bool get isCatalogLoading =>
      catalogStatus == InventoryCatalogStatus.loading;

  bool get canContinue {
    if (selectedWarehouse == null || selectedType == null) return false;
    if (requestName.trim().isEmpty) return false;
    if (selectedType == InventoryCountType.singleProduct) {
      return selectedManualProductIds.isNotEmpty;
    }
    return true;
  }

  InventoryCountState copyWith({
    WarehouseLoadStatus? warehouseLoadStatus,
    List<WarehouseOption>? warehouses,
    String? warehouseErrorMessage,
    bool clearWarehouseError = false,
    WarehouseOption? selectedWarehouse,
    bool clearSelectedWarehouse = false,
    InventoryCountType? selectedType,
    bool clearSelectedType = false,
    ProductLoadStatus? productLoadStatus,
    List<ProductOption>? products,
    String? productErrorMessage,
    bool clearProductError = false,
    ProductOption? selectedProduct,
    bool clearSelectedProduct = false,
    String? productSearchQuery,
    bool? barcodeLookupInProgress,
    bool? includeZeroQuantityInFullCount,
    String? requestName,
    AdjustmentSubmitStatus? adjustmentSubmitStatus,
    String? adjustmentErrorMessage,
    bool clearAdjustmentError = false,
    InventoryCatalogStatus? catalogStatus,
    List<ProductOption>? catalogProducts,
    String? catalogErrorMessage,
    bool clearCatalogError = false,
    Set<String>? selectedManualProductIds,
    bool clearManualProductSelection = false,
  }) {
    return InventoryCountState(
      warehouseLoadStatus: warehouseLoadStatus ?? this.warehouseLoadStatus,
      warehouses: warehouses ?? this.warehouses,
      warehouseErrorMessage: clearWarehouseError
          ? null
          : (warehouseErrorMessage ?? this.warehouseErrorMessage),
      selectedWarehouse: clearSelectedWarehouse
          ? null
          : (selectedWarehouse ?? this.selectedWarehouse),
      selectedType: clearSelectedType ? null : (selectedType ?? this.selectedType),
      productLoadStatus: productLoadStatus ?? this.productLoadStatus,
      products: products ?? this.products,
      productErrorMessage: clearProductError
          ? null
          : (productErrorMessage ?? this.productErrorMessage),
      selectedProduct: clearSelectedProduct
          ? null
          : (selectedProduct ?? this.selectedProduct),
      productSearchQuery: productSearchQuery ?? this.productSearchQuery,
      barcodeLookupInProgress:
          barcodeLookupInProgress ?? this.barcodeLookupInProgress,
      includeZeroQuantityInFullCount:
          includeZeroQuantityInFullCount ?? this.includeZeroQuantityInFullCount,
      requestName: requestName ?? this.requestName,
      adjustmentSubmitStatus:
          adjustmentSubmitStatus ?? this.adjustmentSubmitStatus,
      adjustmentErrorMessage: clearAdjustmentError
          ? null
          : (adjustmentErrorMessage ?? this.adjustmentErrorMessage),
      catalogStatus: catalogStatus ?? this.catalogStatus,
      catalogProducts: catalogProducts ?? this.catalogProducts,
      catalogErrorMessage: clearCatalogError
          ? null
          : (catalogErrorMessage ?? this.catalogErrorMessage),
      selectedManualProductIds: clearManualProductSelection
          ? const <String>{}
          : (selectedManualProductIds ?? this.selectedManualProductIds),
    );
  }

  @override
  List<Object?> get props => [
        warehouseLoadStatus,
        warehouses,
        warehouseErrorMessage,
        selectedWarehouse,
        selectedType,
        productLoadStatus,
        products,
        productErrorMessage,
        selectedProduct,
        productSearchQuery,
        barcodeLookupInProgress,
        includeZeroQuantityInFullCount,
        requestName,
        adjustmentSubmitStatus,
        adjustmentErrorMessage,
        catalogStatus,
        catalogProducts,
        catalogErrorMessage,
        selectedManualProductIds,
      ];
}
