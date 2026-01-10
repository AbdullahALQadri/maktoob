import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class UploadInvoiceUseCase implements UseCase<PaymentEntity, UploadInvoiceParams> {
  final PaymentRepository repository;

  UploadInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(UploadInvoiceParams params) async {
    return await repository.uploadInvoice(
      file: params.file,
      eventId: params.eventId,
    );
  }

  /// Returns a stream of upload progress values (0.0 to 1.0)
  Stream<double> getUploadProgress() {
    return repository.getUploadProgress();
  }
}

class UploadInvoiceParams extends Equatable {
  final PlatformFile file;
  final String eventId;

  const UploadInvoiceParams({
    required this.file,
    required this.eventId,
  });

  @override
  List<Object?> get props => [file, eventId];
}
