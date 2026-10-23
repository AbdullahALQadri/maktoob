import 'package:equatable/equatable.dart';

/// Approval status of an institution account.
enum InstitutionStatus {
  pending,
  approved,
  rejected,

  /// Approved before, then switched off by Maktoob staff.
  suspended;

  static InstitutionStatus? fromString(String? value) {
    switch (value) {
      case 'pending':
        return InstitutionStatus.pending;
      case 'approved':
        return InstitutionStatus.approved;
      case 'rejected':
        return InstitutionStatus.rejected;
      case 'suspended':
        return InstitutionStatus.suspended;
      default:
        return null;
    }
  }

  String get labelKey => 'institution_status_$name';
}

/// Verification document types accepted by the backend.
const List<String> kInstitutionDocumentTypes = [
  'registration_certificate',
  'tax_certificate',
  'authorization_letter',
  'other',
];

/// A private verification document (only the owner and staff can open it).
class InstitutionDocumentEntity extends Equatable {
  final int id;
  final String type;
  final String originalName;
  final int size;
  final String? uploadedAt;

  const InstitutionDocumentEntity({
    required this.id,
    required this.type,
    required this.originalName,
    this.size = 0,
    this.uploadedAt,
  });

  @override
  List<Object?> get props => [id, type, originalName, size, uploadedAt];
}

/// What the review needs, as reported by the backend.
class InstitutionVerification extends Equatable {
  final bool name;
  final bool sector;
  final bool logo;
  final bool registrationDocument;
  final bool declaration;

  const InstitutionVerification({
    this.name = false,
    this.sector = false,
    this.logo = false,
    this.registrationDocument = false,
    this.declaration = false,
  });

  /// Required items (the logo is recommended, not required).
  bool get isComplete => name && sector && registrationDocument && declaration;

  @override
  List<Object?> get props => [name, sector, logo, registrationDocument, declaration];
}

/// Identity edits on an approved institution, held until staff review them.
class InstitutionPendingChanges extends Equatable {
  /// Column → requested value (name_ar, name_en, sector, registration_number,
  /// tax_number, website).
  final Map<String, String?> fields;
  final String? logoUrl;
  final String? submittedAt;

  const InstitutionPendingChanges({this.fields = const {}, this.logoUrl, this.submittedAt});

  @override
  List<Object?> get props => [fields, logoUrl, submittedAt];
}

/// The institution (company / association) owned by the logged-in client.
class InstitutionEntity extends Equatable {
  final int id;
  final InstitutionStatus status;
  final String nameAr;
  final String? nameEn;
  final String? sector;
  final String? contactPerson;
  final String? contactPhone;
  final String? registrationNumber;
  final String? logoUrl;
  final String? rejectionReason;
  final double discountPercent;
  final int invitationCredits;
  final String? taxNumber;
  final String? website;
  final String? officialEmail;
  final String? governorate;
  final String? address;
  final String? description;
  final String? suspensionReason;
  final bool declarationAccepted;
  final InstitutionVerification verification;
  final List<InstitutionDocumentEntity> documents;
  final InstitutionPendingChanges? pendingChanges;

  const InstitutionEntity({
    required this.id,
    required this.status,
    required this.nameAr,
    this.nameEn,
    this.sector,
    this.contactPerson,
    this.contactPhone,
    this.registrationNumber,
    this.logoUrl,
    this.rejectionReason,
    this.discountPercent = 0,
    this.invitationCredits = 0,
    this.taxNumber,
    this.website,
    this.officialEmail,
    this.governorate,
    this.address,
    this.description,
    this.suspensionReason,
    this.declarationAccepted = false,
    this.verification = const InstitutionVerification(),
    this.documents = const [],
    this.pendingChanges,
  });

  bool get isApproved => status == InstitutionStatus.approved;

  bool get isSuspended => status == InstitutionStatus.suspended;

  /// Approved or suspended: identity edits go to review instead of applying.
  bool get isIdentityLocked => isApproved || isSuspended;

  /// Documents can be removed only before approval (they are the evidence).
  bool get canDeleteDocuments => !isIdentityLocked;

  /// The value the owner last asked for (pending) or the live one.
  String? requested(String column, String? live) =>
      pendingChanges != null && pendingChanges!.fields.containsKey(column)
          ? pendingChanges!.fields[column]
          : live;

  String displayName(bool isArabic) =>
      (!isArabic && (nameEn ?? '').isNotEmpty) ? nameEn! : nameAr;

  @override
  List<Object?> get props => [
        id,
        status,
        nameAr,
        nameEn,
        sector,
        contactPerson,
        contactPhone,
        registrationNumber,
        logoUrl,
        rejectionReason,
        discountPercent,
        invitationCredits,
        taxNumber,
        website,
        officialEmail,
        governorate,
        address,
        description,
        suspensionReason,
        declarationAccepted,
        verification,
        documents,
        pendingChanges,
      ];
}

/// An accepted membership of the logged-in client in someone's institution.
class InstitutionMembershipEntity extends Equatable {
  final int membershipId;
  final int institutionId;
  final String institutionName;
  final InstitutionStatus? institutionStatus;
  final int? ownerClientId;

  /// manager | door_staff | viewer
  final String role;

  const InstitutionMembershipEntity({
    required this.membershipId,
    required this.institutionId,
    required this.institutionName,
    this.institutionStatus,
    this.ownerClientId,
    required this.role,
  });

  bool get isApproved => institutionStatus == InstitutionStatus.approved;

  @override
  List<Object?> get props =>
      [membershipId, institutionId, institutionName, institutionStatus, ownerClientId, role];
}

/// A team member as the owner sees it.
class InstitutionMemberEntity extends Equatable {
  final int id;
  final String phone;
  final String role;
  final String? name;

  /// invited | active
  final String status;
  final String? invitedAt;
  final String? acceptedAt;

  const InstitutionMemberEntity({
    required this.id,
    required this.phone,
    required this.role,
    this.name,
    this.status = 'invited',
    this.invitedAt,
    this.acceptedAt,
  });

  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [id, phone, role, name, status, invitedAt, acceptedAt];
}

/// An invitation to join another institution's team.
class PendingInviteEntity extends Equatable {
  final int id;
  final String role;
  final int? institutionId;
  final String institutionName;
  final String? invitedAt;

  const PendingInviteEntity({
    required this.id,
    required this.role,
    this.institutionId,
    required this.institutionName,
    this.invitedAt,
  });

  @override
  List<Object?> get props => [id, role, institutionId, institutionName, invitedAt];
}

/// `GET /institution`.
class InstitutionOverviewEntity extends Equatable {
  final bool isInstitutionAccount;
  final InstitutionEntity? institution;
  final List<InstitutionMembershipEntity> memberships;
  final List<PendingInviteEntity> pendingInvites;

  const InstitutionOverviewEntity({
    this.isInstitutionAccount = false,
    this.institution,
    this.memberships = const [],
    this.pendingInvites = const [],
  });

  @override
  List<Object?> get props => [isInstitutionAccount, institution, memberships, pendingInvites];
}

class CreditTransactionEntity extends Equatable {
  final int id;

  /// topup | usage | adjustment
  final String type;
  final int amount;
  final int balanceAfter;
  final int? eventId;
  final String? note;
  final DateTime? createdAt;

  const CreditTransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.eventId,
    this.note,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, amount, balanceAfter, eventId, note, createdAt];
}

/// `GET /institution/credits`.
class InstitutionCreditsEntity extends Equatable {
  final int balance;
  final double discountPercent;
  final List<CreditTransactionEntity> transactions;

  const InstitutionCreditsEntity({
    required this.balance,
    this.discountPercent = 0,
    this.transactions = const [],
  });

  @override
  List<Object?> get props => [balance, discountPercent, transactions];
}

/// Fields sent to `POST /institution/profile` (and register).
class InstitutionProfileInput extends Equatable {
  final String nameAr;
  final String? nameEn;
  final String? sector;
  final String? contactPerson;
  final String? contactPhone;
  final String? registrationNumber;
  final String? taxNumber;
  final String? website;
  final String? officialEmail;
  final String? governorate;
  final String? address;
  final String? description;

  /// The owner confirmed they may represent the organization and the data is accurate.
  final bool declaration;

  /// Local file path of a new logo (jpg/png/webp, max 2 MB, ≥128×128).
  final String? logoPath;

  /// When true, optional fields are always sent (an empty value clears them).
  /// Registration leaves it false and sends only what was filled in.
  final bool sendEmpty;

  const InstitutionProfileInput({
    required this.nameAr,
    this.nameEn,
    this.sector,
    this.contactPerson,
    this.contactPhone,
    this.registrationNumber,
    this.taxNumber,
    this.website,
    this.officialEmail,
    this.governorate,
    this.address,
    this.description,
    this.declaration = false,
    this.logoPath,
    this.sendEmpty = false,
  });

  Map<String, dynamic> toFields() {
    final optional = <String, String?>{
      'organization_name_en': nameEn,
      'sector': sector,
      'contact_person': contactPerson,
      'contact_phone': contactPhone,
      'registration_number': registrationNumber,
      'tax_number': taxNumber,
      'website': website,
      'official_email': officialEmail,
      'governorate': governorate,
      'address': address,
      'description': description,
    };
    return {
      'organization_name_ar': nameAr,
      for (final e in optional.entries)
        if (sendEmpty || (e.value ?? '').trim().isNotEmpty) e.key: (e.value ?? '').trim(),
      if (declaration) 'declaration': '1',
    };
  }

  @override
  List<Object?> get props => [
        nameAr,
        nameEn,
        sector,
        contactPerson,
        contactPhone,
        registrationNumber,
        taxNumber,
        website,
        officialEmail,
        governorate,
        address,
        description,
        declaration,
        logoPath,
        sendEmpty,
      ];
}

/// Sectors accepted by the backend (`Institution::SECTORS`).
const List<String> kInstitutionSectors = [
  'company',
  'association',
  'ngo',
  'education',
  'government',
  'health',
  'other',
];

/// Palestinian governorates: stored value (English, as the backend keeps it)
/// → Arabic label. Mirrors `Institution::GOVERNORATES`.
const Map<String, String> kPalestineGovernorates = {
  'Gaza': 'غزة',
  'North Gaza': 'شمال غزة',
  'Deir al-Balah': 'دير البلح',
  'Khan Younis': 'خان يونس',
  'Rafah': 'رفح',
  'Jerusalem': 'القدس',
  'Ramallah and al-Bireh': 'رام الله والبيرة',
  'Bethlehem': 'بيت لحم',
  'Hebron': 'الخليل',
  'Jericho': 'أريحا',
  'Nablus': 'نابلس',
  'Jenin': 'جنين',
  'Tulkarm': 'طولكرم',
  'Qalqilya': 'قلقيلية',
  'Salfit': 'سلفيت',
  'Tubas': 'طوباس',
};

/// Roles an owner can give a team member.
const List<String> kInstitutionMemberRoles = ['manager', 'door_staff', 'viewer'];
