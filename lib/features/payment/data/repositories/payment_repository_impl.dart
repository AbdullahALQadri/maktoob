import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, PaymentEntity>> uploadInvoice({
    required PlatformFile file,
    required String eventId,
  }) async {
    try {
      final result = await remoteDataSource.uploadInvoice(
        file: file,
        eventId: eventId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(UploadFailure(message: e.message));
    } catch (e) {
      return Left(UploadFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, BankDetailsEntity>> getBankDetails() async {
    try {
      final result = await remoteDataSource.getBankDetails();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Stream<double> getUploadProgress() {
    return remoteDataSource.getUploadProgress();
  }
}
