import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/error/failures.dart';
import '../entities/bank_details_entity.dart';
import '../entities/payment_entity.dart';
import '../entities/payment_method.dart';

abstract class PaymentRepository {
  /// Submits a payment request: a receipt for bank transfer / wallet,
  /// nothing for cash (the admin collects it in person).
  Future<Either<Failure, PaymentEntity>> uploadInvoice({
    List<PlatformFile> files = const [],
    required String eventId,
    PaymentMethod method = PaymentMethod.bankTransfer,
    String? walletProvider,
    String? endpoint,
  });

  /// Gets the bank details for payment
  Future<Either<Failure, BankDetailsEntity>> getBankDetails();

  /// Simulates upload progress and returns progress updates via stream
  Stream<double> getUploadProgress();
}
