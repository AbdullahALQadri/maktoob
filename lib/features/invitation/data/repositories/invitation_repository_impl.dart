import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/invitation_entity.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../services/excel_parser_service.dart';

/// Implementation of [InvitationRepository].
///
/// Currently delegates to the EventWizardApiService for server operations
/// and ExcelParserService for Excel parsing.
/// TODO: Replace mock implementations with real API calls as backend is ready.
class InvitationRepositoryImpl implements InvitationRepository {
  final ExcelParserService excelParserService;

  InvitationRepositoryImpl({required this.excelParserService});

  @override
  Future<Either<Failure, List<EventTypeEntity>>> getEventTypes() async {
    try {
      // TODO: Replace with real API call via remote data source
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TemplateEntity>>> getTemplatesForEventType(int eventTypeId) async {
    try {
      // TODO: Replace with real API call
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> initializeWizard({
    required int eventTypeId,
    required int templateId,
  }) async {
    try {
      // TODO: Replace with real API call
      return const Right(0);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GuestEntity>>> addGuests({
    required int eventId,
    required List<GuestEntity> guests,
  }) async {
    try {
      // TODO: Replace with real API call
      return Right(guests);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeGuest({
    required int eventId,
    required String guestId,
  }) async {
    try {
      // TODO: Replace with real API call
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GuestEntity>>> parseExcelGuests(File file) async {
    try {
      final result = await excelParserService.parseExcelFile(file);
      if (result.isSuccess) {
        final guests = result.guests
            .map((g) => GuestEntity(
                  name: g.name,
                  phone: g.phone,
                  source: GuestSource.excel,
                ))
            .toList();
        return Right(guests);
      } else {
        return Left(ValidationFailure(
          message: result.errors.isNotEmpty ? result.errors.first : 'Failed to parse Excel file',
        ));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PackageEntity>>> getPackages(int eventId) async {
    try {
      // TODO: Replace with real API call
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> selectPackage({
    required int eventId,
    required int packageId,
  }) async {
    try {
      // TODO: Replace with real API call
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExtraServiceEntity>>> getExtraServices(int eventId) async {
    try {
      // TODO: Replace with real API call
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleService({
    required int eventId,
    required int serviceId,
  }) async {
    try {
      // TODO: Replace with real API call
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoiceEntity>> getInvoiceSummary(int eventId) async {
    try {
      // TODO: Replace with real API call
      return const Right(InvoiceEntity(
        packagePrice: 0,
        servicesPrice: 0,
        totalPrice: 0,
        guestCount: 0,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveDraft(int eventId) async {
    try {
      // TODO: Replace with real API call
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitAndActivate(int eventId) async {
    try {
      // TODO: Replace with real API call
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveEventDetails({
    required int eventId,
    required String name,
    required DateTime date,
    required String time,
    String? venueId,
    String? customLocation,
  }) async {
    try {
      // TODO: Replace with real API call
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getPreviewImage(int eventId) async {
    try {
      // TODO: Replace with real API call
      return const Right('');
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
