import 'package:equatable/equatable.dart';

/// Product line item for single-product inventory.
/// Replace with API DTO mapping when backend is ready.
class ProductOption extends Equatable {
  const ProductOption({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    this.displayName,
  });

  final String id;
  final String name;
  final String sku;
  final String? barcode;

  /// Prefer this for list UI when provided by `get_products` (`display_name`).
  final String? displayName;

  int get odooProductId => int.parse(id);

  @override
  List<Object?> get props => [id, name, sku, barcode, displayName];
}
