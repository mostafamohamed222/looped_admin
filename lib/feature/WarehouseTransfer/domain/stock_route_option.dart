import 'package:equatable/equatable.dart';

/// Route row from `get_routes` (`result.body[]`).
class StockRouteOption extends Equatable {
  const StockRouteOption({
    required this.id,
    required this.name,
    required this.displayName,
  });

  final int id;
  final String name;
  final String displayName;

  String get label =>
      displayName.isNotEmpty ? displayName : (name.isNotEmpty ? name : '#$id');

  @override
  List<Object?> get props => [id, name, displayName];
}
