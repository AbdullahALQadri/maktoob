import '../../domain/entities/institution_entity.dart';

int _int(dynamic v, [int fallback = 0]) =>
    v is int ? v : (v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? fallback);

int? _intOrNull(dynamic v) =>
    v == null ? null : (v is int ? v : (v is num ? v.toInt() : int.tryParse('$v')));

double _double(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

Map<String, dynamic> _dataOf(dynamic body) {
  if (body is Map && body['data'] is Map) return Map<String, dynamic>.from(body['data']);
  if (body is Map) return Map<String, dynamic>.from(body);
  return const {};
}

class InstitutionModel extends InstitutionEntity {
  const InstitutionModel({
    required super.id,
    required super.status,
    required super.nameAr,
    super.nameEn,
    super.sector,
    super.contactPerson,
    super.contactPhone,
    super.registrationNumber,
    super.logoUrl,
    super.rejectionReason,
    super.discountPercent,
    super.invitationCredits,
    super.taxNumber,
    super.website,
    super.officialEmail,
    super.governorate,
    super.address,
    super.description,
    super.suspensionReason,
    super.declarationAccepted,
    super.verification,
    super.documents,
    super.pendingChanges,
  });

  static InstitutionVerification _verification(dynamic v) {
    if (v is! Map) return const InstitutionVerification();
    bool b(String k) => v[k] == true || v[k] == 1;
    return InstitutionVerification(
      name: b('name'),
      sector: b('sector'),
      logo: b('logo'),
      registrationDocument: b('registration_document'),
      declaration: b('declaration'),
    );
  }

  static List<InstitutionDocumentEntity> _documents(dynamic v) {
    if (v is! List) return const [];
    return v
        .whereType<Map>()
        .map((d) => InstitutionDocumentEntity(
              id: _int(d['id']),
              type: _str(d['type']) ?? 'other',
              originalName: _str(d['original_name']) ?? '',
              size: _int(d['size']),
              uploadedAt: _str(d['uploaded_at']),
            ))
        .toList();
  }

  static InstitutionPendingChanges? _pending(dynamic v) {
    if (v is! Map) return null;
    final fields = v['fields'] is Map
        ? Map<String, dynamic>.from(v['fields']).map((k, val) => MapEntry(k, val?.toString()))
        : <String, String?>{};
    final logo = _str(v['logo_url']);
    if (fields.isEmpty && logo == null) return null;
    return InstitutionPendingChanges(fields: fields, logoUrl: logo, submittedAt: _str(v['submitted_at']));
  }

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      taxNumber: _str(json['tax_number']),
      website: _str(json['website']),
      officialEmail: _str(json['official_email']),
      governorate: _str(json['governorate']),
      address: _str(json['address']),
      description: _str(json['description']),
      suspensionReason: _str(json['suspension_reason']),
      declarationAccepted: _str(json['declaration_accepted_at']) != null,
      verification: _verification(json['verification']),
      documents: _documents(json['documents']),
      pendingChanges: _pending(json['pending_changes']),
      id: _int(json['id']),
      status: InstitutionStatus.fromString(_str(json['status'])) ?? InstitutionStatus.pending,
      nameAr: _str(json['name_ar']) ?? _str(json['name']) ?? _str(json['name_en']) ?? '',
      nameEn: _str(json['name_en']),
      sector: _str(json['sector']),
      contactPerson: _str(json['contact_person']),
      contactPhone: _str(json['contact_phone']),
      registrationNumber: _str(json['registration_number']),
      logoUrl: _str(json['logo_url']),
      rejectionReason: _str(json['rejection_reason']),
      discountPercent: _double(json['discount_percent']),
      invitationCredits: _int(json['invitation_credits']),
    );
  }

  static InstitutionModel? tryParse(dynamic json) =>
      json is Map ? InstitutionModel.fromJson(Map<String, dynamic>.from(json)) : null;
}

class InstitutionMembershipModel extends InstitutionMembershipEntity {
  const InstitutionMembershipModel({
    required super.membershipId,
    required super.institutionId,
    required super.institutionName,
    super.institutionStatus,
    super.ownerClientId,
    required super.role,
  });

  factory InstitutionMembershipModel.fromJson(Map<String, dynamic> json) {
    return InstitutionMembershipModel(
      membershipId: _int(json['membership_id'] ?? json['id']),
      institutionId: _int(json['institution_id']),
      institutionName: _str(json['institution_name']) ?? '',
      institutionStatus: InstitutionStatus.fromString(_str(json['institution_status'])),
      ownerClientId: _intOrNull(json['owner_client_id']),
      role: _str(json['role']) ?? 'viewer',
    );
  }

  static List<InstitutionMembershipModel> listFrom(dynamic json) => json is List
      ? json
          .whereType<Map>()
          .map((m) => InstitutionMembershipModel.fromJson(Map<String, dynamic>.from(m)))
          .toList()
      : const [];
}

class InstitutionMemberModel extends InstitutionMemberEntity {
  const InstitutionMemberModel({
    required super.id,
    required super.phone,
    required super.role,
    super.name,
    super.status,
    super.invitedAt,
    super.acceptedAt,
  });

  factory InstitutionMemberModel.fromJson(Map<String, dynamic> json) {
    return InstitutionMemberModel(
      id: _int(json['id']),
      phone: _str(json['phone']) ?? '',
      role: _str(json['role']) ?? 'viewer',
      name: _str(json['name']),
      status: _str(json['status']) ?? (json['accepted_at'] != null ? 'active' : 'invited'),
      invitedAt: _str(json['invited_at']),
      acceptedAt: _str(json['accepted_at']),
    );
  }

  /// `GET /institution/members` → `data.members`.
  static List<InstitutionMemberModel> listFrom(dynamic body) {
    final data = _dataOf(body);
    final list = data['members'];
    return list is List
        ? list
            .whereType<Map>()
            .map((m) => InstitutionMemberModel.fromJson(Map<String, dynamic>.from(m)))
            .toList()
        : const [];
  }
}

class PendingInviteModel extends PendingInviteEntity {
  const PendingInviteModel({
    required super.id,
    required super.role,
    super.institutionId,
    required super.institutionName,
    super.invitedAt,
  });

  factory PendingInviteModel.fromJson(Map<String, dynamic> json) {
    return PendingInviteModel(
      id: _int(json['id']),
      role: _str(json['role']) ?? 'viewer',
      institutionId: _intOrNull(json['institution_id']),
      institutionName: _str(json['institution_name']) ?? '',
      invitedAt: _str(json['invited_at']),
    );
  }
}

class InstitutionOverviewModel extends InstitutionOverviewEntity {
  const InstitutionOverviewModel({
    super.isInstitutionAccount,
    super.institution,
    super.memberships,
    super.pendingInvites,
  });

  /// Accepts `GET /institution` (envelope or bare `data`).
  factory InstitutionOverviewModel.fromJson(dynamic body) {
    final json = _dataOf(body);
    final invites = json['pending_invites'];
    return InstitutionOverviewModel(
      isInstitutionAccount: json['account_type'] == 'institution',
      institution: InstitutionModel.tryParse(json['institution']),
      memberships: InstitutionMembershipModel.listFrom(
          json['memberships'] ?? json['institution_memberships']),
      pendingInvites: invites is List
          ? invites
              .whereType<Map>()
              .map((m) => PendingInviteModel.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : const [],
    );
  }
}

class InstitutionCreditsModel extends InstitutionCreditsEntity {
  const InstitutionCreditsModel({
    required super.balance,
    super.discountPercent,
    super.transactions,
  });

  factory InstitutionCreditsModel.fromJson(dynamic body) {
    final json = _dataOf(body);
    final rows = json['transactions'];
    return InstitutionCreditsModel(
      balance: _int(json['balance']),
      discountPercent: _double(json['discount_percent']),
      transactions: rows is List
          ? rows.whereType<Map>().map((r) {
              final m = Map<String, dynamic>.from(r);
              return CreditTransactionEntity(
                id: _int(m['id']),
                type: _str(m['type']) ?? 'adjustment',
                amount: _int(m['amount']),
                balanceAfter: _int(m['balance_after']),
                eventId: _intOrNull(m['event_id']),
                note: _str(m['note']),
                createdAt: DateTime.tryParse('${m['created_at'] ?? ''}'),
              );
            }).toList()
          : const [],
    );
  }
}
