import '../../domain/entities/staff_review_entities.dart';

/// Readers for the identity and institution reviews.
class StaffReviewModels {
  const StaffReviewModels._();

  static StaffIdentity identity(dynamic json) {
    final map = _map(json);
    final client = _map(map['client']);
    return StaffIdentity(
      id: _int(map['id']),
      status: '${map['status'] ?? 'pending'}',
      clientName: _text(client['name']),
      clientPhone: _text(client['phone']),
      nameAr: _text(map['name_ar']) ?? '',
      nameLatin: _text(map['name_latin']) ?? '',
      documentType: _text(map['document_type']),
      documentCountry: _text(map['document_country']),
      documentLast4: _text(map['document_last4']),
      birthDate: _text(map['birth_date']),
      expiresOn: _text(map['document_expires_on']),
      hasFront: map['has_front'] == true,
      hasBack: map['has_back'] == true,
      sameIdElsewhere: map['same_id_on_another_account'] == true,
      sameNameAccounts: _int(map['same_name_accounts']),
      rejectionReason: _text(map['rejection_reason']),
    );
  }

  static StaffInstitution institution(dynamic json) {
    final map = _map(json);
    final owner = _map(map['owner']);
    final documents = map['documents'];
    return StaffInstitution(
      id: _int(map['id']),
      status: '${map['status'] ?? 'pending'}',
      nameAr: _text(map['name_ar']),
      nameEn: _text(map['name_en']),
      tradeName: _text(map['trade_name_ar']) ?? _text(map['trade_name_en']),
      sector: _text(map['sector']),
      ownerName: _text(owner['name']),
      ownerPhone: _text(owner['phone']),
      legalForm: _text(map['legal_form']),
      registrationNumber: _text(map['registration_number']),
      registrationCountry: _text(map['registration_country']),
      representativeRole: _text(map['representative_role']),
      ownerIdentityStatus: _text(map['owner_identity_status']),
      checklist: {
        for (final entry in _map(map['checklist']).entries)
          if (entry.value is bool) entry.key: entry.value as bool,
      },
      documents: [
        for (final item in documents is List ? documents : const [])
          if (item is Map)
            StaffDocument(
              id: _int(item['id']),
              name: _text(item['name']) ?? '#${item['id']}',
              type: _text(item['type']),
              mime: _text(item['mime']),
            ),
      ],
      rejectionReason: _text(map['rejection_reason']),
    );
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : const {};

  static int _int(dynamic value) => value is num ? value.toInt() : int.tryParse('${value ?? ''}') ?? 0;

  static String? _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
