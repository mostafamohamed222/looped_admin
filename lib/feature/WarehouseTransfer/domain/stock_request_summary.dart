import 'package:equatable/equatable.dart';

/// One row from `get_all_requests` (`result.body[]`).
class StockRequestSummary extends Equatable {
  const StockRequestSummary({
    required this.id,
    required this.name,
    required this.state,
    required this.expectedDate,
    required this.warehouseId,
    required this.warehouseName,
    required this.locationId,
    required this.locationName,
    required this.companyId,
    required this.companyName,
    required this.routeId,
    required this.routeName,
    required this.linesCount,
    required this.requestedBy,
    required this.requestedByName,
    required this.branchId,
    required this.branchName,
  });

  final int id;
  final String name;
  final String state;
  final String expectedDate;
  final int warehouseId;
  final String warehouseName;
  final int locationId;
  final String locationName;
  final int companyId;
  final String companyName;
  final int routeId;
  final String routeName;
  final int linesCount;
  final int requestedBy;
  final String requestedByName;
  final int branchId;
  final String branchName;

  @override
  List<Object?> get props => [
        id,
        name,
        state,
        expectedDate,
        warehouseId,
        warehouseName,
        locationId,
        locationName,
        companyId,
        companyName,
        routeId,
        routeName,
        linesCount,
        requestedBy,
        requestedByName,
        branchId,
        branchName,
      ];
}
