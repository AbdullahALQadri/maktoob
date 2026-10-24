import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/scanner/data/door_engine.dart';
import 'package:maktoob/features/scanner/data/lan/lan_protocol.dart';
import 'package:maktoob/features/scanner/domain/entities/door_entities.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/door_fakes.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  group('venue hub (no internet, local network)', () {
    test('a joined phone admits through the hub and both see every check-in', () async {
      final server = FakeServer();
      final hub = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await hub.open(testSession(name: 'Hub'), live: false);
      server.online = false;

      // A staff phone with no account and no internet joins the hub.
      final peer = await joinedDoor(await localJoin(hub), 'Women door');
      expect(peer.status.guests, 3, reason: 'the list came from the hub');

      final viaHub = await peer.admit(1);
      expect(viaHub.admitted, isTrue);
      expect(viaHub.decidedBy, DoorDecidedBy.hub);

      // She comes back through the hub's own door: let in, nothing new.
      final back = await hub.admit(1);
      expect(back.admitted, isTrue);
      expect(back.returning, isTrue);

      // The hub admits Ahmad; the joined phone learns it within a moment.
      expect((await hub.admit(2)).admitted, isTrue);
      await waitUntil(() => peer.status.checkedIn == 2);
      final ahmad = await peer.lookup(testQr('ahmad0000002'));
      expect(ahmad.blocker, isNull);
      expect(ahmad.returning, isTrue, reason: 'the joined door knows he is in');

      // The hub uploads everything (its own and the joined phone's) when online.
      server.online = true;
      await hub.syncNow();
      expect(server.checkIns.map((c) => c.invitationId), unorderedEquals([1, 2]));
      final relayed = server.uploads.expand((b) => b).firstWhere((i) => i['invitation_id'] == 1);
      expect(relayed['device_name'], 'Women door');
      expect(relayed['source'], 'lan');

      await peer.close();
      await hub.close(force: true);
    });

    // Found on a device: the hub waited 2 s for the server and the joined
    // door gave up first, then decided alone.
    test('a joined door gets the hub\'s answer while the hub\'s internet is slow', () async {
      final server = FakeServer();
      final hub = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await hub.open(testSession(name: 'Hub'), live: false);
      final door = await joinedDoor(await localJoin(hub), 'Women door');

      // Longer than the hub gives the server for a joined door, shorter than
      // the hub's own live claim.
      server.uploadDelay = const Duration(milliseconds: 2500);
      final res = await door.admit(1);
      expect(res.admitted, isTrue);
      expect(res.decidedBy, DoorDecidedBy.hub, reason: 'the hub answered before the door gave up');

      // The server recorded the late claim; the hub's upload replays it.
      server.uploadDelay = Duration.zero;
      await hub.syncNow();
      expect(server.checkIns.where((c) => c.invitationId == 1), hasLength(1));
      expect(server.returns, isEmpty);

      await door.close();
      await hub.close(force: true);
    });

    test('four doors at once: none waits for another guest\'s claim, a guest counts once', () async {
      final server = FakeServer();
      final hub = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await hub.open(testSession(name: 'Men 1'), live: false);
      final join = await localJoin(hub);
      final doors = [
        for (final name in ['Men 2', 'Women 1', 'Women 2']) await joinedDoor(join, name),
      ];

      server.uploadDelay = const Duration(seconds: 1);
      final watch = Stopwatch()..start();
      final results = await Future.wait([
        doors[0].admit(1),
        doors[1].admit(1), // Sara's QR at a second door, at the same moment
        doors[2].admit(2),
        hub.admit(3),
      ]);
      watch.stop();

      expect(results.map((r) => r.decidedBy), [
        DoorDecidedBy.hub,
        DoorDecidedBy.hub,
        DoorDecidedBy.hub,
        DoorDecidedBy.server,
      ]);
      final sara = results.take(2).toList();
      expect(sara.every((r) => r.admitted), isTrue, reason: 'nobody is turned away');
      expect(sara.where((r) => r.returning), hasLength(1), reason: 'one is the attendance, the other a return');
      expect(results[2].admitted && results[3].admitted, isTrue);
      expect(
        watch.elapsed,
        lessThan(const Duration(milliseconds: 2500)),
        reason: 'claims for different guests run side by side',
      );
      expect(server.checkIns.map((c) => c.invitationId), unorderedEquals([1, 2, 3]));

      for (final door in doors) {
        await door.close();
      }
      await hub.close(force: true);
    });

    test('leaving the screen keeps the hub serving; stopping it ends the background service', () async {
      final server = FakeServer();
      final keepAlive = FakeKeepAlive();
      final hub = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null, keepAlive: keepAlive);
      await hub.open(testSession(name: 'Hub'), live: false);
      await hub.startHubJoinCode(notificationTitle: 'Hub on', notificationText: 'Doors connect here');
      expect(keepAlive.calls, ['start:Hub on']);

      await hub.close(); // the scanner screen was closed
      expect(hub.hubPort, isNotNull, reason: 'the other doors still depend on it');
      expect(hub.session, isNotNull);

      await hub.stopHub();
      expect(keepAlive.calls, ['start:Hub on', 'stop']);
      await hub.close();
      expect(hub.session, isNull);
    });

    test('a phone without the hub\'s secret is refused', () async {
      final server = FakeServer();
      final hub = DoorEngine(store: await memoryStore(), remote: server, syncEvery: null);
      await hub.open(testSession(name: 'Hub'), live: false);
      await hub.startHubJoinCode();

      final forged = LanJoinInfo(
        hosts: ['127.0.0.1:${hub.hubPort}'],
        eventId: testEventId,
        eventTitle: '',
        hubName: '',
        secret: List<int>.filled(32, 9),
      );
      final peer = DoorEngine(store: await memoryStore(), remote: null, syncEvery: null);
      await peer.open(testSession(kind: DoorSessionKind.lan, lanJoin: forged.toStorage()));
      await waitUntil(() => peer.status.problem == 'hub_refused');
      expect(peer.status.hasPack, isFalse);

      await peer.close();
      await hub.close(force: true);
    });
  });
}
