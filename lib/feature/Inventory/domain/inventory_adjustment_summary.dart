import 'package:equatable/equatable.dart';

/// One row from `get_all_adjustments` (`result.body[]`).
class InventoryAdjustmentSummary extends Equatable {
  const InventoryAdjustmentSummary({
    required this.inventoryId,
    required this.name,
    required this.date,
    required this.state,
    required this.filter,
    required this.exhausted,
    required this.locationId,
    required this.locationName,
    required this.companyId,
    required this.companyName,
    required this.linesCount,
  });

  final int inventoryId;
  final String name;
  final String date;
  final String state;
  final String filter;
  final bool exhausted;
  final int locationId;
  final String locationName;
  final int companyId;
  final String companyName;
  final int linesCount;

  @override
  List<Object?> get props => [
        inventoryId,
        name,
        date,
        state,
        filter,
        exhausted,
        locationId,
        locationName,
        companyId,
        companyName,
        linesCount,
      ];
}
