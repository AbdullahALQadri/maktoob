import 'package:equatable/equatable.dart';

/// An identity a client sent for verification. The document number never
/// reaches the phone: only its last four digits.
class StaffIdentity extends Equatable {
  const StaffIdentity({
    required this.id,
    required this.status,
    this.clientName,
    this.clientPhone,
    this.nameAr = '',
    this.nameLatin = '',
    this.documentType,
    this.documentCountry,
    this.documentLast4,
    this.birthDate,
    this.expiresOn,
    this.hasFront = false,
    this.hasBack = false,
    this.sameIdElsewhere = false,
    this.sameNameAccounts = 0,
    this.rejectionReason,
  });

  final int id;

  /// `pending`, `approved`, `rejected`, `cancelled` or `superseded`.
  final String status;
  final String? clientName;
  final String? clientPhone;

  /// The legal name as printed on the document.
  final String nameAr;
  final String nameLatin;
  final String? documentType;
  final String? documentCountry;
  final String? documentLast4;
  final String? birthDate;
  final String? expiresOn;
  final bool hasFront;
  final bool hasBack;

  /// The same document is on another account.
  final bool sameIdElsewhere;

  /// Other accounts with the same legal name (namesakes are common).
  final int sameNameAccounts;
  final String? rejectionReason;

  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
        id,
        status,
        clientName,
        clientPhone,
        nameAr,
        nameLatin,
        documentType,
        documentCountry,
        documentLast4,
        birthDate,
        expiresOn,
        hasFront,
        hasBack,
        sameIdElsewhere,
        sameNameAccounts,
        rejectionReason,
      ];
}

class StaffDocument extends Equatable {
  const StaffDocument({required this.id, required this.name, this.type, this.mime});

  final int id;
  final String name;
  final String? type;
  final String? mime;

  /// Something the phone can show; a PDF is opened on the web dashboard.
  bool get isImage => (mime ?? '').startsWith('image/');

  @override
  List<Object?> get props => [id, name, type, mime];
}

/// An institution asking to be approved, with what approval still needs.
class StaffInstitution extends Equatable {
  const StaffInstitution({
    required this.id,
    required this.status,
    this.nameAr,
    this.nameEn,
    this.tradeName,
    this.sector,
    this.ownerName,
    this.ownerPhone,
    this.legalForm,
    this.registrationNumber,
    this.registrationCountry,
    this.representativeRole,
    this.ownerIdentityStatus,
    this.checklist = const {},
    this.documents = const [],
    this.rejectionReason,
  });

  final int id;
  final String status;
  final String? nameAr;
  final String? nameEn;
  final String? tradeName;
  final String? sector;
  final String? ownerName;
  final String? ownerPhone;
  final String? legalForm;
  final String? registrationNumber;
  final String? registrationCountry;
  final String? representativeRole;
  final String? ownerIdentityStatus;

  /// Requirement => met. Approval is refused while one is missing.
  final Map<String, bool> checklist;
  final List<StaffDocument> documents;
  final String? rejectionReason;

  bool get isPending => status == 'pending';

  String get name => nameAr ?? nameEn ?? '#$id';

  @override
  List<Object?> get props => [
        id,
        status,
        nameAr,
        nameEn,
        tradeName,
        sector,
        ownerName,
        ownerPhone,
        legalForm,
        registrationNumber,
        registrationCountry,
        representativeRole,
        ownerIdentityStatus,
        checklist,
        documents,
        rejectionReason,
      ];
}
