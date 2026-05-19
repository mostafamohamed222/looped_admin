import 'package:equatable/equatable.dart';

/// One stock picking / transfer from `get_request_transfers` (`transfers[]`).
class StockPickingSummary extends Equatable {
  const StockPickingSummary({
    required this.id,
    required this.name,
    required this.origin,
    required this.scheduledDate,
    required this.state,
    required this.stateLabel,
    required this.partnerName,
    required this.pickingTypeId,
    required this.pickingTypeName,
    required this.sourceLocationId,
    required this.sourceLocationName,
    required this.destinationLocationId,
    required this.destinationLocationName,
    required this.companyId,
    required this.companyName,
    required this.linesCount,
    required this.branchName,
    required this.brandName,
  });

  final int id;
  final String name;
  final String origin;
  final String scheduledDate;
  final String state;
  final String stateLabel;
  final String partnerName;
  final int pickingTypeId;
  final String pickingTypeName;
  final int sourceLocationId;
  final String sourceLocationName;
  final int destinationLocationId;
  final String destinationLocationName;
  final int companyId;
  final String companyName;
  final int linesCount;
  final String branchName;
  final String brandName;

  String get displayState =>
      stateLabel.isNotEmpty ? stateLabel : state;

  @override
  List<Object?> get props => [
        id,
        name,
        origin,
        scheduledDate,
        state,
        stateLabel,
        partnerName,
        pickingTypeId,
        pickingTypeName,
        sourceLocationId,
        sourceLocationName,
        destinationLocationId,
        destinationLocationName,
        companyId,
        companyName,
        linesCount,
        branchName,
        brandName,
      ];
}
