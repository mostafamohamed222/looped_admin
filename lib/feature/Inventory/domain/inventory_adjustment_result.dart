import 'package:equatable/equatable.dart';

/// Parsed `result.body` from `inventory_create_adjustment` (JSON-RPC).
class InventoryAdjustmentResult extends Equatable {
  const InventoryAdjustmentResult({
    required this.inventoryId,
    required this.reference,
    required this.state,
    required this.filter,
    required this.exhausted,
    required this.locationId,
    required this.locationName,
    required this.lines,
    this.skippedLines = const [],
  });

  final int inventoryId;
  final String reference;
  final String state;
  final String filter;
  final bool exhausted;
  final int locationId;
  final String locationName;
  final List<InventoryAdjustmentLine> lines;
  final List<Map<String, dynamic>> skippedLines;

  @override
  List<Object?> get props => [
        inventoryId,
        reference,
        state,
        filter,
        exhausted,
        locationId,
        locationName,
        lines,
        skippedLines,
      ];
}

class InventoryAdjustmentLine extends Equatable {
  const InventoryAdjustmentLine({
    required this.lineId,
    required this.productId,
    required this.productName,
    required this.productUomId,
    required this.productUomName,
    required this.locationId,
    required this.locationName,
    required this.theoreticalQty,
    required this.productQty,
    required this.quantitiesDifference,
  });

  final int lineId;
  final int productId;
  final String productName;
  final int productUomId;
  final String productUomName;
  final int locationId;
  final String locationName;
  final double theoreticalQty;
  final double productQty;
  final double quantitiesDifference;

  /// Difference when the user edits counted qty: `counted - theoretical_qty`.
  double differenceForCounted(double counted) => counted - theoreticalQty;

  @override
  List<Object?> get props => [
        lineId,
        productId,
        productName,
        productUomId,
        productUomName,
        locationId,
        locationName,
        theoreticalQty,
        productQty,
        quantitiesDifference,
      ];
}
