import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_state.dart';

void main() {
  test('package reads per-invitation price and volume saving', () {
    final p = PackageModel.fromJson({
      'id': 3,
      'name_en': 'Gold',
      'name_ar': 'ذهبية',
      'price': '300.00',
      'invitations_limit': 200,
      'price_per_invitation': 1.5,
      'volume_saving_percent': 25,
    });

    expect(p.pricePerInvitation, 1.5);
    expect(p.volumeSavingPercent, 25);
    // copyWith keeps them (the wizard copies packages when selecting).
    expect(p.copyWith(name: 'Gold+').volumeSavingPercent, 25);
  });

  test('older payloads without the fields still parse', () {
    final p = PackageModel.fromJson({'id': 1, 'name_ar': 'مجانية', 'price': 0, 'invitations_limit': 1});

    expect(p.pricePerInvitation, isNull);
    expect(p.volumeSavingPercent, 0);
  });
}
