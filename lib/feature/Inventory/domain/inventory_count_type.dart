/// How the warehouse count session is scoped.
enum InventoryCountType {
  /// Count every product in the selected warehouse.
  full,

  /// Count one product (search / barcode / picker).
  singleProduct,
}
