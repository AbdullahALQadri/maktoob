import '../../domain/entities/identity_entities.dart';

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

int _int(dynamic v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0);

bool _bool(dynamic v) => v == true || v == 1 || v == '1' || v == 'true';

Map<String, dynamic>? _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : null;

class LegalNameModel extends LegalNameEntity {
  const LegalNameModel({
    super.firstAr,
    super.fatherAr,
    super.grandfatherAr,
    super.familyAr,
    super.fullAr,
    super.givenLatin,
    super.familyLatin,
    super.fullLatin,
  });

  /// `{ar: {first, father, grandfather, family, full}, latin: {given, family, full}}`.
  static LegalNameModel? tryParse(dynamic json) {
    final m = _map(json);
    if (m == null) return null;
    final ar = _map(m['ar']) ?? const {};
    final latin = _map(m['latin']) ?? _map(m['en']) ?? const {};
    final model = LegalNameModel(
      firstAr: _str(ar['first']),
      fatherAr: _str(ar['father']),
      grandfatherAr: _str(ar['grandfather']),
      familyAr: _str(ar['family']),
      fullAr: _str(ar['full']),
      givenLatin: _str(latin['given'] ?? latin['first']),
      familyLatin: _str(latin['family']),
      fullLatin: _str(latin['full']),
    );
    return model.isEmpty ? null : model;
  }
}

class IdentityStateModel extends IdentityStateEntity {
  const IdentityStateModel({
    super.status,
    super.verifiedAt,
    super.required,
    super.requiredReason,
    super.legalName,
    super.document,
    super.pendingSubmittedAt,
    super.pendingDocumentType,
    super.rejectionReason,
  });

  factory IdentityStateModel.fromJson(Map<String, dynamic> json) {
    final document = _map(json['document']);
    final pending = _map(json['pending']);
    return IdentityStateModel(
      status: IdentityStatus.fromString(_str(json['status'])),
      verifiedAt: _str(json['verified_at']),
      required: _bool(json['required']),
      requiredReason: _str(json['required_reason']),
      legalName: LegalNameModel.tryParse(json['legal_name']),
      document: document == null
          ? null
          : IdentityDocumentSummary(
              type: _str(document['type']) ?? 'national_id',
              country: _str(document['country']),
              last4: _str(document['last4']),
              expiresOn: _str(document['expires_on']),
            ),
      pendingSubmittedAt: pending == null ? null : (_str(pending['submitted_at']) ?? ''),
      pendingDocumentType: pending == null ? null : _str(pending['document_type']),
      rejectionReason: _str(json['rejection_reason']),
    );
  }

  /// Null on older backends that do not send `identity`.
  static IdentityStateModel? tryParse(dynamic json) {
    final m = _map(json);
    return m == null ? null : IdentityStateModel.fromJson(m);
  }
}

class IdentitySubmissionModel extends IdentitySubmissionEntity {
  const IdentitySubmissionModel({
    required super.id,
    required super.status,
    required super.documentType,
    super.documentCountry,
    super.last4,
    super.expiresOn,
    super.legalName,
    super.birthDate,
    super.hasBack,
    super.submittedAt,
    super.reviewedAt,
    super.rejectionReason,
  });

  factory IdentitySubmissionModel.fromJson(Map<String, dynamic> json) => IdentitySubmissionModel(
        id: _int(json['id']),
        status: _str(json['status']) ?? 'pending',
        documentType: _str(json['document_type']) ?? 'national_id',
        documentCountry: _str(json['document_country']),
        last4: _str(json['document_last4'] ?? json['last4']),
        expiresOn: _str(json['document_expires_on']),
        legalName: LegalNameModel.tryParse(json['legal_name']) ?? const LegalNameEntity(),
        birthDate: _str(json['birth_date']),
        hasBack: _bool(json['has_back']),
        submittedAt: _str(json['submitted_at']),
        reviewedAt: _str(json['reviewed_at']),
        rejectionReason: _str(json['rejection_reason']),
      );

  static List<IdentitySubmissionModel> listFrom(dynamic json) => json is List
      ? json.whereType<Map>().map((m) => IdentitySubmissionModel.fromJson(Map<String, dynamic>.from(m))).toList()
      : const [];
}

class IdentityOptionsModel extends IdentityOptionsEntity {
  const IdentityOptionsModel({
    super.documentTypes,
    super.countries,
    super.fourPartIdCountries,
    super.checkDigitIdCountries,
    super.minimumAge,
    super.maxFileKb,
  });

  static List<String> _codes(dynamic v, List<String> fallback) =>
      v is List ? v.map((e) => e.toString().toUpperCase()).toList() : fallback;

  factory IdentityOptionsModel.fromJson(Map<String, dynamic> json) {
    final types = json['document_types'];
    final countries = json['countries'];
    return IdentityOptionsModel(
      documentTypes: types is List
          ? types
              .map((t) => t is Map
                  ? IdentityOptionItem(key: _str(t['key']) ?? '', label: _str(t['label']) ?? _str(t['key']) ?? '')
                  : IdentityOptionItem(key: t.toString(), label: t.toString()))
              .where((t) => t.key.isNotEmpty)
              .toList()
          : const [],
      countries: countries is List
          ? countries
              .whereType<Map>()
              .map((c) => CountryOption(code: (_str(c['code']) ?? '').toUpperCase(), name: _str(c['name']) ?? _str(c['code']) ?? ''))
              .where((c) => c.code.length == 2)
              .toList()
          : const [],
      fourPartIdCountries: _codes(json['four_part_id_countries'], const ['PS']),
      checkDigitIdCountries: _codes(json['check_digit_id_countries'], const ['PS', 'IL']),
      minimumAge: json['minimum_age'] == null ? 18 : _int(json['minimum_age']),
      maxFileKb: json['max_file_kb'] == null ? 8192 : _int(json['max_file_kb']),
    );
  }
}

/// `GET /auth/identity` → `{success, message, data: {identity, submissions, options}}`.
class IdentityOverviewModel extends IdentityOverviewEntity {
  const IdentityOverviewModel({super.identity, super.submissions, super.options});

  factory IdentityOverviewModel.fromJson(dynamic body) {
    final data = _map(body is Map ? (body['data'] ?? body) : null) ?? const {};
    return IdentityOverviewModel(
      identity: IdentityStateModel.tryParse(data['identity']) ?? const IdentityStateEntity(),
      submissions: IdentitySubmissionModel.listFrom(data['submissions']),
      options: _map(data['options']) == null
          ? const IdentityOptionsEntity()
          : IdentityOptionsModel.fromJson(_map(data['options'])!),
    );
  }
}
