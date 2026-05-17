import 'package:equatable/equatable.dart';

class StockRequestLine extends Equatable {
  const StockRequestLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productUomQty,
    required this.productUomId,
    required this.productUomName,
    required this.routeId,
    required this.state,
  });

  final int id;
  final int productId;
  final String productName;
  final double productUomQty;
  final int productUomId;
  final String productUomName;
  final int routeId;
  final String state;

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productUomQty,
        productUomId,
        productUomName,
        routeId,
        state,
      ];
}
