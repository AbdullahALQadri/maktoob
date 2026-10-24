import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/scanner/data/door_engine.dart';
import 'package:maktoob/features/scanner/domain/entities/door_entities.dart';
import 'package:maktoob/features/scanner/domain/logic/door_rules.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/door_fakes.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  group('offline door', () {
    test('admits from the saved list, lets the guest back in on the second scan, uploads once', () async {
      final server = FakeServer();
      final engine = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await engine.open(testSession(), live: false); // pack downloaded while online
      expect(engine.status.hasPack, isTrue);
      expect(engine.status.guests, 3);

      server.online = false; // at the venue: no internet
      final verdict = await engine.lookup(testQr('sara00000001'));
      expect(verdict.guest?.name, 'سارة');
      expect(verdict.canAdmit, isTrue);

      final admitted = await engine.admit(1, companions: 1);
      expect(admitted.admitted, isTrue);
      expect(admitted.decidedBy, DoorDecidedBy.device, reason: 'the server did not answer');
      expect(engine.status.pending, 1);

      // She steps out to the bathroom and comes back with the same QR.
      final back = await engine.lookup(testQr('sara00000001'));
      expect(back.blocker, isNull);
      expect(back.returning, isTrue);
      final again = await engine.admit(1);
      expect(again.admitted, isTrue);
      expect(again.returning, isTrue);
      expect(again.checkIn?.companions, 1, reason: 'the first entry, with its companion');
      expect(engine.status.pending, 1, reason: 'a return records nothing');
      expect(engine.status.checkedIn, 1);

      // Internet is back.
      server.online = true;
      await engine.syncNow();
      expect(server.uploads.single.single['source'], 'offline');
      expect(server.uploads.single.single['companions'], 1);
      expect(engine.status.pending, 0);
      expect(server.checkIns.single.invitationId, 1);

      // Sending again is harmless.
      await engine.syncNow();
      expect(server.checkIns, hasLength(1));
      await engine.close();
    });

    test('online: the server decides, and other doors\' check-ins arrive', () async {
      final server = FakeServer();
      final engine = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await engine.open(testSession(gateId: 1), live: false);

      final admitted = await engine.admit(2, companions: 2);
      expect(admitted.decidedBy, DoorDecidedBy.server);
      expect(server.uploads.single.single['source'], 'online');
      expect(server.uploads.single.single['gate_id'], 1);

      // Women's door admitted Sara on another phone.
      server.checkIns.add(
        DoorCheckIn(uuid: 'other-phone-1', invitationId: 1, checkedInAt: DateTime.now().toUtc(), deviceName: 'Women 1'),
      );
      await engine.syncNow();
      final verdict = await engine.lookup(testQr('sara00000001'));
      expect(verdict.blocker, isNull);
      expect(verdict.returning, isTrue);
      expect(verdict.guest?.checkIn?.deviceName, 'Women 1');
      expect(engine.status.checkedIn, 2);
      await engine.close();
    });

    test('a guest another door let in comes back here: the server says so, nothing is kept', () async {
      final server = FakeServer();
      final engine = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await engine.open(testSession(), live: false);
      server.checkIns.add(
        DoorCheckIn(uuid: 'x-1', invitationId: 3, checkedInAt: DateTime.now().toUtc(), deviceName: 'Hall'),
      );

      final res = await engine.admit(3);
      expect(res.admitted, isTrue);
      expect(res.returning, isTrue);
      expect(res.decidedBy, DoorDecidedBy.server);
      expect(res.checkIn?.deviceName, 'Hall');
      expect(server.checkIns, hasLength(1));
      expect(engine.status.pending, 0);
      await engine.close();
    });

    test('the QR is one day: coming back after the event day is refused', () async {
      final server = FakeServer();
      final engine = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await engine.open(testSession(), live: false);
      expect((await engine.admit(2)).admitted, isTrue);

      // The day is over (the pack says so after the next sync).
      final ended = testPack()..['roster_version'] = 'v2';
      (ended['event'] as Map)['valid_until'] = DateTime.now()
          .toUtc()
          .subtract(const Duration(minutes: 1))
          .toIso8601String();
      server.packJson = ended;
      await engine.syncNow();
      server.online = false;

      expect((await engine.lookup(testQr('ahmad0000002'))).blocker, DoorRules.expired);
      final late = await engine.admit(2);
      expect(late.admitted, isFalse);
      expect(late.code, DoorRules.expired);
      await engine.close();
    });

    test('door rules: wrong gate warns, too many companions and a cancelled event refuse', () async {
      final server = FakeServer()..packJson = testPack(maxCompanions: 1);
      final engine = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await engine.open(testSession(gateId: 1), live: false); // men's gate
      server.online = false;

      final sara = await engine.lookup(testQr('sara00000001'));
      expect(sara.warnings, contains(DoorRules.warnWrongGate));
      expect(sara.canAdmit, isTrue, reason: 'a warning never refuses');

      expect((await engine.admit(2, companions: 3)).code, DoorRules.tooManyCompanions);

      server
        ..online = true
        ..packJson = (testPack(status: 'cancelled')..['roster_version'] = 'v2');
      await engine.syncNow();
      server.online = false;
      expect((await engine.lookup(testQr('ahmad0000002'))).blocker, DoorRules.eventNotActive);
      expect((await engine.admit(2)).code, DoorRules.eventNotActive);
      await engine.close();
    });

    test('a genuine QR added after the download is admitted; another event\'s QR is not', () async {
      final server = FakeServer();
      final engine = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await engine.open(testSession(), live: false);
      server.online = false;

      final late = await engine.lookup(testQr('newguest0099', invitation: 99, max: '3'));
      expect(late.unlisted, isTrue);
      expect(late.guest?.id, 99);
      expect(late.maxCompanions, 3);
      expect(late.warnings, contains(DoorRules.warnUnlisted));
      expect((await engine.admit(99, companions: 3, maxCompanions: 3)).admitted, isTrue);

      expect((await engine.lookup(testQr('elsewhere001', invitation: 5, event: 8))).blocker, DoorRules.otherEvent);
      expect((await engine.lookup('https://maktoob.social/i/unknown12345')).blocker, DoorRules.notFound);
      await engine.close();
    });

    test('a phone with no list yet says so instead of failing', () async {
      final server = FakeServer()..online = false;
      final engine = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await engine.open(testSession(), live: false);
      expect(engine.status.hasPack, isFalse);
      expect((await engine.lookup(testQr('sara00000001'))).blocker, 'no_pack');
      await engine.close();
    });
  });

  group('two offline doors, no hub', () {
    test('in at one door, back in at the other: one attendance, the return is settled', () async {
      final server = FakeServer();
      final men = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      final women = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await men.open(testSession(name: 'Men 1'), live: false);
      await women.open(testSession(name: 'Women 1'), live: false);
      server.online = false;

      expect((await men.admit(3, companions: 1)).admitted, isTrue);
      expect((await women.admit(3)).admitted, isTrue, reason: 'neither door could know: let in');

      server.online = true;
      await men.syncNow();
      await women.syncNow();
      final attendance = server.checkIns.where((c) => c.invitationId == 3).toList();
      expect(attendance, hasLength(1));
      expect(attendance.single.companions, 1, reason: 'the first entry is the attendance');
      expect(server.returns, hasLength(1));
      expect(women.status.pending, 0, reason: 'a return is settled, not retried');

      await men.close();
      await women.close();
    });
  });
}
