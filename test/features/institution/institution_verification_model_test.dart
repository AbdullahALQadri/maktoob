import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/institution/data/models/institution_models.dart';
import 'package:maktoob/features/institution/domain/entities/institution_entity.dart';

void main() {
  group('InstitutionModel verification payload', () {
    final json = {
      'id': 7,
      'status': 'approved',
      'name_ar': 'جمعية الأمل',
      'name_en': 'Al Amal',
      'sector': 'association',
      'tax_number': '123',
      'website': 'https://alamal.ps',
      'official_email': 'info@alamal.ps',
      'governorate': 'Gaza',
      'address': 'Al-Rimal',
      'declaration_accepted_at': '2026-10-19T10:00:00+03:00',
      'verification': {
        'name': true,
        'sector': true,
        'logo': false,
        'registration_document': true,
        'declaration': true,
      },
      'documents': [
        {'id': 3, 'type': 'registration_certificate', 'original_name': 'cert.pdf', 'size': 1024},
      ],
      'pending_changes': {
        'fields': {'name_ar': 'جمعية الأمل الخيرية'},
        'logo_url': null,
        'submitted_at': '2026-10-19T11:00:00+03:00',
      },
    };

    test('parses official fields, checklist, documents and pending changes', () {
      final i = InstitutionModel.fromJson(json);

      expect(i.isApproved, isTrue);
      expect(i.isIdentityLocked, isTrue);
      expect(i.canDeleteDocuments, isFalse);
      expect(i.taxNumber, '123');
      expect(i.declarationAccepted, isTrue);
      expect(i.verification.isComplete, isTrue);
      expect(i.documents.single.type, 'registration_certificate');
      expect(i.pendingChanges?.fields['name_ar'], 'جمعية الأمل الخيرية');
      // The form shows what the owner asked for, not the live value.
      expect(i.requested('name_ar', i.nameAr), 'جمعية الأمل الخيرية');
      expect(i.requested('name_en', i.nameEn), 'Al Amal');
    });

    test('suspended status is understood', () {
      final i = InstitutionModel.fromJson({...json, 'status': 'suspended', 'suspension_reason': 'Complaint'});
      expect(i.isSuspended, isTrue);
      expect(i.suspensionReason, 'Complaint');
    });

    test('no pending_changes means null, not an empty object', () {
      final i = InstitutionModel.fromJson({...json, 'pending_changes': null});
      expect(i.pendingChanges, isNull);
    });
  });

  group('InstitutionProfileInput.toFields', () {
    test('registration sends only filled fields and the declaration', () {
      final f = const InstitutionProfileInput(nameAr: 'شركة', sector: 'company', declaration: true).toFields();
      expect(f, {'organization_name_ar': 'شركة', 'sector': 'company', 'declaration': '1'});
    });

    test('profile edit sends empty values so a field can be cleared', () {
      final f = const InstitutionProfileInput(nameAr: 'شركة', taxNumber: '', sendEmpty: true).toFields();
      expect(f['tax_number'], '');
      expect(f.containsKey('declaration'), isFalse);
    });
  });
}
