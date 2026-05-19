import 'package:equatable/equatable.dart';

/// One move line from `get_transfer_details` (`move_lines[]`).
class StockPickingMoveLine extends Equatable {
  const StockPickingMoveLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.demand,
    required this.quantityDone,
    required this.productUomId,
    required this.productUomName,
    required this.state,
    required this.branchName,
    required this.brandName,
  });

  final int id;
  final int productId;
  final String productName;
  final double demand;
  final double quantityDone;
  final int productUomId;
  final String productUomName;
  final String state;
  final String branchName;
  final String brandName;

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        demand,
        quantityDone,
        productUomId,
        productUomName,
        state,
        branchName,
        brandName,
      ];
}
