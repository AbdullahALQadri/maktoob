import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, PaymentEntity>> uploadInvoice({
    List<PlatformFile> files = const [],
    required String eventId,
    PaymentMethod method = PaymentMethod.bankTransfer,
    String? walletProvider,
    String? endpoint,
  }) async {
    try {
      final result = await remoteDataSource.uploadInvoice(
        files: files,
        eventId: eventId,
        method: method,
        walletProvider: walletProvider,
        endpoint: endpoint,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(UploadFailure(message: e.message));
    } on DioException catch (e) {
      return Left(UploadFailure(message: _dioMessage(e)));
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

  /// Surfaces the backend's message (e.g. 422 "a pending request already
  /// exists") instead of a raw Dio dump.
  static String _dioMessage(DioException e) {
    dynamic body = e.response?.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {}
    }
    if (body is Map) {
      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return '${first.first}';
      }
      if (body['message'] != null) return '${body['message']}';
    }
    return e.message ?? 'Upload failed';
  }

  @override
  Stream<double> getUploadProgress() {
    return remoteDataSource.getUploadProgress();
  }
}
