import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Sends user text to the AI backend and returns an HTML reply string.
class AiChatService {
  static const String chatUrl = 'http://89.117.60.212:8001/chat';

  AiChatService({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 2),
        validateStatus: (_) => true,
      ),
    );
    if (!kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
    return dio;
  }

  Future<String> fetchHtmlReply({
    required String text,
    required String language,
  }) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'text': text,
      'language': language == 'en' ? 'en' : 'ar',
    });

    late final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        chatUrl,
        data: formData,
        options: Options(
          validateStatus: (_) => true,
          sendTimeout: const Duration(minutes: 2),
        ),
      );
    } on DioException catch (e) {
      throw _toUserFacingError(e);
    }

    final statusCode = response.statusCode;
    final data = response.data;

    if (statusCode != null && statusCode >= 400) {
      if (statusCode >= 500) {
        throw const FormatException('ai_chat_server_error');
      }
      throw Exception(_httpErrorMessage(statusCode, data));
    }

    if (data == null) {
      throw FormatException('ai_chat_empty_response', statusCode);
    }

    final map = _parseResponseMap(data);
    if (map == null) {
      throw const FormatException('ai_chat_invalid_response');
    }

    if (map['detail'] != null) {
      throw Exception(_formatDetail(map['detail']));
    }

    final status = map['status']?.toString();
    if (status != null && status != 'success') {
      throw Exception(map['message']?.toString() ?? 'ai_chat_bad_status');
    }

    final report = map['report'];
    if (report is String && report.trim().isNotEmpty) {
      return report.trim();
    }

    final fallback = map['html'] ?? map['message'] ?? map['reply'];
    if (fallback is String && fallback.trim().isNotEmpty) {
      return fallback.trim();
    }

    throw const FormatException('ai_chat_missing_html');
  }

  static Map<String, dynamic>? _parseResponseMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return null;
  }

  static String _formatDetail(dynamic detail) {
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map) {
        return first['msg']?.toString() ??
            first['message']?.toString() ??
            detail.toString();
      }
    }
    return detail.toString();
  }

  static String _httpErrorMessage(int statusCode, dynamic data) {
    final map = _parseResponseMap(data);
    if (map != null) {
      if (map['detail'] != null) {
        return _formatDetail(map['detail']);
      }
      final message = map['message'] ?? map['error'];
      if (message != null) return message.toString();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return 'ai_chat_server_error:$statusCode';
  }

  static Object _toUserFacingError(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    if (code != null && code >= 500) {
      return const FormatException('ai_chat_server_error');
    }
    if (code != null && data != null) {
      return Exception(_httpErrorMessage(code, data));
    }
    return Exception(e.message ?? 'ai_chat_error');
  }
}
