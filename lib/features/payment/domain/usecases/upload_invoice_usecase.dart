import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_entity.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_repository.dart';

class UploadInvoiceUseCase implements UseCase<PaymentEntity, UploadInvoiceParams> {
  final PaymentRepository repository;

  UploadInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(UploadInvoiceParams params) async {
    return await repository.uploadInvoice(
      files: params.files,
      eventId: params.eventId,
      method: params.method,
      walletProvider: params.walletProvider,
      endpoint: params.endpoint,
    );
  }

  /// Returns a stream of upload progress values (0.0 to 1.0)
  Stream<double> getUploadProgress() {
    return repository.getUploadProgress();
  }
}

class UploadInvoiceParams extends Equatable {
  final List<PlatformFile> files;
  final String eventId;
  final PaymentMethod method;
  final String? walletProvider;

  /// Where to send it; null = `POST /payment-requests` (the event's first
  /// payment). Extra services on a paid event use their own endpoint.
  final String? endpoint;

  const UploadInvoiceParams({
    this.files = const [],
    required this.eventId,
    this.method = PaymentMethod.bankTransfer,
    this.walletProvider,
    this.endpoint,
  });

  @override
  List<Object?> get props => [files, eventId, method, walletProvider, endpoint];
}
