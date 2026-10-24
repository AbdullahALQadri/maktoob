import 'package:equatable/equatable.dart';

/// The client's identity verification (KYC) state, from `client.identity`.
///
/// Separate from `is_verified`, which only means the mobile number was
/// confirmed by code.
enum IdentityStatus {
  none,
  pending,
  verified,
  rejected;

  static IdentityStatus fromString(String? value) {
    switch (value) {
      case 'pending':
        return IdentityStatus.pending;
      case 'verified':
        return IdentityStatus.verified;
      case 'rejected':
        return IdentityStatus.rejected;
      default:
        return IdentityStatus.none;
    }
  }

  String get labelKey => 'identity_status_$name';
}

/// Identity document types accepted by the backend.
const List<String> kIdentityDocumentTypes = ['national_id', 'passport', 'residence_permit'];

/// The legal name as printed on the document, in parts.
class LegalNameEntity extends Equatable {
  final String? firstAr;
  final String? fatherAr;
  final String? grandfatherAr;
  final String? familyAr;
  final String? fullAr;
  final String? givenLatin;
  final String? familyLatin;
  final String? fullLatin;

  const LegalNameEntity({
    this.firstAr,
    this.fatherAr,
    this.grandfatherAr,
    this.familyAr,
    this.fullAr,
    this.givenLatin,
    this.familyLatin,
    this.fullLatin,
  });

  String get arabic => (fullAr ?? '').isNotEmpty
      ? fullAr!
      : [firstAr, fatherAr, grandfatherAr, familyAr].whereType<String>().where((s) => s.isNotEmpty).join(' ');

  String get latin => (fullLatin ?? '').isNotEmpty
      ? fullLatin!
      : [givenLatin, familyLatin].whereType<String>().where((s) => s.isNotEmpty).join(' ');

  /// The name in the script that suits the locale, else the other one.
  String display(bool isArabic) {
    final first = isArabic ? arabic : latin;
    return first.isNotEmpty ? first : (isArabic ? latin : arabic);
  }

  bool get isEmpty => arabic.isEmpty && latin.isEmpty;

  @override
  List<Object?> get props =>
      [firstAr, fatherAr, grandfatherAr, familyAr, fullAr, givenLatin, familyLatin, fullLatin];
}

/// The approved document in force (never the full number).
class IdentityDocumentSummary extends Equatable {
  final String type;
  final String? country;
  final String? last4;
  final String? expiresOn;

  const IdentityDocumentSummary({required this.type, this.country, this.last4, this.expiresOn});

  @override
  List<Object?> get props => [type, country, last4, expiresOn];
}

/// `client.identity` in every account payload.
class IdentityStateEntity extends Equatable {
  final IdentityStatus status;
  final String? verifiedAt;

  /// Staff asked for verification; the client's events cannot be activated until done.
  final bool required;
  final String? requiredReason;
  final LegalNameEntity? legalName;
  final IdentityDocumentSummary? document;

  /// A submission waiting for review (also while an older one is verified).
  final String? pendingSubmittedAt;
  final String? pendingDocumentType;
  final String? rejectionReason;

  const IdentityStateEntity({
    this.status = IdentityStatus.none,
    this.verifiedAt,
    this.required = false,
    this.requiredReason,
    this.legalName,
    this.document,
    this.pendingSubmittedAt,
    this.pendingDocumentType,
    this.rejectionReason,
  });

  bool get isVerified => status == IdentityStatus.verified;

  bool get hasPending => pendingSubmittedAt != null || status == IdentityStatus.pending;

  @override
  List<Object?> get props => [
        status,
        verifiedAt,
        required,
        requiredReason,
        legalName,
        document,
        pendingSubmittedAt,
        pendingDocumentType,
        rejectionReason,
      ];
}

/// One of the client's submissions (`GET /auth/identity` → `submissions`).
class IdentitySubmissionEntity extends Equatable {
  final int id;

  /// pending | approved | rejected | cancelled | superseded
  final String status;
  final String documentType;
  final String? documentCountry;
  final String? last4;
  final String? expiresOn;
  final LegalNameEntity legalName;
  final String? birthDate;
  final bool hasBack;
  final String? submittedAt;
  final String? reviewedAt;
  final String? rejectionReason;

  const IdentitySubmissionEntity({
    required this.id,
    required this.status,
    required this.documentType,
    this.documentCountry,
    this.last4,
    this.expiresOn,
    this.legalName = const LegalNameEntity(),
    this.birthDate,
    this.hasBack = false,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        documentType,
        documentCountry,
        last4,
        expiresOn,
        legalName,
        birthDate,
        hasBack,
        submittedAt,
        reviewedAt,
        rejectionReason,
      ];
}

class IdentityOptionItem extends Equatable {
  final String key;
  final String label;

  const IdentityOptionItem({required this.key, required this.label});

  @override
  List<Object?> get props => [key, label];
}

class CountryOption extends Equatable {
  final String code;
  final String name;

  const CountryOption({required this.code, required this.name});

  @override
  List<Object?> get props => [code, name];
}

/// What the form needs (`GET /auth/identity` → `options`), with safe defaults.
class IdentityOptionsEntity extends Equatable {
  final List<IdentityOptionItem> documentTypes;
  final List<CountryOption> countries;
  final List<String> fourPartIdCountries;
  final List<String> checkDigitIdCountries;
  final int minimumAge;
  final int maxFileKb;

  const IdentityOptionsEntity({
    this.documentTypes = const [],
    this.countries = const [],
    this.fourPartIdCountries = const ['PS'],
    this.checkDigitIdCountries = const ['PS', 'IL'],
    this.minimumAge = 18,
    this.maxFileKb = 8192,
  });

  String countryName(String? code) {
    if (code == null) return '';
    for (final c in countries) {
      if (c.code == code) return c.name;
    }
    return code;
  }

  @override
  List<Object?> get props =>
      [documentTypes, countries, fourPartIdCountries, checkDigitIdCountries, minimumAge, maxFileKb];
}

/// `GET /auth/identity`.
class IdentityOverviewEntity extends Equatable {
  final IdentityStateEntity identity;
  final List<IdentitySubmissionEntity> submissions;
  final IdentityOptionsEntity options;

  const IdentityOverviewEntity({
    this.identity = const IdentityStateEntity(),
    this.submissions = const [],
    this.options = const IdentityOptionsEntity(),
  });

  IdentityOverviewEntity copyWith({IdentityStateEntity? identity, List<IdentitySubmissionEntity>? submissions}) =>
      IdentityOverviewEntity(
        identity: identity ?? this.identity,
        submissions: submissions ?? this.submissions,
        options: options,
      );

  @override
  List<Object?> get props => [identity, submissions, options];
}

/// Fields sent to `POST /auth/identity` (multipart).
class IdentitySubmissionInput extends Equatable {
  final String documentType;
  final String documentCountry;
  final String documentNumber;

  /// Y-m-d, optional (after today when given).
  final String? documentExpiresOn;
  final String firstNameAr;
  final String fatherNameAr;
  final String grandfatherNameAr;
  final String familyNameAr;
  final String givenNamesLatin;
  final String familyNameLatin;

  /// Y-m-d.
  final String birthDate;

  /// Local paths of the document photos / scans.
  final String frontPath;
  final String? backPath;

  const IdentitySubmissionInput({
    required this.documentType,
    required this.documentCountry,
    required this.documentNumber,
    this.documentExpiresOn,
    this.firstNameAr = '',
    this.fatherNameAr = '',
    this.grandfatherNameAr = '',
    this.familyNameAr = '',
    this.givenNamesLatin = '',
    this.familyNameLatin = '',
    required this.birthDate,
    required this.frontPath,
    this.backPath,
  });

  /// Text fields of the request (the files are added by the data source).
  Map<String, String> toFields() {
    final names = {
      'first_name_ar': firstNameAr,
      'father_name_ar': fatherNameAr,
      'grandfather_name_ar': grandfatherNameAr,
      'family_name_ar': familyNameAr,
      'given_names_latin': givenNamesLatin,
      'family_name_latin': familyNameLatin,
    };
    return {
      'document_type': documentType,
      'document_country': documentCountry,
      'document_number': documentNumber,
      if ((documentExpiresOn ?? '').isNotEmpty) 'document_expires_on': documentExpiresOn!,
      for (final e in names.entries)
        if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
      'birth_date': birthDate,
      'declaration': '1',
    };
  }

  @override
  List<Object?> get props => [
        documentType,
        documentCountry,
        documentNumber,
        documentExpiresOn,
        firstNameAr,
        fatherNameAr,
        grandfatherNameAr,
        familyNameAr,
        givenNamesLatin,
        familyNameLatin,
        birthDate,
        frontPath,
        backPath,
      ];
}
