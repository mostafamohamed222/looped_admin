import 'package:equatable/equatable.dart';

/// Location row from `get_locations` (filtered by warehouse).
class StockLocationOption extends Equatable {
  const StockLocationOption({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
