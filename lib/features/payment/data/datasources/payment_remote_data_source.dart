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
import '../../domain/entities/payment_method.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentModel> uploadInvoice({
    List<PlatformFile> files = const [],
    required String eventId,
    PaymentMethod method = PaymentMethod.bankTransfer,
    String? walletProvider,
    String? endpoint,
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

  /// Text fields for `POST /payment-requests`. `amount` is omitted — the
  /// server derives it from the event's invoice_total. `wallet_provider` is
  /// sent only for wallet payments (where the backend requires it).
  static Map<String, String> buildPaymentRequestFields({
    required String eventId,
    required PaymentMethod method,
    String? walletProvider,
  }) {
    final provider = walletProvider?.trim();
    return {
      'event_id': eventId,
      'payment_method': method.apiValue,
      if (method == PaymentMethod.wallet && provider != null && provider.isNotEmpty)
        'wallet_provider': provider,
    };
  }

  @override
  Future<PaymentModel> uploadInvoice({
    List<PlatformFile> files = const [],
    required String eventId,
    PaymentMethod method = PaymentMethod.bankTransfer,
    String? walletProvider,
    String? endpoint,
  }) async {
    _progressController.add(0.0);

    // Backend (PaymentRequestController@store) expects `invoice_images[]`
    // (1-5 images), required unless payment_method=cash.
    final formData = FormData.fromMap(buildPaymentRequestFields(
      eventId: eventId,
      method: method,
      walletProvider: walletProvider,
    ));
    if (method.requiresReceipt) {
      for (final file in files) {
        final path = file.path;
        if (path == null) continue;
        formData.files.add(
          MapEntry(
            'invoice_images[]',
            await MultipartFile.fromFile(path, filename: file.name),
          ),
        );
      }
    }

    // We use raw dio.post here (not apiConsumer) because we need
    // onSendProgress for upload progress, which apiConsumer.post does not
    // expose. The Bearer token must be attached explicitly: AuthInterceptor
    // sits on the singleton Dio but its public-path detection is fragile
    // when full URLs are passed, so we add Authorization here directly.
    final token = await _secureStorage.getToken();
    final response = await dio.post(
      '${Endpoints.baseUrl}${endpoint ?? Endpoints.paymentRequests}',
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
    // 201 {message, payment_request}; tolerate an ApiResponse `data` too.
    final data = decoded is Map
        ? (decoded['payment_request'] ?? decoded['data'] ?? decoded)
        : const {};
    final file = files.isEmpty ? null : files.first;
    return PaymentModel(
      id: '${(data is Map ? data['id'] : null) ?? ''}',
      fileName: file?.name ?? '',
      fileSize: file?.lengthSync() ?? 0,
      fileExtension: file?.extension ?? '',
      filePath: file?.path,
      uploadedAt: DateTime.now(),
      status: PaymentStatus.uploaded,
    );
  }

  @override
  Future<BankDetailsModel> getBankDetails() async {
    // `/payments/initiate` is a POST that CREATES a payment; it was never a
    // bank-details source (a GET there 404s on the `payments/{payment}` route).
    final response = await apiConsumer.get(Endpoints.paymentBankDetails);
    final data = response is Map ? (response['data'] ?? response) : const {};
    return BankDetailsModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Stream<double> getUploadProgress() {
    return _progressController.stream;
  }

  void dispose() {
    _progressController.close();
  }
}
