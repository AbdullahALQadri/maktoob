import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/guest_groups/data/models/guest_group_model.dart';
import 'package:maktoob/features/guest_groups/domain/entities/guest_group.dart';
import 'package:maktoob/features/guest_groups/domain/repositories/guest_groups_repository.dart';
import 'package:maktoob/features/guest_groups/domain/usecases/guest_group_usecases.dart';
import 'package:maktoob/features/guest_groups/presentation/cubit/guest_group_cubit.dart';
import 'package:maktoob/features/guest_groups/presentation/cubit/guest_groups_cubit.dart';
import 'package:maktoob/features/guest_groups/presentation/screens/guest_group_screen.dart';
import 'package:maktoob/features/guest_groups/presentation/screens/guest_groups_screen.dart';
import 'package:maktoob/features/invitation/data/models/invitation_draft_model.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_cubit.dart';

/// Keeps the groups in memory, the way the server does.
class _Repo implements GuestGroupsRepository {
  final _groups = <int, GuestGroup>{};
  int _nextId = 1;
  int _nextGuest = 100;

  GuestGroup _with(int id, {String? name, List<GroupGuest>? guests}) {
    final old = _groups[id]!;
    final list = guests ?? old.guests;
    return _groups[id] = GuestGroup(id: id, name: name ?? old.name, guestsCount: list.length, guests: list);
  }

  @override
  Future<Either<Failure, GuestGroupsOverview>> groups() async => Right(GuestGroupsOverview(
        groups: _groups.values.toList(),
        totalGuests: _groups.values.fold(0, (sum, g) => sum + g.guests.length),
      ));

  @override
  Future<Either<Failure, GuestGroup>> group(int id) async =>
      _groups.containsKey(id) ? Right(_groups[id]!) : const Left(NotFoundFailure(message: 'gone'));

  @override
  Future<Either<Failure, GuestGroup>> create(String name, {List<GroupGuest> guests = const []}) async {
    if (_groups.values.any((g) => g.name == name)) {
      return const Left(ValidationFailure(message: 'A group with this name already exists.'));
    }
    final id = _nextId++;
    return Right(_groups[id] = GuestGroup(id: id, name: name));
  }

  @override
  Future<Either<Failure, GuestGroup>> rename(int id, String name) async => Right(_with(id, name: name));

  @override
  Future<Either<Failure, GuestGroup>> addGuests(int id, List<GroupGuest> guests) async => Right(_with(id, guests: [
        ..._groups[id]!.guests,
        for (final g in guests) GroupGuest(id: _nextGuest++, name: g.name, phone: g.phone),
      ]));

  @override
  Future<Either<Failure, GuestGroup>> removeGuest(int id, int guestId) async =>
      Right(_with(id, guests: _groups[id]!.guests.where((g) => g.id != guestId).toList()));

  @override
  Future<Either<Failure, Unit>> delete(int id) async {
    _groups.remove(id);
    return const Right(unit);
  }
}

GuestGroupsCubit _list(_Repo repo) =>
    GuestGroupsCubit(getGroups: GetGuestGroupsUseCase(repo), createGroup: CreateGuestGroupUseCase(repo));

GuestGroupCubit _one(_Repo repo, int id) => GuestGroupCubit(
      getGroup: GetGuestGroupUseCase(repo),
      changeGroup: ChangeGuestGroupUseCase(repo),
      deleteGroup: DeleteGuestGroupUseCase(repo),
      groupId: id,
    );

const _viewports = <(String, Size, double)>[
  ('small phone', Size(320, 568), 1.0),
  ('phone, very large text', Size(390, 844), 2.0),
  ('desktop', Size(1280, 800), 1.0),
];

void main() {
  test('reads a group and its people; a missing number is no number', () {
    final group = GuestGroupModel.fromResponse({
      'data': {
        'id': 3,
        'name': 'العائلة',
        'guests_count': 2,
        'guests': [
          {'id': 1, 'name': 'سارة', 'phone': '+970599123456'},
          {'id': 2, 'name': 'خالد', 'phone': null},
        ],
      },
    });
    expect(group.guests.map((g) => g.phone), ['+970599123456', null]);
    expect(GuestGroupModel.guestsToJson(const [GroupGuest(name: ' منى ', phone: '')]), [
      {'name': 'منى'},
    ]);
  });

  test('a host makes a group, fills it, renames it and deletes it', () async {
    final repo = _Repo();
    final list = _list(repo);
    await list.load();
    expect(list.state.groups, isEmpty);

    final created = await list.create(' العائلة ');
    expect(created?.name, 'العائلة');
    expect(list.state.groups.single.name, 'العائلة');

    // The same name again is refused and said so.
    expect(await list.create('العائلة'), isNull);
    expect(list.state.message, isNotNull);
    expect(await list.create('  '), isNull);

    final one = _one(repo, created!.id);
    await one.load();
    expect(await one.addGuest('سارة', '0599123456'), isTrue);
    expect(await one.addGuest('خالد', ''), isTrue);
    expect(one.state.group?.guests, hasLength(2));

    await one.removeGuest(one.state.group!.guests.first.id!);
    expect(one.state.group?.guests.single.name, 'خالد');

    await one.rename('الأهل');
    expect(one.state.group?.name, 'الأهل');

    await one.delete();
    expect(one.state.deleted, isTrue);
    await list.load();
    expect(list.state.groups, isEmpty);
    await one.close();
    await list.close();
  });

  test('a group joins an event list: only people with a number, none twice', () {
    final wizard = InvitationCubit();
    wizard.addManualGuest(const GuestInfoModel(name: 'سارة', phone: '0599123456'));
    final added = wizard.addSavedGuests(const [
      GuestInfoModel(name: 'سارة أحمد', phone: '0599123456'), // already on the list
      GuestInfoModel(name: 'منى', phone: '0599000111'),
      GuestInfoModel(name: 'خالد', phone: ''), // no number: cannot be invited
    ]);
    expect(added, 1);
    expect(wizard.state.guests.map((g) => g.name), containsAll(['سارة', 'منى']));
    expect(wizard.state.guests, hasLength(2));
  });

  group('layout', () {
    for (final locale in const [Locale('ar'), Locale('en')]) {
      for (final (name, size, textScale) in _viewports) {
        testWidgets('${locale.languageCode}: $name', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = textScale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          final repo = _Repo();
          final list = _list(repo);
          late GuestGroupCubit one;
          addTearDown(list.close);

          Future<void> show(Widget home) async {
            await tester.runAsync(() async {
              await tester.pumpWidget(MaterialApp(
                locale: locale,
                supportedLocales: AppLocalizationsSetup.supportedLocales,
                localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
                home: home,
              ));
              await Future<void>.delayed(const Duration(milliseconds: 200));
            });
            await tester.pump();
            expect(tester.takeException(), isNull);
          }

          // Nothing yet: the page says what groups are for.
          await tester.runAsync(list.load);
          await show(BlocProvider.value(value: list, child: const GuestGroupsScreen()));
          expect(find.byKey(const Key('groups_first')), findsOneWidget);

          await tester.runAsync(() async {
            final group = await list.create('عائلة العريس الكريمة من غزة وخان يونس');
            one = _one(repo, group!.id);
            await one.load();
            await one.addGuest('عبد الرحمن محمد عبد الله أبو شمالة', '0599123456');
            await list.load();
          });
          addTearDown(one.close);
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('groups_new')), findsOneWidget);

          await show(BlocProvider.value(value: one, child: const GuestGroupScreen()));
          expect(find.byKey(const Key('group_guest_add')), findsOneWidget);
          expect(find.textContaining('أبو شمالة'), findsOneWidget);
        });
      }
    }
  });
}
