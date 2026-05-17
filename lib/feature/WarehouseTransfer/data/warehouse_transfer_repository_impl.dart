import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/core/data_scource/remote/end_points.dart';
import 'package:looped_admin/feature/Inventory/domain/product_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_create_request_result.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_location_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_detail.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_line.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_summary.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_route_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_warehouse_option.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/warehouse_transfer_repository.dart';

class WarehouseTransferRepositoryImpl implements WarehouseTransferRepository {
  WarehouseTransferRepositoryImpl({required DioConsumer dio}) : _dio = dio;

  final DioConsumer _dio;

  @override
  Future<List<StockRequestSummary>> fetchAllRequests() async {
    final dynamic response = await _dio.post(
      EndPoints.stockGetAllRequests,
      body: const <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{},
      },
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException('transfer_requests_list_invalid_response');
    }
    if (response['error'] != null) {
      throw Exception(response['error'].toString());
    }
    final result = response['result'];
    if (result is! Map<String, dynamic>) {
      throw const FormatException('transfer_requests_list_missing_result');
    }
    final statusCode = result['status_code'];
    if (statusCode != 200) {
      final msg =
          result['message']?.toString() ?? 'transfer_requests_list_bad_status';
      throw Exception(msg);
    }
    final body = result['body'];
    if (body is! List<dynamic>) {
      throw const FormatException('transfer_requests_list_missing_body');
    }
    return body
        .map(_mapStockRequestRow)
        .whereType<StockRequestSummary>()
        .toList();
  }

  @override
  Future<StockRequestDetail> fetchRequestDetails({
    required int requestOrderId,
  }) async {
    final dynamic response = await _dio.post(
      EndPoints.stockGetRequestDetails,
      body: <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{
          'request_order_id': requestOrderId,
        },
      },
    );
    _ensureRpcOk(response);
    final map = response as Map<String, dynamic>;
    final innerRaw = map['result'];
    if (innerRaw is! Map) {
      throw const FormatException('transfer_request_details_missing_result');
    }
    final inner = Map<String, dynamic>.from(innerRaw);
    final bodyRaw = inner['body'];
    if (bodyRaw is! Map) {
      throw const FormatException('transfer_request_details_missing_body');
    }
    final detail = _mapStockRequestDetail(Map<String, dynamic>.from(bodyRaw));
    if (detail == null) {
      throw const FormatException('transfer_request_details_invalid_body');
    }
    return detail;
  }

  @override
  Future<List<StockWarehouseOption>> fetchStockWarehouses() async {
    final body = await _postRpcList(
      EndPoints.stockGetWarehouses,
      const <String, dynamic>{},
      invalidResponse: 'transfer_warehouses_invalid_response',
      missingResult: 'transfer_warehouses_missing_result',
      badStatus: 'transfer_warehouses_bad_status',
      missingBody: 'transfer_warehouses_missing_body',
    );
    return body
        .map(_mapStockWarehouseRow)
        .whereType<StockWarehouseOption>()
        .toList();
  }

  @override
  Future<List<StockLocationOption>> fetchStockLocations({
    required int warehouseId,
  }) async {
    final body = await _postRpcList(
      EndPoints.stockGetLocations,
      <String, dynamic>{'warehouse_id': warehouseId},
      invalidResponse: 'transfer_locations_invalid_response',
      missingResult: 'transfer_locations_missing_result',
      badStatus: 'transfer_locations_bad_status',
      missingBody: 'transfer_locations_missing_body',
    );
    return body
        .map(_mapStockLocationRow)
        .whereType<StockLocationOption>()
        .toList();
  }

  @override
  Future<StockCreateRequestResult> createRequest({
    required int warehouseId,
    required int locationId,
    required List<Map<String, dynamic>> items,
  }) async {
    final dynamic response = await _dio.post(
      EndPoints.stockCreateRequest,
      body: <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{
          'warehouse_id': warehouseId,
          'location_id': locationId,
          'items': items,
        },
      },
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException('transfer_create_invalid_response');
    }
    if (response['error'] != null) {
      throw Exception(response['error'].toString());
    }
    final resultRaw = response['result'];
    if (resultRaw is! Map) {
      throw const FormatException('transfer_create_missing_result');
    }
    final result = Map<String, dynamic>.from(resultRaw);
    final statusCode = result['status_code'];
    if (statusCode != 200) {
      final msg = result['message']?.toString() ?? 'transfer_create_bad_status';
      throw Exception(msg);
    }
    final bodyRaw = result['body'];
    if (bodyRaw is! Map) {
      throw const FormatException('transfer_create_missing_body');
    }
    final body = Map<String, dynamic>.from(bodyRaw);
    final id = _asInt(body['request_order_id']) ?? _asInt(body['id']);
    if (id == null) {
      throw const FormatException('transfer_create_missing_request_id');
    }
    final name = (body['name'] ?? '').toString().trim();
    return StockCreateRequestResult(
      requestOrderId: id,
      name: name.isEmpty ? null : name,
    );
  }

  @override
  Future<List<StockRouteOption>> fetchRoutes({
    required int requestOrderId,
  }) async {
    final body = await _postRpcList(
      EndPoints.stockGetRoutes,
      <String, dynamic>{'request_order_id': requestOrderId},
      invalidResponse: 'transfer_routes_invalid_response',
      missingResult: 'transfer_routes_missing_result',
      badStatus: 'transfer_routes_bad_status',
      missingBody: 'transfer_routes_missing_body',
    );
    return body.map(_mapStockRouteRow).whereType<StockRouteOption>().toList();
  }

  @override
  Future<void> addRequestLines({
    required int requestOrderId,
    required List<Map<String, dynamic>> items,
  }) async {
    final dynamic response = await _dio.post(
      EndPoints.stockAddRequestLines,
      body: <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{
          'request_order_id': requestOrderId,
          'items': items,
        },
      },
    );
    _ensureActionRpcOk(
      response,
      invalidResponse: 'transfer_add_lines_invalid_response',
      missingResult: 'transfer_add_lines_missing_result',
      badStatus: 'transfer_add_lines_bad_status',
    );
  }

  @override
  Future<void> submitRequest({required int requestOrderId}) async {
    final dynamic response = await _dio.post(
      EndPoints.stockSubmitRequest,
      body: <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{
          'request_order_id': requestOrderId,
        },
      },
    );
    _ensureActionRpcOk(
      response,
      invalidResponse: 'transfer_submit_invalid_response',
      missingResult: 'transfer_submit_missing_result',
      badStatus: 'transfer_submit_bad_status',
    );
  }

  @override
  Future<void> confirmRequest({required int requestOrderId}) async {
    final dynamic response = await _dio.post(
      EndPoints.stockConfirmRequest,
      body: <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{
          'request_order_id': requestOrderId,
        },
      },
    );
    _ensureActionRpcOk(
      response,
      invalidResponse: 'transfer_confirm_invalid_response',
      missingResult: 'transfer_confirm_missing_result',
      badStatus: 'transfer_confirm_bad_status',
    );
  }

  @override
  Future<void> setRoute({
    required int requestOrderId,
    required int routeId,
  }) async {
    final dynamic response = await _dio.post(
      EndPoints.stockSetRoute,
      body: <String, dynamic>{
        'jsonrpc': '2.0',
        'params': <String, dynamic>{
          'request_order_id': requestOrderId,
          'route_id': routeId,
        },
      },
    );
    _ensureActionRpcOk(
      response,
      invalidResponse: 'transfer_set_route_invalid_response',
      missingResult: 'transfer_set_route_missing_result',
      badStatus: 'transfer_set_route_bad_status',
    );
  }

  @override
  Future<List<ProductOption>> fetchProductsCatalog() async {
    final body = await _postRpcList(
      EndPoints.inventoryGetProducts,
      const <String, dynamic>{},
      invalidResponse: 'transfer_products_invalid_response',
      missingResult: 'transfer_products_missing_result',
      badStatus: 'transfer_products_bad_status',
      missingBody: 'transfer_products_missing_body',
    );
    return body.map(_mapProductRow).whereType<ProductOption>().toList();
  }

  Future<List<dynamic>> _postRpcList(
    String path,
    Map<String, dynamic> params, {
    required String invalidResponse,
    required String missingResult,
    required String badStatus,
    required String missingBody,
  }) async {
    final dynamic response = await _dio.post(
      path,
      body: <String, dynamic>{
        'jsonrpc': '2.0',
        'params': params,
      },
    );
    if (response is! Map<String, dynamic>) {
      throw FormatException(invalidResponse);
    }
    if (response['error'] != null) {
      throw Exception(response['error'].toString());
    }
    final result = response['result'];
    if (result is! Map<String, dynamic>) {
      throw FormatException(missingResult);
    }
    final statusCode = result['status_code'];
    if (statusCode != 200) {
      final msg = result['message']?.toString() ?? badStatus;
      throw Exception(msg);
    }
    final body = result['body'];
    if (body is! List<dynamic>) {
      throw FormatException(missingBody);
    }
    return body;
  }

  StockRouteOption? _mapStockRouteRow(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = _asInt(m['id']);
    if (id == null) return null;
    final display = _asString(m['display_name']);
    final name = _asString(m['name']);
    return StockRouteOption(
      id: id,
      name: name.isEmpty ? display : name,
      displayName: display.isEmpty ? name : display,
    );
  }

  StockWarehouseOption? _mapStockWarehouseRow(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = _asInt(m['id']);
    if (id == null) return null;
    final name = (m['display_name'] ?? m['name'] ?? '').toString().trim();
    if (name.isEmpty) return null;
    return StockWarehouseOption(id: id, name: name);
  }

  StockLocationOption? _mapStockLocationRow(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = _asInt(m['id']);
    if (id == null) return null;
    final name = (m['display_name'] ?? m['complete_name'] ?? m['name'] ?? '')
        .toString()
        .trim();
    if (name.isEmpty) return null;
    return StockLocationOption(id: id, name: name);
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

  void _ensureRpcOk(dynamic response) {
    _ensureActionRpcOk(
      response,
      invalidResponse: 'transfer_request_details_invalid_response',
      missingResult: 'transfer_request_details_missing_result',
      badStatus: 'transfer_request_details_bad_status',
    );
  }

  void _ensureActionRpcOk(
    dynamic response, {
    required String invalidResponse,
    required String missingResult,
    required String badStatus,
  }) {
    if (response is! Map<String, dynamic>) {
      throw FormatException(invalidResponse);
    }
    if (response['error'] != null) {
      throw Exception(response['error'].toString());
    }
    final resultRaw = response['result'];
    if (resultRaw is! Map) {
      throw FormatException(missingResult);
    }
    final result = Map<String, dynamic>.from(resultRaw);
    final statusCode = result['status_code'];
    if (statusCode != 200) {
      final msg = result['message']?.toString() ?? badStatus;
      throw Exception(msg);
    }
  }

  StockRequestDetail? _mapStockRequestDetail(Map<String, dynamic> m) {
    final linesRaw = m['lines'];
    final lines = <StockRequestLine>[];
    if (linesRaw is List<dynamic>) {
      for (final raw in linesRaw) {
        final line = _mapStockRequestLine(raw);
        if (line != null) lines.add(line);
      }
    }

    final summary = _mapStockRequestRow(m);
    if (summary == null) return null;

    return StockRequestDetail(
      id: summary.id,
      name: summary.name,
      state: summary.state,
      expectedDate: summary.expectedDate,
      warehouseId: summary.warehouseId,
      warehouseName: summary.warehouseName,
      locationId: summary.locationId,
      locationName: summary.locationName,
      companyId: summary.companyId,
      companyName: summary.companyName,
      routeId: summary.routeId,
      routeName: summary.routeName,
      linesCount: summary.linesCount,
      requestedBy: summary.requestedBy,
      requestedByName: summary.requestedByName,
      branchId: summary.branchId,
      branchName: summary.branchName,
      lines: lines,
    );
  }

  StockRequestLine? _mapStockRequestLine(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    return StockRequestLine(
      id: _asIntOrZero(m['id']),
      productId: _asIntOrZero(m['product_id']),
      productName: _asString(m['product_name']),
      productUomQty: _asDouble(m['product_uom_qty']),
      productUomId: _asIntOrZero(m['product_uom_id']),
      productUomName: _asString(m['product_uom_name']),
      routeId: _asIntOrZero(m['route_id']),
      state: _asString(m['state']),
    );
  }

  StockRequestSummary? _mapStockRequestRow(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    return StockRequestSummary(
      id: _requestOrderId(m),
      name: _asString(m['name']),
      state: _asString(m['state']),
      expectedDate: _asString(m['expected_date']),
      warehouseId: _asIntOrZero(m['warehouse_id']),
      warehouseName: _asString(m['warehouse_name']),
      locationId: _asIntOrZero(m['location_id']),
      locationName: _asString(m['location_name']),
      companyId: _asIntOrZero(m['company_id']),
      companyName: _asString(m['company_name']),
      routeId: _asIntOrZero(m['route_id']),
      routeName: _asString(m['route_name']),
      linesCount: _asInt(m['lines_count']) ?? 0,
      requestedBy: _asIntOrZero(m['requested_by']),
      requestedByName: _asString(m['requested_by_name']),
      branchId: _asIntOrZero(m['branch_id']),
      branchName: _asString(m['branch_name']),
    );
  }

  int _requestOrderId(Map<String, dynamic> m) =>
      _asInt(m['request_order_id']) ?? _asInt(m['id']) ?? 0;

  String _asString(dynamic v) => (v ?? '').toString().trim();

  int _asIntOrZero(dynamic v) => _asInt(v) ?? 0;

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
}
