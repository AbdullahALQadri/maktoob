import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/event_type_fields_models.dart';
import '../../data/models/extra_service_model.dart';
import '../../data/models/invitation_draft_model.dart';
import '../../data/models/template_venue_models.dart';
import '../entities/wizard_results.dart';

typedef WizardResult<T> = Future<Either<Failure, T>>;

/// Everything the event wizard asks the server, step by step.
abstract class EventWizardRepository {
  WizardResult<WizardCatalogue> catalogue();
  WizardResult<List<TemplateModel>> templates(int eventTypeId);
  WizardResult<List<EventTypeFormField>> typeFields(int eventTypeId);

  /// Creates the draft event and returns its id.
  WizardResult<int> createDraft({int? eventTypeId, String? customTypeName, int? templateId, int? institutionId});
  WizardResult<WizardDraft> draft(int eventId);
  WizardResult<Unit> saveDetails(int eventId, WizardDetails details);

  /// The whole list: a guest left out is removed there too.
  WizardResult<Unit> saveGuests(int eventId, List<GuestInfoModel> guests);

  WizardResult<String?> editorUrl(int eventId);
  WizardResult<String?> designUrl(int eventId);

  WizardResult<Unit> saveInvitationConfig(int eventId, WizardInvitationConfig config);
  WizardResult<List<ExtraServiceModel>> services(int eventId);

  /// [levels]: service id => the level picked for it.
  WizardResult<Unit> saveServices(int eventId, List<int> serviceIds, Map<String, int> levels);

  WizardResult<WizardPackages> packages(int eventId);

  /// No package and not custom = clear the choice.
  WizardResult<Unit> selectPackage(int eventId, {int? packageId, bool custom = false, int? customInvitations});
  WizardResult<double?> customPackagePrice(int invitations);
  WizardResult<WizardInvoice> invoice(int eventId);

  WizardResult<WizardSaveResult> save(int eventId, {required bool asDraft});
  WizardResult<Unit> activate(int eventId);
}
