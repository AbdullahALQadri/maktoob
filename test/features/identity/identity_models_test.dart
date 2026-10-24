import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/authentication/data/models/auth_response_model.dart';
import 'package:maktoob/features/identity/data/models/identity_models.dart';
import 'package:maktoob/features/identity/domain/entities/identity_entities.dart';

void main() {
  const identityJson = {
    'status': 'verified',
    'verified_at': '2026-10-24T10:00:00+03:00',
    'required': false,
    'required_reason': null,
    'legal_name': {
      'ar': {'first': 'محمد', 'father': 'عبد الله', 'grandfather': 'أحمد', 'family': 'أبو شمالة', 'full': 'محمد عبد الله أحمد أبو شمالة'},
      'latin': {'given': 'Mohammed Abdullah Ahmad', 'family': 'Abu Shamala', 'full': 'Mohammed Abdullah Ahmad Abu Shamala'},
    },
    'document': {'type': 'national_id', 'country': 'PS', 'last4': '6782', 'expires_on': null},
    'pending': null,
    'rejection_reason': null,
  };

  group('client.identity in the account payload', () {
    test('is parsed into the user, separate from the mobile check', () {
      final user = ClientModel.fromJson({
        'id': 1,
        'name': 'محمد أبو شمالة',
        'phone': '+970599000000',
        'is_verified': true,
        'identity': identityJson,
      }).toEntity();

      expect(user.isVerified, isTrue);
      expect(user.isIdentityVerified, isTrue);
      expect(user.identityRequired, isFalse);
      expect(user.identity!.legalName!.display(true), 'محمد عبد الله أحمد أبو شمالة');
      expect(user.identity!.legalName!.display(false), 'Mohammed Abdullah Ahmad Abu Shamala');
      expect(user.identity!.document!.last4, '6782');
    });

    test('an older backend without identity gives null, not a crash', () {
      final user = ClientModel.fromJson({'id': 1, 'name': 'A B', 'phone': '', 'is_verified': true}).toEntity();
      expect(user.identity, isNull);
      expect(user.isIdentityVerified, isFalse);
    });

    test('a phone-confirmed client asked to verify sees the requirement', () {
      final user = ClientModel.fromJson({
        'id': 1,
        'name': 'A B',
        'phone': '',
        'is_verified': true,
        'identity': {'status': 'rejected', 'required': true, 'required_reason': 'High volume', 'rejection_reason': 'Blurry photo'},
      }).toEntity();

      expect(user.identityRequired, isTrue);
      expect(user.identity!.status, IdentityStatus.rejected);
      expect(user.identity!.requiredReason, 'High volume');
      expect(user.identity!.rejectionReason, 'Blurry photo');
    });

    test('a cached user keeps its identity through toJson', () {
      final first = ClientModel.fromJson({'id': 1, 'name': 'A B', 'phone': '', 'identity': identityJson});
      final again = ClientModel.fromJson(first.toJson()).toEntity();
      expect(again.isIdentityVerified, isTrue);
    });
  });

  test('GET /auth/identity overview: state, submissions and options', () {
    final overview = IdentityOverviewModel.fromJson({
      'success': true,
      'message': '',
      'data': {
        'identity': {
          'status': 'pending',
          'pending': {'id': 9, 'document_type': 'passport', 'submitted_at': '2026-10-24T10:00:00+03:00'},
        },
        'submissions': [
          {
            'id': 9,
            'status': 'pending',
            'document_type': 'passport',
            'document_country': 'DE',
            'document_last4': '0T47',
            'legal_name': {'ar': {}, 'latin': {'given': 'Mohammed', 'family': 'Abu-Shamala', 'full': 'Mohammed Abu-Shamala'}},
            'has_back': false,
          },
        ],
        'options': {
          'document_types': [
            {'key': 'national_id', 'label': 'بطاقة هوية'},
            {'key': 'passport', 'label': 'جواز سفر'},
          ],
          'countries': [
            {'code': 'PS', 'name': 'فلسطين'},
            {'code': 'de', 'name': 'ألمانيا'},
          ],
          'four_part_id_countries': ['PS'],
          'check_digit_id_countries': ['PS', 'IL'],
          'minimum_age': 18,
          'max_file_kb': 8192,
        },
      },
    });

    expect(overview.identity.status, IdentityStatus.pending);
    expect(overview.identity.hasPending, isTrue);
    expect(overview.identity.pendingDocumentType, 'passport');
    expect(overview.submissions.single.last4, '0T47');
    expect(overview.submissions.single.legalName.latin, 'Mohammed Abu-Shamala');
    expect(overview.options.countries.map((c) => c.code), ['PS', 'DE']);
    expect(overview.options.countryName('DE'), 'ألمانيا');
    expect(overview.options.documentTypes.first.label, 'بطاقة هوية');
  });
}
