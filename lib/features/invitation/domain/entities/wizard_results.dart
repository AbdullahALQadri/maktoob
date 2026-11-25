import '../../../../core/error/failures.dart';
import '../../data/models/event_type_fields_models.dart';
import '../../data/models/event_type_model.dart';
import '../../data/models/invitation_draft_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/package_model.dart';

/// The occasions a host can pick from, and the groups they sit in.
class WizardCatalogue {
  const WizardCatalogue({this.types = const [], this.groups = const []});

  final List<EventTypeModel> types;
  final List<EventTypeGroupModel> groups;
}

/// A draft as the server holds it, read when the host comes back to it.
class WizardDraft {
  const WizardDraft({
    required this.id,
    this.title,
    this.description,
    this.date,
    this.endDate,
    this.typeId,
    this.type,
    this.formValues = const {},
    this.latitude,
    this.longitude,
    this.place = '',
    this.companions,
    this.replyDeadline,
    this.message,
    this.guests = const [],
    this.designUrl,
    this.deliveryMethod = 'whatsapp',
    this.requireResponse = true,
  });

  final int id;
  final String? title;
  final String? description;
  final DateTime? date;
  final DateTime? endDate;
  final int? typeId;

  /// The occasion as saved with the event, when it is not in the catalogue.
  final EventTypeModel? type;
  final Map<String, dynamic> formValues;
  final double? latitude;
  final double? longitude;
  final String place;
  final int? companions;
  final DateTime? replyDeadline;
  final String? message;
  final List<GuestInfoModel> guests;
  final String? designUrl;
  final String deliveryMethod;
  final bool requireResponse;
}

/// Step 1, as it is sent.
class WizardDetails {
  const WizardDetails({
    required this.title,
    required this.date,
    this.description,
    this.time,
    this.endDate,
    this.venueId,
    this.place,
    this.latitude,
    this.longitude,
    this.companions,
    this.formValues = const {},
  });

  /// Empty lets the backend write a title from the occasion's names.
  final String title;
  final String? description;
  final DateTime date;

  /// `HH:mm`.
  final String? time;
  final DateTime? endDate;
  final int? venueId;

  /// The typed line holds the whole place; null leaves the place untouched.
  final String? place;
  final double? latitude;
  final double? longitude;
  final int? companions;
  final Map<String, dynamic> formValues;
}

/// Step 4: how the invitation goes out and how guests reply.
class WizardInvitationConfig {
  const WizardInvitationConfig({
    required this.deliveryMethod,
    required this.requireResponse,
    this.companions = 0,
    this.replyDeadline,
    this.message,
  });

  final String deliveryMethod;
  final bool requireResponse;
  final int companions;
  final DateTime? replyDeadline;

  /// Null keeps the message already saved.
  final String? message;
}

class WizardPackages {
  const WizardPackages({this.packages = const [], this.freeTrialAvailable = true, this.suggestedPackageId});

  final List<PackageModel> packages;
  final bool freeTrialAvailable;
  final int? suggestedPackageId;
}

class WizardInvoice {
  const WizardInvoice({required this.summary, this.whatsappNumber});

  final InvoiceSummaryModel summary;

  /// Where the invoice may be shared; null when Maktoob set no number.
  final String? whatsappNumber;
}

/// What the final save answered.
class WizardSaveResult {
  const WizardSaveResult({required this.eventId, this.invoiceTotal, this.creditsCover = false});

  final int eventId;
  final double? invoiceTotal;

  /// The institution's prepaid balance pays for it: activate, no payment.
  final bool creditsCover;
}

/// The server refused a save for a reason the host can act on.
class WizardRefusedFailure extends ValidationFailure {
  const WizardRefusedFailure({required super.message, this.freeTrialUsed = false, this.institutionNotApproved = false});

  final bool freeTrialUsed;
  final bool institutionNotApproved;

  @override
  List<Object?> get props => [...super.props, freeTrialUsed, institutionNotApproved];
}
