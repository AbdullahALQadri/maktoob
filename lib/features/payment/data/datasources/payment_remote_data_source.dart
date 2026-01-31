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
      // TODO: Implement actual API upload with progress tracking
      await Future.delayed(const Duration(milliseconds: 200));
      _progressController.add(1.0);

      return PaymentModel(
        id: '',
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 100));

      return const BankDetailsModel(
        bankName: '',
        accountName: '',
        accountNumber: '',
        iban: '',
        swiftCode: '',
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
