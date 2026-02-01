import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/api/event_wizard_api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/invitation_entity.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../services/excel_parser_service.dart';

/// Implementation of [InvitationRepository].
///
/// Delegates to [EventWizardApiService] for all server operations
/// and [ExcelParserService] for local Excel parsing.
class InvitationRepositoryImpl implements InvitationRepository {
  final ExcelParserService excelParserService;
  final EventWizardApiService wizardApiService;

  InvitationRepositoryImpl({
    required this.excelParserService,
    required this.wizardApiService,
  });

  @override
  Future<Either<Failure, List<EventTypeEntity>>> getEventTypes() async {
    try {
      final response = await wizardApiService.getEventTypes();
      final data = response['data'] as List? ?? [];
      final eventTypes = data.map((json) => EventTypeEntity(
        id: json['id'] as int,
        name: json['name_en'] ?? json['name'] ?? '',
        nameAr: json['name_ar'] as String?,
        icon: json['icon'] as String?,
        isCustom: json['is_custom'] == true,
      )).toList();
      return Right(eventTypes);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TemplateEntity>>> getTemplatesForEventType(int eventTypeId) async {
    try {
      final response = await wizardApiService.getTemplatesForEventType(eventTypeId);
      final data = response['data'] as List? ?? [];
      final templates = data.map((json) => TemplateEntity(
        id: json['id'] as int,
        name: json['name'] ?? json['name_en'] ?? '',
        previewUrl: json['preview_url'] as String?,
        eventTypeId: json['event_type_id'] as int? ?? eventTypeId,
      )).toList();
      return Right(templates);
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
      final response = await wizardApiService.initializeWizard(
        eventTypeId: eventTypeId,
        templateId: templateId,
      );
      final eventId = response['data']?['event_id'] as int? ??
          response['event_id'] as int? ??
          0;
      return Right(eventId);
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
      final guestsData = guests.map((g) {
        final map = <String, String>{
          'name': g.name,
          'phone': g.phone,
        };
        if (g.email != null) map['email'] = g.email!;
        return map;
      }).toList();
      final response = await wizardApiService.addManualGuests(eventId, guestsData);
      final data = response['data'] as List? ?? [];
      final addedGuests = data.map((json) => GuestEntity(
        id: json['id']?.toString(),
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] as String?,
        source: GuestSource.manual,
      )).toList();
      return Right(addedGuests.isNotEmpty ? addedGuests : guests);
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
      await wizardApiService.removeGuest(eventId, int.parse(guestId));
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
      final response = await wizardApiService.getPackages(eventId);
      final data = response['data'] as List? ?? [];
      final packages = data.map((json) => PackageEntity(
        id: json['id'] as int,
        name: json['name'] ?? json['name_en'] ?? '',
        nameAr: json['name_ar'] as String?,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        guestLimit: json['guest_limit'] as int? ?? 0,
        features: (json['features'] as List?)
            ?.map((f) => f.toString())
            .toList() ?? [],
      )).toList();
      return Right(packages);
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
      await wizardApiService.selectPackage(eventId, packageId: packageId);
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
      final response = await wizardApiService.getExtraServices(eventId);
      final data = response['data'] as List? ?? [];
      final services = data.map((json) => ExtraServiceEntity(
        id: json['id'] as int,
        name: json['name'] ?? json['name_en'] ?? '',
        nameAr: json['name_ar'] as String?,
        description: json['description'] as String?,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        isSelected: json['is_selected'] == true,
      )).toList();
      return Right(services);
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
      // The API saves all selected services at once;
      // the cubit manages the full list and sends updated IDs.
      await wizardApiService.saveExtraServices(eventId, [serviceId]);
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
      final response = await wizardApiService.getInvoiceSummary(eventId);
      final data = response['data'] ?? response;
      final lineItems = (data['line_items'] as List? ?? [])
          .map((item) => InvoiceLineItem(
                description: item['description'] ?? '',
                amount: (item['amount'] as num?)?.toDouble() ?? 0,
              ))
          .toList();
      return Right(InvoiceEntity(
        packagePrice: (data['package_price'] as num?)?.toDouble() ?? 0,
        servicesPrice: (data['services_price'] as num?)?.toDouble() ?? 0,
        totalPrice: (data['total_price'] as num?)?.toDouble() ?? 0,
        packageName: data['package_name'] as String?,
        guestCount: data['guest_count'] as int? ?? 0,
        lineItems: lineItems,
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
      await wizardApiService.saveEvent(eventId, isDraft: true);
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
      await wizardApiService.saveEvent(eventId, isDraft: false);
      await wizardApiService.activateEvent(eventId);
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
      await wizardApiService.saveEventDetails(
        eventId,
        titleAr: name,
        eventDate: date,
        eventTime: time,
        venueId: venueId != null ? int.tryParse(venueId) : null,
        customVenueNameAr: customLocation,
      );
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
      final response = await wizardApiService.getInvitationPreview(eventId);
      final previewUrl = response['data']?['preview_url'] as String? ??
          response['preview_url'] as String? ??
          '';
      return Right(previewUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
