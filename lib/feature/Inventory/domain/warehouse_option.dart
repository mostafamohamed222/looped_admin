import 'package:equatable/equatable.dart';

/// Stock location / warehouse line shown in the inventory count flow.
class WarehouseOption extends Equatable {
  const WarehouseOption({
    required this.id,
    required this.name,
    this.code,
    this.warehouseName,
    this.companyName,
  });

  final int id;
  final String name;
  final String? code;
  final String? warehouseName;
  final String? companyName;

  @override
  List<Object?> get props => [id, name, code, warehouseName, companyName];
}
