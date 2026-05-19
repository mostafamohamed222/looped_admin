import 'package:equatable/equatable.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_picking_summary.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_summary.dart';

/// Payload from `get_request_transfers` (`result.body`).
class StockRequestTransfers extends Equatable {
  const StockRequestTransfers({
    required this.requestOrder,
    required this.transfers,
    required this.pickingCount,
  });

  final StockRequestSummary requestOrder;
  final List<StockPickingSummary> transfers;
  final int pickingCount;

  @override
  List<Object?> get props => [requestOrder, transfers, pickingCount];
}
