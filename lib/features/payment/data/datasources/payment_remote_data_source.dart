import 'dart:async';

import 'package:file_picker/file_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../models/bank_details_model.dart';
import '../models/payment_model.dart';
import '../../domain/entities/payment_entity.dart';

abstract class PaymentRemoteDataSource {
  /// Uploads an invoice file to the server
  ///
  /// Throws a [ServerException] if the upload fails
  Future<PaymentModel> uploadInvoice({
    required PlatformFile file,
    required String eventId,
  });

  /// Gets bank details from the server
  ///
  /// Throws a [ServerException] if fetching fails
  Future<BankDetailsModel> getBankDetails();

  /// Returns a stream of upload progress values (0.0 to 1.0)
  Stream<double> getUploadProgress();
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  // In a real implementation, this would be injected
  // final ApiConsumer apiConsumer;

  final StreamController<double> _progressController = StreamController<double>.broadcast();

  PaymentRemoteDataSourceImpl();

  @override
  Future<PaymentModel> uploadInvoice({
    required PlatformFile file,
    required String eventId,
  }) async {
    try {
      // Simulate upload with progress updates
      const totalDuration = 2000;
      const steps = 20;
      const stepDuration = totalDuration ~/ steps;

      for (int i = 1; i <= steps; i++) {
        await Future.delayed(Duration(milliseconds: stepDuration));
        _progressController.add(i / steps);
      }

      // In a real implementation, this would call the API
      // final response = await apiConsumer.post(
      //   EndPoints.uploadInvoice,
      //   formData: FormData.fromMap({
      //     'file': await MultipartFile.fromFile(file.path!, filename: file.name),
      //     'event_id': eventId,
      //   }),
      // );
      // return PaymentModel.fromJson(response);

      // For now, return a mock response
      return PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: file.name,
        fileSize: file.size,
        fileExtension: file.extension ?? '',
        filePath: file.path,
        uploadedAt: DateTime.now(),
        status: PaymentStatus.uploaded,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to upload invoice: $e');
    }
  }

  @override
  Future<BankDetailsModel> getBankDetails() async {
    try {
      // In a real implementation, this would call the API
      // final response = await apiConsumer.get(EndPoints.bankDetails);
      // return BankDetailsModel.fromJson(response);

      // For now, return mock bank details
      await Future.delayed(const Duration(milliseconds: 300));

      return const BankDetailsModel(
        bankName: 'Al Rajhi Bank',
        accountName: 'Maktoob Events LLC',
        accountNumber: '1234567890123456',
        iban: 'SA03 8000 0000 1234 5678 9012 3456',
        swiftCode: 'RJHISARI',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch bank details: $e');
    }
  }

  @override
  Stream<double> getUploadProgress() {
    return _progressController.stream;
  }

  void dispose() {
    _progressController.close();
  }
}
