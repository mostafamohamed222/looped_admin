import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/warehouse_transfer_repository.dart';
import 'package:looped_admin/feature/WarehouseTransfer/presentation/cubit/warehouse_transfer_list_state.dart';

class WarehouseTransferListCubit extends Cubit<WarehouseTransferListState> {
  WarehouseTransferListCubit({required WarehouseTransferRepository repository})
      : _repository = repository,
        super(const WarehouseTransferListState());

  final WarehouseTransferRepository _repository;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: WarehouseTransferListStatus.loading,
        clearError: true,
      ),
    );
    try {
      final list = await _repository.fetchAllRequests();
      emit(
        state.copyWith(
          status: WarehouseTransferListStatus.success,
          items: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WarehouseTransferListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
