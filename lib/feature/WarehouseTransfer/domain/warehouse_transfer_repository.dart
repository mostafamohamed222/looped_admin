import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_create_request_result.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_location_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_detail.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_summary.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_route_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_warehouse_option.dart';

abstract class WarehouseTransferRepository {
  /// Warehouse transfer / stock requests (`get_all_requests`).
  Future<List<StockRequestSummary>> fetchAllRequests();

  /// Single request with lines (`get_request_details`).
  Future<StockRequestDetail> fetchRequestDetails({required int requestOrderId});

  /// Warehouses for create flow (`get_warehouses`).
  Future<List<StockWarehouseOption>> fetchStockWarehouses();

  /// Locations for a warehouse (`get_locations`).
  Future<List<StockLocationOption>> fetchStockLocations({
    required int warehouseId,
  });

  /// Product catalog (`get_products`, shared with inventory).
  Future<List<ProductOption>> fetchProductsCatalog();

  /// Create stock transfer request (`create_request`).
  Future<StockCreateRequestResult> createRequest({
    required int warehouseId,
    required int locationId,
    required List<Map<String, dynamic>> items,
  });

  /// Submit a draft request (`submit_request`).
  Future<void> submitRequest({required int requestOrderId});

  /// Add product lines to a draft request (`add_request_lines`).
  Future<void> addRequestLines({
    required int requestOrderId,
    required List<Map<String, dynamic>> items,
  });

  /// Routes available for a submitted request (`get_routes`).
  Future<List<StockRouteOption>> fetchRoutes({
    required int requestOrderId,
  });

  /// Assign route to a submitted request (`set_route`).
  Future<void> setRoute({
    required int requestOrderId,
    required int routeId,
  });

  /// Confirm a submitted request with route assigned (`confirm_request`).
  Future<void> confirmRequest({required int requestOrderId});
}
