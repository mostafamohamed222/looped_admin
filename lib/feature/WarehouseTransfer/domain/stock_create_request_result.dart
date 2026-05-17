import 'package:equatable/equatable.dart';

/// Response from `create_request` (`result.body`).
class StockCreateRequestResult extends Equatable {
  const StockCreateRequestResult({
    required this.requestOrderId,
    this.name,
  });

  final int requestOrderId;
  final String? name;

  @override
  List<Object?> get props => [requestOrderId, name];
}
