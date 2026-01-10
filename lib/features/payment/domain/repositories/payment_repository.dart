import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/error/failures.dart';
import '../entities/bank_details_entity.dart';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  /// Uploads an invoice file and returns the payment entity
  Future<Either<Failure, PaymentEntity>> uploadInvoice({
    required PlatformFile file,
    required String eventId,
  });

  /// Gets the bank details for payment
  Future<Either<Failure, BankDetailsEntity>> getBankDetails();

  /// Simulates upload progress and returns progress updates via stream
  Stream<double> getUploadProgress();
}
