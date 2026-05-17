import 'package:looped_admin/feature/Inventory/domain/inventory_adjustment_result.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_adjustment_summary.dart';
import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/feature/Inventory/domain/warehouse_option.dart';

/// Remote data access for the inventory count setup screen.
/// Wire [DioConsumer] / endpoints here in the implementation.
abstract class InventoryCountRepository {
  /// Placeholder: `GET /warehouses` (or equivalent).
  Future<List<WarehouseOption>> fetchWarehouses();

  /// Full product catalog for manual inventory (`get_products`).
  Future<List<ProductOption>> fetchInventoryCatalog();

  /// Placeholder: `GET /products?warehouseId=&q=` with server-side search.
  Future<List<ProductOption>> fetchProducts({
    required String warehouseId,
    String? query,
  });

  /// Placeholder: resolve barcode to a product in the warehouse context.
  Future<ProductOption?> lookupProductByBarcode({
    required String warehouseId,
    required String barcode,
  });

  /// Creates an inventory adjustment request (`inventory_of`: `all` or `manual`).
  Future<InventoryAdjustmentResult> createAdjustment({
    required int locationId,
    required String inventoryReference,
    required bool isFullCount,
    required bool exhausted,
    List<Map<String, dynamic>>? manualLines,
  });

  /// Updates counted quantities on existing inventory lines (`update_lines`).
  Future<void> updateInventoryLines(
    List<Map<String, dynamic>> lines,
  );

  /// Past / current inventory adjustments (`get_all_adjustments`).
  Future<List<InventoryAdjustmentSummary>> fetchAllAdjustments();

  /// Full adjustment payload for editing lines (`get_adjustment_details`).
  Future<InventoryAdjustmentResult> fetchAdjustmentDetails({
    required int inventoryId,
  });
}
