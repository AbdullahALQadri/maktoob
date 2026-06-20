import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/utils/storage/secure_storage_service.dart';
import '../models/bank_details_model.dart';
import '../models/payment_model.dart';
import '../../domain/entities/payment_entity.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentModel> uploadInvoice({
    required PlatformFile file,
    required String eventId,
  });
  Future<BankDetailsModel> getBankDetails();
  Stream<double> getUploadProgress();
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiConsumer apiConsumer;
  final Dio dio;
  final SecureStorageService _secureStorage = SecureStorageService();

  final StreamController<double> _progressController =
      StreamController<double>.broadcast();

  PaymentRemoteDataSourceImpl({
    required this.apiConsumer,
    required this.dio,
  });

  @override
  Future<PaymentModel> uploadInvoice({
    required PlatformFile file,
    required String eventId,
  }) async {
    _progressController.add(0.0);

    // Backend (PaymentRequestController@store) expects `invoice_images[]`
    // (an array of 1-5 image files), not a single `receipt`. `amount` is
    // optional — the server derives it from the event's invoice_total.
    final formData = FormData.fromMap({'event_id': eventId});
    formData.files.add(
      MapEntry(
        'invoice_images[]',
        await MultipartFile.fromFile(file.path!, filename: file.name),
      ),
    );

    // We use raw dio.post here (not apiConsumer) because we need
    // onSendProgress for upload progress, which apiConsumer.post does not
    // expose. The Bearer token must be attached explicitly: AuthInterceptor
    // sits on the singleton Dio but its public-path detection is fragile
    // when full URLs are passed, so we add Authorization here directly.
    final token = await _secureStorage.getToken();
    final response = await dio.post(
      '${Endpoints.baseUrl}${Endpoints.paymentRequests}',
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
      onSendProgress: (sent, total) {
        if (total > 0) {
          _progressController.add(sent / total);
        }
      },
    );

    _progressController.add(1.0);

    // The shared Dio is configured with ResponseType.plain (see DioConsumer),
    // so response.data is a String — decode before reading.
    final raw = response.data;
    final decoded = raw is String ? jsonDecode(raw) : raw;
    final data = (decoded is Map && decoded['data'] != null)
        ? decoded['data']
        : decoded;
    return PaymentModel(
      id: '${data['id'] ?? ''}',
      fileName: file.name,
      fileSize: file.size,
      fileExtension: file.extension ?? '',
      filePath: file.path,
      uploadedAt: DateTime.now(),
      status: PaymentStatus.uploaded,
    );
  }

  @override
  Future<BankDetailsModel> getBankDetails() async {
    final response = await apiConsumer.get(Endpoints.paymentsInitiate);
    final data = response['data'] ?? response;
    return BankDetailsModel.fromJson(data);
  }

  @override
  Stream<double> getUploadProgress() {
    return _progressController.stream;
  }

  void dispose() {
    _progressController.close();
  }
}
