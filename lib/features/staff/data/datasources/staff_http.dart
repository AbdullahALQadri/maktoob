import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/api/end_points.dart';
import '../../../../core/error/exceptions.dart';
import 'staff_token_store.dart';

/// The staff mode's own HTTP client. Separate from the app's on purpose: it
/// carries the staff token, and a refusal here never signs the client out.
class StaffHttp {
  StaffHttp({required this.tokens, Dio? dio}) : dio = dio ?? _build();

  final StaffTokenStore tokens;
  final Dio dio;

  static Dio _build() => Dio(
        BaseOptions(
          baseUrl: Endpoints.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          responseType: ResponseType.json,
          headers: {'Accept': 'application/json', 'Accept-Language': 'ar'},
          // Every answer is read here, so the server's own words reach the screen.
          validateStatus: (_) => true,
        ),
      );

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) => _send('GET', path, query: query);

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, bool signedIn = true}) =>
      _send('POST', path, body: body, signedIn: signedIn);

  /// A private file (an ID photo, a certificate): bytes kept in memory,
  /// never written to the phone.
  Future<Uint8List> bytes(String path) async {
    final token = await tokens.read();
    if (token == null || token.isEmpty) throw const UnauthorizedException();
    final Response<List<int>> response;
    try {
      response = await dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes, headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw NetworkException(message: e.message);
    }
    final status = response.statusCode ?? 0;
    if (status == 401) throw const UnauthorizedException();
    if (status < 200 || status >= 300) throw ServerException(code: status);
    return Uint8List.fromList(response.data ?? const []);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool signedIn = true,
  }) async {
    final token = signedIn ? await tokens.read() : null;
    if (signedIn && (token == null || token.isEmpty)) throw const UnauthorizedException();

    final Response<dynamic> response;
    try {
      response = await dio.request<dynamic>(
        path,
        queryParameters: query,
        data: body,
        options: Options(method: method, headers: {if (token != null) 'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw NetworkException(message: e.message);
    }

    final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return data;

    final message = _message(data);
    if (status == 401) throw UnauthorizedException(message: message);
    if (status == 422) throw ValidationException(message: message);
    throw ServerException(message: message, code: status);
  }

  /// The first field error when there is one, else the message.
  static String? _message(Map<String, dynamic> data) {
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return '${first.first}';
    }
    return data['message']?.toString();
  }
}
