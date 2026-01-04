// import 'dart:convert';
// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:flutter/foundation.dart';
// import 'package:takata/core/api/status_code.dart';
//
// import '../../injection_container.dart' as di;
// import '../error/exceptions.dart';
// import '../utils/storage/shared_preferences.dart';
// import 'api_consumer.dart';
// import 'app_interceptors.dart';
// import 'end_points.dart';
//
// class DioConsumer implements ApiConsumer {
//   final Dio client;
//
//   DioConsumer({required this.client}) {
//     (client.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
//       final client = HttpClient();
//       client.badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//       return client;
//     };
//
//     client.options
//       ..baseUrl = Endpoints.baseUrl
//       ..responseType = ResponseType.plain
//       ..followRedirects = false
//       ..validateStatus = (status) => status! < StatusCode.internalServerError;
//
//     client.interceptors.add(di.sl<AppIntercepters>());
//     if (kDebugMode) {
//       client.interceptors.add(di.sl<LogInterceptor>());
//     }
//   }
//
//   // ========== GET ==========
//   @override
//   Future get(String path, {Map<String, dynamic>? queryParameters}) async {
//     try {
//       final response = await client.get(
//         path,
//         queryParameters: queryParameters,
//         options: Options(
//           headers: {
//             "Accept": "application/json",
//             "Authorization": "Bearer ${SharedPrefController().token}",
//           },
//         ),
//       );
//       return _handleResponseAsJson(response);
//     } on DioException catch (error) {
//       _handleDioError(error);
//     }
//   }
//
//   // ========== POST ==========
//   @override
//   Future post(
//     String path, {
//     Map<String, dynamic>? body,
//     bool formDataIsEnabled = false,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     try {
//       final response = await client.post(
//         path,
//         queryParameters: queryParameters,
//         options: Options(
//           headers: {
//             "Accept": "application/json",
//             "Authorization": "Bearer ${SharedPrefController().token}",
//           },
//         ),
//         data: formDataIsEnabled ? FormData.fromMap(body!) : body,
//       );
//       return _handleResponseAsJson(response);
//     } on DioException catch (error) {
//       _handleDioError(error);
//     }
//   }
//
//   // ========== POST WITH IMAGE ==========
//   @override
//   Future postWithImage(
//     String path, {
//     Map<String, dynamic>? body,
//     bool formDataIsEnabled = true,
//     Map<String, dynamic>? queryParameters,
//     dynamic params,
//   }) async {
//     try {
//       String? fileName;
//       if (params.image != null) {
//         fileName = params.image.path.split('/').last;
//       }
//
//       FormData formData = FormData.fromMap({
//         "image":
//             params.image != null
//                 ? await MultipartFile.fromFile(
//                   params.image.path,
//                   filename: fileName,
//                 )
//                 : null,
//         "phone": params.phone,
//         "address": params.address,
//         "twitter": params.twitter,
//       });
//
//       final response = await client.post(
//         path,
//         queryParameters: queryParameters,
//         options: Options(
//           headers: {
//             "Accept": "application/json",
//             "Authorization": "Bearer ${SharedPrefController().token}",
//           },
//         ),
//         data: formData,
//       );
//       return _handleResponseAsJson(response);
//     } on DioException catch (error) {
//       _handleDioError(error);
//     }
//   }
//
//   // ========== POST REGISTER ==========
//   @override
//   Future postRegister(
//     String path, {
//     Map<String, dynamic>? body,
//     bool formDataIsEnabled = true,
//     Map<String, dynamic>? queryParameters,
//     dynamic params,
//   }) async {
//     try {
//       String? fileName;
//       MultipartFile? imageFile;
//
//       if (params.image != null && params.image.path.isNotEmpty) {
//         fileName = params.image.path.split('/').last;
//         imageFile = await MultipartFile.fromFile(
//           params.image.path,
//           filename: fileName,
//         );
//       }
//
//       FormData formData = FormData.fromMap({
//         "email": params.email,
//         "password": params.password,
//         "name": params.name,
//         "fcm_token": "testtoken",
//         "phone": params.phone,
//         "image": imageFile,
//       });
//
//       final response = await client.post(
//         path,
//         queryParameters: queryParameters,
//         options: Options(
//           headers: {
//             "Accept": "application/json",
//             "Authorization": "Bearer ${SharedPrefController().token}",
//           },
//         ),
//         data: formData,
//       );
//       return _handleResponseAsJson(response);
//     } on DioException catch (error) {
//       _handleDioError(error);
//     }
//   }
//
//   // ========== CREATE SERVICE ==========
//   @override
//   Future postCreateService(
//     String path, {
//     Map<String, dynamic>? body,
//     Map<String, dynamic>? queryParameters,
//     params,
//   }) async {
//     try {
//       String? fileName;
//       MultipartFile? imageFile;
//
//       if (params.image != null && params.image.path.isNotEmpty) {
//         fileName = params.image.path.split('/').last;
//         imageFile = await MultipartFile.fromFile(
//           params.image.path,
//           filename: fileName,
//         );
//       }
//
//       FormData formData = FormData.fromMap({
//         "name": params.name,
//         "category_id": params.categoryId,
//         "subcategory_id": params.subCategoryId,
//         "year_production": params.yearProduction,
//         "spare_parts": params.spareParts,
//         "residential_unit": params.residentialUnit,
//         "region": params.region,
//         "polish_type": params.polishType,
//         "photography_type": params.photographyType,
//         "paper_type": params.paperType,
//         "delivery_area": params.deliveryArea,
//         "count_workers": params.countWorkers,
//         "count_videos": params.countVideos,
//         "count_photos": params.countPhotos,
//         "conditioning_type": params.conditioningType,
//         "car_type": params.carType,
//         "message": params.message,
//         "execution_time": params.executionTime,
//         "number_person": params.numberPerson,
//         "image": imageFile,
//       });
//
//       final response = await client.post(
//         path,
//         queryParameters: queryParameters,
//         options: Options(
//           headers: {
//             "Accept": "application/json",
//             "Authorization": "Bearer ${SharedPrefController().token}",
//           },
//         ),
//         data: formData,
//       );
//       return _handleResponseAsJson(response);
//     } on DioException catch (error) {
//       _handleDioError(error);
//     }
//   }
//
//   // ========== PUT ==========
//   @override
//   Future put(
//     String path, {
//     Map<String, dynamic>? body,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     try {
//       final response = await client.put(
//         path,
//         queryParameters: queryParameters,
//         data: body,
//         options: Options(
//           headers: {
//             "Accept": "application/json",
//             "Authorization": "Bearer ${SharedPrefController().token}",
//           },
//         ),
//       );
//       return _handleResponseAsJson(response);
//     } on DioException catch (error) {
//       _handleDioError(error);
//     }
//   }
//
//   // ========== DELETE ==========
//   @override
//   Future delete(
//     String path, {
//     Map<String, dynamic>? body,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     try {
//       final response = await client.delete(
//         path,
//         queryParameters: queryParameters,
//         options: Options(
//           headers: {
//             "Accept": "application/json",
//             "Authorization": "Bearer ${SharedPrefController().token}",
//           },
//         ),
//         data: body,
//       );
//       return _handleResponseAsJson(response);
//     } on DioException catch (error) {
//       _handleDioError(error);
//     }
//   }
//
//   // ========== HANDLE RESPONSE ==========
//   dynamic _handleResponseAsJson(Response<dynamic> response) {
//     final responseJson = jsonDecode(response.data.toString());
//     return responseJson;
//   }
//
//   // ========== HANDLE ERRORS ==========
//   dynamic _handleDioError(DioException error) {
//     switch (error.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         throw const FetchDataException();
//
//       case DioExceptionType.badResponse:
//         final statusCode = error.response?.statusCode;
//
//         switch (statusCode) {
//           case StatusCode.badRequest:
//             throw const BadRequestException();
//           case StatusCode.unauthorized:
//           case StatusCode.forbidden:
//             throw const UnauthorizedException();
//           case StatusCode.notFound:
//             throw const NotFoundException();
//           case StatusCode.conflict:
//             throw const ConflictException();
//           case StatusCode.internalServerError:
//             throw const InternalServerErrorException();
//           default:
//             throw ServerException("Unexpected error: $statusCode");
//         }
//
//       case DioExceptionType.cancel:
//         throw const RequestCancelledException();
//
//       case DioExceptionType.unknown:
//       case DioExceptionType.connectionError:
//         throw const NoInternetConnectionException();
//
//       case DioExceptionType.badCertificate:
//         throw UnimplementedError();
//
//       default:
//         throw ServerException("Unknown Dio exception occurred");
//     }
//   }
// }
