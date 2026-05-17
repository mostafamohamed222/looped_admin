import 'package:equatable/equatable.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_summary.dart';

enum WarehouseTransferListStatus { initial, loading, success, failure }

class WarehouseTransferListState extends Equatable {
  const WarehouseTransferListState({
    this.status = WarehouseTransferListStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final WarehouseTransferListStatus status;
  final List<StockRequestSummary> items;
  final String? errorMessage;

  bool get isLoading => status == WarehouseTransferListStatus.loading;

  WarehouseTransferListState copyWith({
    WarehouseTransferListStatus? status,
    List<StockRequestSummary>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WarehouseTransferListState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
