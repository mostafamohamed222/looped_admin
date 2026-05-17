import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_count_repository.dart';
import 'package:looped_admin/feature/Inventory/presentation/cubit/inventory_adjustments_list_state.dart';

class InventoryAdjustmentsListCubit extends Cubit<InventoryAdjustmentsListState> {
  InventoryAdjustmentsListCubit({required InventoryCountRepository repository})
      : _repository = repository,
        super(const InventoryAdjustmentsListState());

  final InventoryCountRepository _repository;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: InventoryAdjustmentsListStatus.loading,
        clearError: true,
      ),
    );
    try {
      final list = await _repository.fetchAllAdjustments();
      emit(
        state.copyWith(
          status: InventoryAdjustmentsListStatus.success,
          items: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryAdjustmentsListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
