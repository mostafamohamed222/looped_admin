import 'package:equatable/equatable.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_adjustment_summary.dart';

enum InventoryAdjustmentsListStatus { initial, loading, success, failure }

class InventoryAdjustmentsListState extends Equatable {
  const InventoryAdjustmentsListState({
    this.status = InventoryAdjustmentsListStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final InventoryAdjustmentsListStatus status;
  final List<InventoryAdjustmentSummary> items;
  final String? errorMessage;

  bool get isLoading => status == InventoryAdjustmentsListStatus.loading;

  InventoryAdjustmentsListState copyWith({
    InventoryAdjustmentsListStatus? status,
    List<InventoryAdjustmentSummary>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InventoryAdjustmentsListState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
