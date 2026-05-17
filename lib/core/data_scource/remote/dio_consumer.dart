import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../error/exceptions.dart';
import 'api_consumer.dart';
import 'dio_interceptors.dart';
import 'staus_code.dart';



class DioConsumer extends ApiConsumer {
  late Dio client;

  DioConsumer({required this.client}) {
    (client.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return httpClient;
    };

    client.options
      ..responseType = ResponseType.plain
      ..followRedirects = false
      ..headers = {
        "accept": "text/plain",
        // "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
        'X-Requested-With': 'XMLHttpRequest',
        'Accept-Language': 'en_US',
        'Content-Type': 'application/json'
        
      }
      ..validateStatus = (status) {
        return true;
      };
    client.interceptors.add(AppIntercepters());
  }

  void changeLang(String newLang) {
    client.options.headers['Accept-Language']= newLang;
  }

  void addToken(String token) {
    client.options.headers.addAll({"Authentication": token});
  }

  void addBaseUrl(String baseUrl) {
    client.options.baseUrl = baseUrl;
  }

  void addLocation({
    required double longitude,
    required double latitude,
  }) {
    client.options.headers.addAll({});
  }
  
  void addSession(String session) {
    client.options.headers.addAll({"Cookie": session});
  }

  @override
  Future get(String path,
      {dynamic body,
      Map<String, dynamic>? queryParameters}) async {
    try {
      debugPrint(body.toString());
      debugPrint(client.options.headers.toString());
      final response =
          await client.get(path, queryParameters: queryParameters, data: body);
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioException(error);
    }
  }

  @override
  Future post(String path,
      {dynamic body,
      // bool formDataIsEnabled = false,
      Map<String, dynamic>? queryParameters}) async {
    try {
      debugPrint(body.toString());
      final response = await client.post(path,
          queryParameters: queryParameters,
          data: body
          // data: formDataIsEnabled ? FormData.fromMap(body!) : body
          );
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioException(error);
    }
  }

  @override
  Future download(String path,
      {Map<String, dynamic>? body,
      bool formDataIsEnabled = false,
      Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await client.post(
        path,
        //onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status != null ? status < 500 : false;
            }),
      );
      //log(response.headers["content-disposition"].toString());
      // log(response.data.toString());
      // log(response.statusMessage.toString());
      Map<String, dynamic> result = {
        "content-disposition": response.headers["content-disposition"],
        "data": jsonDecode(response.data.toString()),
      };
      return result;
    } on DioException catch (error) {
      _handleDioException(error);
    }
  }

  @override
  Future patch(String path,
      {Map<String, dynamic>? body,
      bool formDataIsEnabled = false,
      Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await client.patch(path,
          queryParameters: queryParameters,
          data: formDataIsEnabled ? FormData.fromMap(body!) : body);
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioException(error);
    }
  }

  @override
  Future put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await client.put(path, queryParameters: queryParameters, data: body);
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioException(error);
    }
  }

  @override
  Future delete(String path,
      {Map<String, dynamic>? body,
      Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await client.delete(path,
          queryParameters: queryParameters, data: body);
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioException(error);
    }
  }

  dynamic _handleResponseAsJson(Response<dynamic> response) {
    if (response.data == null || response.data.toString().trim() == "") {
      return {
        "statusCode": response.statusCode ?? 204,
        "description": "No Content",
      };
    }
    final String raw = response.data.toString();
    try {
      final responseJson = jsonDecode(raw);
      if (responseJson is Map<String, dynamic>) {
        responseJson['statusCode'] = response.statusCode;
      }
      return responseJson;
    } catch (_) {
      // مرجع HTML أو نص مش JSON — نرميه كما هو عشان تظهر عند العميل وتعرَف الإيشو
      throw ServerException('Server response error | $raw');
    }
  }

  dynamic _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const FetchDataException();
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case StatusCode.badRequest:
            throw const BadRequestException();
          case StatusCode.unauthorized:
          case StatusCode.forbidden:
            throw const UnauthorizedException();
          case StatusCode.notFound:
            throw const NotFoundException();
          case StatusCode.conflict:
            throw const ConflictException();

          case StatusCode.internalServerError:
            throw const InternalServerErrorException();
        }
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.connectionError:
        throw const NoInternetConnectionException();
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown: {
        // عرض الخطأ الفعلي كما هو عند العميل عشان تعرف الإيشو بالظبط
        final msg = error.message ?? '';
        final err = error.error?.toString() ?? '';
        final body = error.response?.data?.toString() ?? '';
        final parts = [msg, err, body].where((s) => s.isNotEmpty);
        throw ServerException(
          parts.isEmpty ? 'Server response error' : 'Server response error | ${parts.join(' | ')}',
        );
      }
    }
  }
}