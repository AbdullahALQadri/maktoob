import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_cubit.dart';

/// The invoice WhatsApp number used to fall back to a made-up `+972599999999`
/// whenever the API did not supply one — so clients were sent to WhatsApp a
/// number nobody at Maktoob owns. With no configured number, there must be no
/// number at all (the save still succeeds; the UI says WhatsApp is unavailable).
void main() {
  test('invoice generated without the API leaves the WhatsApp number unset', () async {
    final cubit = InvitationCubit(); // no api service → local invoice branch

    await cubit.loadInvoice();

    expect(cubit.state.whatsappNumber, isNull);
    expect(cubit.state.isLoadingInvoice, isFalse, reason: 'invoice flow still completes');
  });

  test('a blank number from the API is treated as no number', () {
    final cubit = InvitationCubit();

    cubit.setWhatsAppNumber('   ');
    expect(cubit.state.whatsappNumber, isNull);

    cubit.setWhatsAppNumber('');
    expect(cubit.state.whatsappNumber, isNull);
  });

  test('a configured number is kept as given', () {
    final cubit = InvitationCubit();

    cubit.setWhatsAppNumber('+000000000001');

    expect(cubit.state.whatsappNumber, '+000000000001');
  });

  test('no placeholder WhatsApp number remains anywhere in lib/', () {
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => f.readAsStringSync().contains('599999999'))
        .map((f) => f.path)
        .toList();

    expect(offenders, isEmpty);
  });
}
