import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
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

    final formData = FormData.fromMap({
      'event_id': eventId,
      'receipt': await MultipartFile.fromFile(
        file.path!,
        filename: file.name,
      ),
    });

    final response = await dio.post(
      '${Endpoints.baseUrl}${Endpoints.paymentRequests}',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) {
          _progressController.add(sent / total);
        }
      },
    );

    _progressController.add(1.0);

    final data = response.data['data'] ?? response.data;
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
