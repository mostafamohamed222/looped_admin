import 'package:equatable/equatable.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_picking_move_line.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_picking_summary.dart';

/// Full picking from `get_transfer_details` (`result.body`).
class StockPickingDetail extends Equatable {
  const StockPickingDetail({
    required this.summary,
    required this.moveLines,
  });

  final StockPickingSummary summary;
  final List<StockPickingMoveLine> moveLines;

  @override
  List<Object?> get props => [summary, moveLines];
}
