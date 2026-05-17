import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/core/data_scource/remote/end_points.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_adjustment_result.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_adjustment_summary.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_count_repository.dart';
import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/feature/Inventory/domain/warehouse_option.dart';

class InventoryCountRepositoryImpl implements InventoryCountRepository {
  InventoryCountRepositoryImpl({required DioConsumer dio}) : _dio = dio;

  final DioConsumer _dio;

  static const _demoProducts = <ProductOption>[
    ProductOption(
      id: 'p-101',
      name: 'Mineral water 500ml — carton',
      sku: 'SKU-44102',
      barcode: '6281234567890',
    ),
    ProductOption(
      id: 'p-102',
      name: 'Arabica coffee beans 1kg',
      sku: 'SKU-88211',
      barcode: '6289876543210',
    ),
    ProductOption(
      id: 'p-103',
      name: 'Office paper A4 (5 reams)',
      sku: 'SKU-22001',
      barcode: '6281112223334',
    ),
    ProductOption(
      id: 'p-104',
      name: 'Hand sanitizer 500ml',
      sku: 'SKU-77340',
      barcode: '6285556667778',
    ),
  ];

  @override
  Future<List<ProductOption>> fetchInventoryCatalog() async {
    final dynamic response = await _dio.post(
      EndPoints.inventoryGetProducts,
      body: const <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{},
      },
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException('inventory_products_invalid_response');
    }
    if (response['error'] != null) {
      throw Exception(response['error'].toString());
    }
    final result = response['result'];
    if (result is! Map<String, dynamic>) {
      throw const FormatException('inventory_products_missing_result');
    }
    final statusCode = result['status_code'];
    if (statusCode != 200) {
      final msg = result['message']?.toString() ?? 'inventory_products_bad_status';
      throw Exception(msg);
    }
    final body = result['body'];
    if (body is! List<dynamic>) {
      throw const FormatException('inventory_products_missing_body');
    }
    return body.map(_mapProductRow).whereType<ProductOption>().toList();
  }

  ProductOption? _mapProductRow(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final idRaw = m['id'];
    if (idRaw == null) return null;
    final id = idRaw.toString();
    final display =
        (m['display_name'] ?? m['name'] ?? '').toString().trim();
    if (display.isEmpty) return null;
    final name = (m['name'] ?? display).toString().trim();
    final sku = (m['default_code'] ?? '').toString().trim();
    final barcode = m['barcode']?.toString();
    final disp = m['display_name']?.toString().trim();
    return ProductOption(
      id: id,
      name: name.isEmpty ? display : name,
      sku: sku,
      barcode: (barcode == null || barcode.isEmpty) ? null : barcode,
      displayName: (disp != null && disp.isNotEmpty) ? disp : null,
    );
  }

  @override
  Future<List<WarehouseOption>> fetchWarehouses() async {
    final dynamic response = await _dio.post(
      EndPoints.inventoryGetLocations,
      body: const <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{},
      },
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException('inventory_locations_invalid_response');
    }
    if (response['error'] != null) {
      throw Exception(response['error'].toString());
    }
    final result = response['result'];
    if (result is! Map<String, dynamic>) {
      throw const FormatException('inventory_locations_missing_result');
    }
    final statusCode = result['status_code'];
    if (statusCode != 200) {
      final msg = result['message']?.toString() ?? 'inventory_locations_bad_status';
      throw Exception(msg);
    }
    final body = result['body'];
    if (body is! List<dynamic>) {
      throw const FormatException('inventory_locations_missing_body');
    }
    return body.map(_mapLocationRow).whereType<WarehouseOption>().toList();
  }

  WarehouseOption? _mapLocationRow(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final idRaw = m['id'];
    final int? id = switch (idRaw) {
      int v => v,
      num v => v.toInt(),
      String v => int.tryParse(v),
      _ => null,
    };
    if (id == null) return null;
    final displayName =
        (m['display_name'] ?? m['complete_name'] ?? m['name'] ?? '')
            .toString()
            .trim();
    if (displayName.isEmpty) return null;
    return WarehouseOption(
      id: id,
      name: displayName,
      warehouseName: m['warehouse_name']?.toString(),
      companyName: m['company_name']?.toString(),
    );
  }

  @override
  Future<List<ProductOption>> fetchProducts({
    required String warehouseId,
    String? query,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final q = query?.trim().toLowerCase() ?? '';
    final list = _demoProducts.where((p) {
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q) ||
          (p.barcode?.toLowerCase().contains(q) ?? false);
    }).toList();
    // Pretend catalog differs slightly per warehouse for realism.
    if (warehouseId == 'wh-3') {
      return list.where((p) => p.id != 'p-102').toList();
    }
    return list;
  }

  @override
  Future<ProductOption?> lookupProductByBarcode({
    required String warehouseId,
    required String barcode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final products = await fetchProducts(warehouseId: warehouseId);
    final normalized = barcode.trim();
    for (final p in products) {
      if (p.barcode == normalized) return p;
    }
    return null;
  }

  @override
  Future<InventoryAdjustmentResult> createAdjustment({
    required int locationId,
    required String inventoryReference,
    required bool isFullCount,
    required bool exhausted,
    List<Map<String, dynamic>>? manualLines,
  }) async {
    final params = <String, dynamic>{
      'inventory_reference': inventoryReference,
      'location_id': locationId,
      'inventory_of': isFullCount ? 'all' : 'manual',
    };
    if (isFullCount) {
      params['exhausted'] = exhausted;
    } else {
      params['lines'] = manualLines ?? <Map<String, dynamic>>[];
    }

    final dynamic response = await _dio.post(
      EndPoints.inventoryCreateAdjustment,
      body: <String, dynamic>{
        'jsonrpc': '2.0',
        'params': params,
      },
    );
    _ensureInventoryRpcOk(response);
    final result = response as Map<String, dynamic>;
    final innerRaw = result['result'];
    if (innerRaw is! Map) {
      throw const FormatException('inventory_adjustment_missing_result');
    }
    final inner = Map<String, dynamic>.from(innerRaw);
    final bodyRaw = inner['body'];
    if (bodyRaw is! Map) {
      throw const FormatException('inventory_adjustment_missing_body');
    }
    final body = Map<String, dynamic>.from(bodyRaw);
    return _mapAdjustmentResult(body);
  }

  InventoryAdjustmentResult _mapAdjustmentResult(Map<String, dynamic> body) {
    final inventoryId = _asInt(body['inventory_id']);
    final locationId = _asInt(body['location_id']);
    if (inventoryId == null || locationId == null) {
      throw const FormatException('inventory_adjustment_missing_body');
    }
    final linesRaw = body['lines'];
    final lines = <InventoryAdjustmentLine>[];
    if (linesRaw is List) {
      for (final row in linesRaw) {
        if (row is! Map) continue;
        final m = Map<String, dynamic>.from(row);
        final line = _mapAdjustmentLine(m);
        if (line != null) lines.add(line);
      }
    }
    final skippedRaw = body['skipped_lines'];
    final skipped = <Map<String, dynamic>>[];
    if (skippedRaw is List) {
      for (final row in skippedRaw) {
        if (row is Map) skipped.add(Map<String, dynamic>.from(row));
      }
    }
    return InventoryAdjustmentResult(
      inventoryId: inventoryId,
      reference:
          (body['reference'] ?? body['name'] ?? '').toString(),
      state: (body['state'] ?? '').toString(),
      filter: (body['filter'] ?? '').toString(),
      exhausted: body['exhausted'] == true,
      locationId: locationId,
      locationName: (body['location_name'] ?? '').toString(),
      lines: lines,
      skippedLines: skipped,
    );
  }

  InventoryAdjustmentLine? _mapAdjustmentLine(Map<String, dynamic> m) {
    final lineId = _asInt(m['line_id']);
    final productId = _asInt(m['product_id']);
    if (lineId == null || productId == null) return null;
    final productName = (m['product_name'] ?? '').toString();
    if (productName.isEmpty) return null;
    final locId = _asInt(m['location_id']) ?? 0;
    return InventoryAdjustmentLine(
      lineId: lineId,
      productId: productId,
      productName: productName,
      productUomId: _asInt(m['product_uom_id']) ?? 0,
      productUomName: (m['product_uom_name'] ?? '').toString(),
      locationId: locId,
      locationName: (m['location_name'] ?? '').toString(),
      theoreticalQty: _asDouble(m['theoretical_qty']),
      productQty: _asDouble(m['product_qty']),
      quantitiesDifference: _asDouble(m['quantities_difference']),
    );
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  @override
  Future<List<InventoryAdjustmentSummary>> fetchAllAdjustments() async {
    final dynamic response = await _dio.post(
      EndPoints.inventoryGetAllAdjustments,
      body: const <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{},
      },
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException('inventory_adjustments_list_invalid_response');
    }
    if (response['error'] != null) {
      throw Exception(response['error'].toString());
    }
    final result = response['result'];
    if (result is! Map<String, dynamic>) {
      throw const FormatException('inventory_adjustments_list_missing_result');
    }
    final statusCode = result['status_code'];
    if (statusCode != 200) {
      final msg = result['message']?.toString() ??
          'inventory_adjustments_list_bad_status';
      throw Exception(msg);
    }
    final body = result['body'];
    if (body is! List<dynamic>) {
      throw const FormatException('inventory_adjustments_list_missing_body');
    }
    return body.map(_mapAdjustmentSummaryRow).whereType<InventoryAdjustmentSummary>().toList();
  }

  @override
  Future<InventoryAdjustmentResult> fetchAdjustmentDetails({
    required int inventoryId,
  }) async {
    final dynamic response = await _dio.post(
      EndPoints.inventoryGetAdjustmentDetails,
      body: <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{
          'inventory_id': inventoryId,
        },
      },
    );
    _ensureInventoryRpcOk(response);
    final map = response as Map<String, dynamic>;
    final innerRaw = map['result'];
    if (innerRaw is! Map) {
      throw const FormatException('inventory_adjustment_details_missing_result');
    }
    final inner = Map<String, dynamic>.from(innerRaw);
    final bodyRaw = inner['body'];
    if (bodyRaw is! Map) {
      throw const FormatException('inventory_adjustment_details_missing_body');
    }
    return _mapAdjustmentResult(Map<String, dynamic>.from(bodyRaw));
  }

  InventoryAdjustmentSummary? _mapAdjustmentSummaryRow(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = _asInt(m['inventory_id']);
    final locId = _asInt(m['location_id']);
    final compId = _asInt(m['company_id']);
    final lines = _asInt(m['lines_count']) ?? 0;
    if (id == null || locId == null || compId == null) return null;
    final name = (m['name'] ?? '').toString().trim();
    if (name.isEmpty) return null;
    return InventoryAdjustmentSummary(
      inventoryId: id,
      name: name,
      date: (m['date'] ?? '').toString(),
      state: (m['state'] ?? '').toString(),
      filter: (m['filter'] ?? '').toString(),
      exhausted: m['exhausted'] == true,
      locationId: locId,
      locationName: (m['location_name'] ?? '').toString(),
      companyId: compId,
      companyName: (m['company_name'] ?? '').toString(),
      linesCount: lines,
    );
  }

  @override
  Future<void> updateInventoryLines(List<Map<String, dynamic>> lines) async {
    final dynamic response = await _dio.post(
      EndPoints.inventoryUpdateLines,
      body: <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{
          'lines': lines,
        },
      },
    );
    _ensureInventoryRpcOk(response);
  }

  void _ensureInventoryRpcOk(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const FormatException('inventory_adjustment_invalid_response');
    }
    if (response['error'] != null) {
      throw Exception(response['error'].toString());
    }
    final resultRaw = response['result'];
    if (resultRaw is! Map) {
      throw const FormatException('inventory_adjustment_missing_result');
    }
    final result = Map<String, dynamic>.from(resultRaw);
    final statusCode = result['status_code'];
    if (statusCode != 200) {
      final msg =
          result['message']?.toString() ?? 'inventory_adjustment_bad_status';
      throw Exception(msg);
    }
  }
}
