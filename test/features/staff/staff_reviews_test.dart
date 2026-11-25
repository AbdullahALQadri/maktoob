import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/staff/data/models/staff_review_models.dart';
import 'package:maktoob/features/staff/domain/entities/staff_review_entities.dart';
import 'package:maktoob/features/staff/domain/repositories/staff_repository.dart';
import 'package:maktoob/features/staff/domain/repositories/staff_reviews_repository.dart';
import 'package:maktoob/features/staff/domain/usecases/staff_review_usecases.dart';
import 'package:maktoob/features/staff/presentation/cubit/staff_item_cubit.dart';
import 'package:maktoob/features/staff/presentation/screens/staff_gate.dart';
import 'package:maktoob/features/staff/presentation/screens/staff_identity_screens.dart';
import 'package:maktoob/features/staff/presentation/screens/staff_institution_screens.dart';
import 'package:maktoob/features/staff/presentation/cubit/staff_session_cubit.dart';
import 'package:maktoob/features/staff/domain/usecases/staff_usecases.dart';
import 'package:maktoob/features/staff/domain/entities/staff_entities.dart';

const _identityJson = {
  'id': 7,
  'status': 'pending',
  'client': {'id': 2, 'name': 'محمد أبو شمالة', 'phone': '+970599123456'},
  'name_ar': 'محمد عبد الله أحمد أبو شمالة',
  'name_latin': 'MOHAMMED ABU SHAMALA',
  'document_type': 'national_id',
  'document_country': 'PS',
  'document_last4': '6782',
  'birth_date': '1990-05-14',
  'has_front': true,
  'has_back': true,
  'same_id_on_another_account': true,
  'same_name_accounts': 2,
};

const _institutionJson = {
  'id': 4,
  'status': 'pending',
  'name_ar': 'جمعية الأمل الخيرية للتنمية والإغاثة',
  'name_en': 'Al Amal Charity',
  'legal_form': 'association',
  'registration_number': 'GZ-1234',
  'registration_country': 'PS',
  'owner': {'id': 2, 'name': 'سارة أحمد', 'phone': '+970599000111'},
  'owner_identity_status': 'verified',
  'checklist': {'name': true, 'legal_details': true, 'registration_document': false, 'declaration': true},
  'documents': [
    {'id': 11, 'type': 'registration_certificate', 'name': 'certificate.pdf', 'mime': 'application/pdf'},
    {'id': 12, 'type': 'other', 'name': 'photo.jpg', 'mime': 'image/jpeg'},
  ],
};

class _Reviews implements StaffReviewsRepository {
  final opened = <String>[];
  final decisions = <String>[];

  @override
  StaffResult<List<StaffIdentity>> identities() async => Right([StaffReviewModels.identity(_identityJson)]);

  @override
  StaffResult<StaffIdentity> identity(int id) async => Right(StaffReviewModels.identity(_identityJson));

  @override
  StaffResult<Uint8List> identityPhoto(int id, String side) async {
    opened.add('identity $id $side');
    return Right(Uint8List(0));
  }

  @override
  StaffResult<Unit> approveIdentity(int id, {String? notes}) async {
    decisions.add('approve identity $id');
    return const Right(unit);
  }

  @override
  StaffResult<Unit> rejectIdentity(int id, String reason) async {
    decisions.add('reject identity $id: $reason');
    return const Right(unit);
  }

  @override
  StaffResult<List<StaffInstitution>> institutions() async => Right([StaffReviewModels.institution(_institutionJson)]);

  @override
  StaffResult<StaffInstitution> institution(int id) async => Right(StaffReviewModels.institution(_institutionJson));

  @override
  StaffResult<Uint8List> institutionDocument(int id, int documentId) async {
    opened.add('institution $id $documentId');
    return Right(Uint8List(0));
  }

  @override
  StaffResult<Unit> approveInstitution(int id, {String? notes}) async =>
      const Left(ValidationFailure(message: 'Registration certificate'));

  @override
  StaffResult<Unit> rejectInstitution(int id, String reason) async {
    decisions.add('reject institution $id: $reason');
    return const Right(unit);
  }
}

class _NoSession implements StaffRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  StaffResult<StaffUser?> restore() async => const Right(null);
}

Widget _app(Widget home, [Locale locale = const Locale('ar')]) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      home: home,
    );

const _viewports = <(String, Size, double)>[
  ('small phone', Size(320, 568), 1.0),
  ('phone, very large text', Size(390, 844), 2.0),
  ('desktop', Size(1280, 800), 1.0),
];

void main() {
  test('reads a review: the number is only its last four, a PDF is not a picture', () {
    final identity = StaffReviewModels.identity(_identityJson);
    expect(identity.documentLast4, '6782');
    expect(identity.sameIdElsewhere, isTrue);
    expect(identity.sameNameAccounts, 2);

    final institution = StaffReviewModels.institution(_institutionJson);
    expect(institution.checklist['registration_document'], isFalse);
    expect(institution.documents.first.isImage, isFalse);
    expect(institution.documents.last.isImage, isTrue);
  });

  test('a file is opened through its own use case, by what it belongs to', () async {
    final repo = _Reviews();
    final open = OpenStaffFileUseCase(repo);
    await open(const StaffFile.identity(7, 'front'));
    await open(const StaffFile.institution(4, 11));
    expect(repo.opened, ['identity 7 front', 'institution 4 11']);
  });

  test('an identity is decided once; an institution missing a requirement stays open', () async {
    final repo = _Reviews();
    final identity = StaffItemCubit<StaffIdentity>(
      read: GetStaffIdentityUseCase(repo).call,
      review: ReviewStaffIdentityUseCase(repo).call,
      id: 7,
    );
    await identity.load();
    await identity.reject('  ');
    expect(identity.state.message, 'staff_reason_required');
    await identity.approve();
    await identity.reject('late');
    expect(repo.decisions, ['approve identity 7']);
    expect(identity.state.reviewed, isTrue);

    final institution = StaffItemCubit<StaffInstitution>(
      read: GetStaffInstitutionUseCase(repo).call,
      review: ReviewStaffInstitutionUseCase(repo).call,
      id: 4,
    );
    await institution.load();
    await institution.approve();
    expect(institution.state.reviewed, isNull);
    expect(institution.state.message, 'Registration certificate');
    await institution.reject('الشهادة منتهية');
    expect(institution.state.reviewed, isFalse);
    await identity.close();
    await institution.close();
  });

  testWidgets('a staff phone opens on the team sign-in, with a way back to the client side', (tester) async {
    final repo = _NoSession();
    final session = StaffSessionCubit(
      signIn: SignInStaffUseCase(repo),
      restore: RestoreStaffUseCase(repo),
      signOut: SignOutStaffUseCase(repo),
    );
    addTearDown(session.close);
    var left = false;
    await tester.runAsync(() async {
      await session.open();
      await tester.pumpWidget(_app(BlocProvider.value(value: session, child: StaffGate(onExit: () => left = true))));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.tap(find.byKey(const Key('staff_exit')));
    expect(left, isTrue);
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

          final repo = _Reviews();
          final identity = StaffItemCubit<StaffIdentity>(
            read: GetStaffIdentityUseCase(repo).call,
            review: ReviewStaffIdentityUseCase(repo).call,
            id: 7,
          );
          final institution = StaffItemCubit<StaffInstitution>(
            read: GetStaffInstitutionUseCase(repo).call,
            review: ReviewStaffInstitutionUseCase(repo).call,
            id: 4,
          );
          addTearDown(identity.close);
          addTearDown(institution.close);
          await tester.runAsync(() async {
            await identity.load();
            await institution.load();
          });

          Future<void> show(Widget page) async {
            await tester.runAsync(() async {
              await tester.pumpWidget(_app(page, locale));
              await Future<void>.delayed(const Duration(milliseconds: 200));
            });
            await tester.pump();
            expect(tester.takeException(), isNull);
          }

          await show(BlocProvider.value(value: identity, child: const StaffIdentityScreen()));
          expect(find.byKey(const Key('staff_approve')), findsOneWidget);
          // The number shown is masked.
          await tester.scrollUntilVisible(find.textContaining('6782'), 120);
          expect(find.textContaining('6782'), findsOneWidget);
          // The photo buttons sit under the facts: scroll down to them.
          await tester.scrollUntilVisible(find.byKey(const Key('staff_identity_back')), 120);
          expect(find.byKey(const Key('staff_identity_back')), findsOneWidget);
          expect(tester.takeException(), isNull);

          await show(BlocProvider.value(value: institution, child: const StaffInstitutionScreen()));
          expect(find.byKey(const Key('staff_reject')), findsOneWidget);
        });
      }
    }

    testWidgets('approving an identity needs the reviewer to tick the match', (tester) async {
      final repo = _Reviews();
      final identity = StaffItemCubit<StaffIdentity>(
        read: GetStaffIdentityUseCase(repo).call,
        review: ReviewStaffIdentityUseCase(repo).call,
        id: 7,
      );
      addTearDown(identity.close);
      await tester.runAsync(() async {
        await identity.load();
        await tester.pumpWidget(_app(BlocProvider.value(value: identity, child: const StaffIdentityScreen())));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      await tester.tap(find.byKey(const Key('staff_approve')));
      await tester.pumpAndSettle();
      final yes = find.byKey(const Key('staff_approve_yes'));
      expect(tester.widget<TextButton>(yes).onPressed, isNull);

      await tester.tap(find.byKey(const Key('staff_approve_tick')));
      await tester.pump();
      expect(tester.widget<TextButton>(yes).onPressed, isNotNull);
    });
  });
}
