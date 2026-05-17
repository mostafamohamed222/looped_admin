import 'package:equatable/equatable.dart';

/// Warehouse row from `get_warehouses`.
class StockWarehouseOption extends Equatable {
  const StockWarehouseOption({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
