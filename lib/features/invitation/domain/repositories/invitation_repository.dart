import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/invitation_entity.dart';

/// Abstract repository for the invitation wizard feature.
///
/// Defines all data operations needed by the invitation flow,
/// including event types, templates, guests, packages, services, and invoices.
abstract class InvitationRepository {
  // ===========================================================================
  // EVENT TYPES & TEMPLATES
  // ===========================================================================

  /// Load available event types.
  Future<Either<Failure, List<EventTypeEntity>>> getEventTypes();

  /// Load templates for a specific event type.
  Future<Either<Failure, List<TemplateEntity>>> getTemplatesForEventType(int eventTypeId);

  /// Initialize a new wizard session on the server.
  Future<Either<Failure, int>> initializeWizard({
    required int eventTypeId,
    required int templateId,
  });

  // ===========================================================================
  // GUEST MANAGEMENT
  // ===========================================================================

  /// Add guests to the event.
  Future<Either<Failure, List<GuestEntity>>> addGuests({
    required int eventId,
    required List<GuestEntity> guests,
  });

  /// Remove a guest from the event.
  Future<Either<Failure, void>> removeGuest({
    required int eventId,
    required String guestId,
  });

  /// Parse guests from an Excel file.
  Future<Either<Failure, List<GuestEntity>>> parseExcelGuests(File file);

  // ===========================================================================
  // PACKAGES & SERVICES
  // ===========================================================================

  /// Load available packages for the event.
  Future<Either<Failure, List<PackageEntity>>> getPackages(int eventId);

  /// Select a package for the event.
  Future<Either<Failure, void>> selectPackage({
    required int eventId,
    required int packageId,
  });

  /// Load available extra services.
  Future<Either<Failure, List<ExtraServiceEntity>>> getExtraServices(int eventId);

  /// Toggle an extra service selection.
  Future<Either<Failure, void>> toggleService({
    required int eventId,
    required int serviceId,
  });

  // ===========================================================================
  // INVOICE & SUBMISSION
  // ===========================================================================

  /// Generate invoice summary for the event.
  Future<Either<Failure, InvoiceEntity>> getInvoiceSummary(int eventId);

  /// Save event as draft.
  Future<Either<Failure, void>> saveDraft(int eventId);

  /// Submit and activate the event.
  Future<Either<Failure, void>> submitAndActivate(int eventId);

  // ===========================================================================
  // EVENT DETAILS
  // ===========================================================================

  /// Save event details (name, date, time, venue).
  Future<Either<Failure, void>> saveEventDetails({
    required int eventId,
    required String name,
    required DateTime date,
    required String time,
    String? venueId,
    String? customLocation,
  });

  /// Load preview image for the invitation.
  Future<Either<Failure, String>> getPreviewImage(int eventId);
}
