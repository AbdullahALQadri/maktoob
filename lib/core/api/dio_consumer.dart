import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../injection_container.dart' as di;
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import '../utils/storage/shared_preferences.dart';
import 'api_consumer.dart';
import 'app_interceptors.dart';
import 'end_points.dart';
import 'status_code.dart';

class DioConsumer implements ApiConsumer {
  final Dio client;

  DioConsumer({required this.client}) {
    // Allow self-signed certificates in development
    (client.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    client.options
      ..baseUrl = Endpoints.baseUrl
      ..responseType = ResponseType.plain
      ..followRedirects = false
      ..connectTimeout = Duration(milliseconds: AppConstants.apiTimeout)
      ..receiveTimeout = Duration(milliseconds: AppConstants.apiTimeout)
      ..sendTimeout = Duration(milliseconds: AppConstants.uploadTimeout)
      ..validateStatus = (status) => status! < StatusCode.internalServerError;

    client.interceptors.add(di.sl<AppIntercepters>());
    if (kDebugMode) {
      client.interceptors.add(di.sl<LogInterceptor>());
    }
  }

  /// Get authorization headers based on current user type
  Map<String, dynamic> _getHeaders() {
    final token = SharedPrefController().token;
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // ========== GET ==========
  @override
  Future get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await client.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: _getHeaders()),
      );
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  // ========== POST ==========
  @override
  Future post(
    String path, {
    Map<String, dynamic>? body,
    bool formDataIsEnabled = false,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await client.post(
        path,
        queryParameters: queryParameters,
        options: Options(headers: _getHeaders()),
        data: formDataIsEnabled ? FormData.fromMap(body!) : body,
      );
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  // ========== POST WITH IMAGE ==========
  @override
  Future postWithImage(
    String path, {
    Map<String, dynamic>? body,
    bool formDataIsEnabled = true,
    Map<String, dynamic>? queryParameters,
    dynamic params,
  }) async {
    try {
      String? fileName;
      if (params.image != null) {
        fileName = params.image.path.split('/').last;
      }

      FormData formData = FormData.fromMap({
        "image": params.image != null
            ? await MultipartFile.fromFile(
                params.image.path,
                filename: fileName,
              )
            : null,
        ...?body,
      });

      final response = await client.post(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            ..._getHeaders(),
            "Content-Type": "multipart/form-data",
          },
        ),
        data: formData,
      );
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  // ========== POST REGISTER ==========
  @override
  Future postRegister(
    String path, {
    Map<String, dynamic>? body,
    bool formDataIsEnabled = true,
    Map<String, dynamic>? queryParameters,
    dynamic params,
  }) async {
    try {
      String? fileName;
      MultipartFile? imageFile;

      if (params.image != null && params.image.path.isNotEmpty) {
        fileName = params.image.path.split('/').last;
        imageFile = await MultipartFile.fromFile(
          params.image.path,
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap({
        "name": params.name,
        "email": params.email,
        "phone": params.phone,
        "password": params.password,
        "password_confirmation": params.password,
        if (imageFile != null) "avatar": imageFile,
      });

      final response = await client.post(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
          },
        ),
        data: formData,
      );
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  // ========== CREATE SERVICE ==========
  @override
  Future postCreateService(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    params,
  }) async {
    try {
      String? fileName;
      MultipartFile? imageFile;

      if (params.image != null && params.image.path.isNotEmpty) {
        fileName = params.image.path.split('/').last;
        imageFile = await MultipartFile.fromFile(
          params.image.path,
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap({
        ...?body,
        if (imageFile != null) "image": imageFile,
      });

      final response = await client.post(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            ..._getHeaders(),
            "Content-Type": "multipart/form-data",
          },
        ),
        data: formData,
      );
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  // ========== PUT ==========
  @override
  Future put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await client.put(
        path,
        queryParameters: queryParameters,
        data: body,
        options: Options(headers: _getHeaders()),
      );
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  // ========== DELETE ==========
  @override
  Future delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await client.delete(
        path,
        queryParameters: queryParameters,
        options: Options(headers: _getHeaders()),
        data: body,
      );
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  // ========== HANDLE RESPONSE ==========
  dynamic _handleResponseAsJson(Response<dynamic> response) {
    final responseJson = jsonDecode(response.data.toString());
    return responseJson;
  }

  // ========== HANDLE ERRORS ==========
  dynamic _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const FetchDataException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        // Try to extract error message from response
        String? message;
        if (responseData != null) {
          try {
            final json = jsonDecode(responseData.toString());
            message = json['message'] as String?;
          } catch (_) {}
        }

        switch (statusCode) {
          case StatusCode.badRequest:
            throw BadRequestException(message);
          case StatusCode.unauthorized:
          case StatusCode.forbidden:
            throw UnauthorizedException(message);
          case StatusCode.notFound:
            throw NotFoundException(message);
          case StatusCode.conflict:
            throw ConflictException(message);
          case StatusCode.unprocessableEntity:
            throw ValidationException(message);
          case StatusCode.internalServerError:
            throw InternalServerErrorException(message);
          default:
            throw ServerException(message ?? "Unexpected error: $statusCode");
        }

      case DioExceptionType.cancel:
        throw const RequestCancelledException();

      case DioExceptionType.unknown:
      case DioExceptionType.connectionError:
        throw const NoInternetConnectionException();

      case DioExceptionType.badCertificate:
        throw const ServerException("Invalid certificate");

      default:
        throw const ServerException("Unknown error occurred");
    }
  }
}
