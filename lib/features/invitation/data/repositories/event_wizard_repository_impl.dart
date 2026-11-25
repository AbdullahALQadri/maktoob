import 'package:dartz/dartz.dart';

import '../../../../core/api/event_wizard_api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/free_trial_refusal.dart';
import '../../../../core/error/institution_errors.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/wizard_results.dart';
import '../../domain/repositories/event_wizard_repository.dart';
import '../models/event_type_fields_models.dart';
import '../models/event_type_model.dart';
import '../models/extra_service_model.dart';
import '../models/invitation_draft_model.dart';
import '../models/package_model.dart';
import '../models/template_venue_models.dart';
import 'wizard_parsers.dart';

class EventWizardRepositoryImpl implements EventWizardRepository {
  EventWizardRepositoryImpl(this._api);

  final EventWizardApiService _api;

  static List<Map<String, dynamic>> _maps(dynamic list) =>
      [for (final item in list is List ? list : const []) if (item is Map) Map<String, dynamic>.from(item)];

  static Map _data(Map<String, dynamic> response) => response['data'] is Map ? response['data'] as Map : const {};

  @override
  WizardResult<WizardCatalogue> catalogue() => guardCall(() async {
        final data = _data(await _api.getEventTypes());
        return WizardCatalogue(
          types: _maps(data['event_types']).map(EventTypeModel.fromJson).toList(),
          // Absent on older backends.
          groups: _maps(data['groups']).map(EventTypeGroupModel.fromJson).toList(),
        );
      });

  @override
  WizardResult<List<TemplateModel>> templates(int eventTypeId) => guardCall(() async {
        final data = _data(await _api.getTemplatesForEventType(eventTypeId));
        return _maps(data['templates']).map(TemplateModel.fromJson).toList();
      });

  @override
  WizardResult<List<EventTypeFormField>> typeFields(int eventTypeId) => guardCall(() async {
        return EventTypeFormField.listFromJson(_data(await _api.getAiFormFields(eventTypeId))['fields']);
      });

  @override
  WizardResult<int> createDraft({int? eventTypeId, String? customTypeName, int? templateId, int? institutionId}) =>
      guardCall(() async {
        final response = await _api.initializeWizard(
          eventTypeId: eventTypeId,
          customEventTypeName: customTypeName,
          templateId: templateId,
          institutionId: institutionId,
        );
        final id = parseInt(_data(response)['event_id']);
        if (id == null) throw const ServerException(message: 'invitation_failed_create_draft');
        return id;
      });

  @override
  WizardResult<WizardDraft> draft(int eventId) => guardCall(() async {
        final draft = parseDraft(await _api.getWizardState(eventId), eventId);
        if (draft == null) throw const ServerException(message: 'invitation_failed_create_draft');
        return draft;
      });

  @override
  WizardResult<Unit> saveDetails(int eventId, WizardDetails d) => _done(() => _api.saveEventDetails(
        eventId,
        titleAr: d.title,
        descriptionAr: d.description,
        eventDate: d.date,
        eventTime: d.time,
        eventEndDate: d.endDate,
        venueId: d.venueId,
        customVenueNameAr: d.place,
        // The typed line holds the whole place: an older separate address is cleared.
        customVenueAddressAr: d.place == null ? null : '',
        customVenueLat: d.latitude,
        customVenueLng: d.longitude,
        partnerCount: d.companions,
        eventTypeFormValues: d.formValues,
      ));

  @override
  WizardResult<Unit> saveGuests(int eventId, List<GuestInfoModel> guests) => _done(
        () => _api.addManualGuests(eventId, [for (final g in guests) {'name': g.name, 'phone': g.phone}]),
      );

  @override
  WizardResult<String?> editorUrl(int eventId) => guardCall(() => _api.getDesignerUrl(eventId));

  @override
  WizardResult<String?> designUrl(int eventId) =>
      guardCall(() async => designUrlOf(_data(await _api.getWizardState(eventId))['event']));

  @override
  WizardResult<Unit> saveInvitationConfig(int eventId, WizardInvitationConfig c) => _done(
        () => _api.saveInvitationConfig(
          eventId,
          defaultDeliveryMethod: c.deliveryMethod,
          allowCompanions: c.companions > 0,
          maxCompanions: c.companions,
          requireResponse: c.requireResponse,
          responseDeadline: c.replyDeadline,
          messageAr: c.message,
        ),
      );

  @override
  WizardResult<List<ExtraServiceModel>> services(int eventId) => guardCall(() async {
        return _maps(_data(await _api.getExtraServices(eventId))['services']).map(ExtraServiceModel.fromJson).toList();
      });

  @override
  WizardResult<Unit> saveServices(int eventId, List<int> serviceIds, Map<String, int> levels) =>
      _done(() => _api.saveExtraServices(eventId, serviceIds, options: levels));

  @override
  WizardResult<WizardPackages> packages(int eventId) => guardCall(() async {
        final data = _data(await _api.getPackages(eventId));
        return WizardPackages(
          packages: _maps(data['packages']).map(PackageModel.fromJson).toList(),
          freeTrialAvailable: data['free_trial_available'] as bool? ?? true,
          suggestedPackageId: parseInt(data['suggested_package_id']),
        );
      });

  @override
  WizardResult<Unit> selectPackage(int eventId, {int? packageId, bool custom = false, int? customInvitations}) =>
      _done(() => _api.selectPackage(
            eventId,
            packageId: custom ? null : packageId,
            isCustomPackage: custom,
            customGuestCount: custom ? customInvitations : null,
          ));

  @override
  WizardResult<double?> customPackagePrice(int invitations) => guardCall(() async {
        final calculation = _data(await _api.calculateCustomPackage(invitations))['calculation'];
        return double.tryParse('${calculation is Map ? calculation['total'] : ''}');
      });

  @override
  WizardResult<WizardInvoice> invoice(int eventId) =>
      guardCall(() async => parseInvoice(await _api.getInvoiceSummary(eventId)));

  @override
  WizardResult<WizardSaveResult> save(int eventId, {required bool asDraft}) async {
    try {
      final data = (await _api.saveEvent(eventId, isDraft: asDraft))['data'];
      // A draft answers with the event itself; a final save nests it.
      final event = data is Map && data['event'] is Map ? data['event'] as Map : data;
      final total = data is Map ? data['invoice_total'] ?? (event is Map ? event['invoice_total'] : null) : null;
      return Right(WizardSaveResult(
        eventId: parseInt(event is Map ? event['id'] : null) ?? eventId,
        invoiceTotal: total == null ? null : double.tryParse('$total'),
        creditsCover: data is Map && data['credits_cover'] == true,
      ));
    } catch (e) {
      final freeTrial = isFreeTrialRefusal(e);
      final institution = isInstitutionNotApproved(e);
      if (!freeTrial && !institution) return guardCall(() => throw e);
      return Left(WizardRefusedFailure(
        message: freeTrial ? freeTrialRefusalMessage(e) ?? '$e' : kInstitutionNotApprovedMessageKey,
        freeTrialUsed: freeTrial,
        institutionNotApproved: institution,
      ));
    }
  }

  @override
  WizardResult<Unit> activate(int eventId) => _done(() => _api.activateEvent(eventId));

  WizardResult<Unit> _done(Future<dynamic> Function() call) => guardCall(() async {
        await call();
        return unit;
      });
}
