import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/authentication/data/models/auth_response_model.dart';

void main() {
  group('ClientModel profile photo', () {
    test('prefers the absolute avatar_url from the backend', () {
      final user = ClientModel.fromJson({
        'id': 1,
        'name': 'Ahmad Saleh',
        'phone': '+970599000000',
        'avatar': 'clients/avatars/a.jpg',
        'avatar_url': 'https://maktoob.social/storage/clients/avatars/a.jpg',
      }).toEntity();

      expect(user.avatar, 'https://maktoob.social/storage/clients/avatars/a.jpg');
    });

    test('ignores a bare storage path that the app cannot load', () {
      final user = ClientModel.fromJson({
        'id': 1,
        'name': 'Ahmad',
        'phone': '',
        'avatar': 'avatars/a.jpg',
      }).toEntity();

      expect(user.avatar, isNull);
    });

    test('round-trips through toJson (cached user)', () {
      final first = ClientModel.fromJson({
        'id': 1,
        'name': 'A',
        'phone': '',
        'avatar_url': 'https://x.test/a.jpg',
      });
      final again = ClientModel.fromJson(first.toJson());

      expect(again.avatar, 'https://x.test/a.jpg');
    });
  });

  group('UserEntity identity', () {
    test('initials use first and last word, Arabic included', () {
      expect(ClientModel.fromJson({'id': 1, 'name': 'أحمد محمد صالح', 'phone': ''}).toEntity().initials, 'أص');
      expect(ClientModel.fromJson({'id': 1, 'name': '  Sara  ', 'phone': ''}).toEntity().initials, 'S');
      expect(ClientModel.fromJson({'id': 1, 'name': '', 'phone': ''}).toEntity().initials, '');
    });

    test('a workplace name does not make an individual an institution', () {
      final individual = ClientModel.fromJson({
        'id': 1,
        'name': 'Sara',
        'phone': '',
        'company_name': 'Bank of Palestine',
        'account_type': 'individual',
      }).toEntity();
      final org = ClientModel.fromJson({
        'id': 2,
        'name': 'Org',
        'phone': '',
        'account_type': 'institution',
      }).toEntity();

      expect(individual.isInstitution, isFalse);
      expect(org.isInstitution, isTrue);
    });
  });
}
