import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_state.dart';
import 'package:maktoob/features/identity/domain/entities/identity_entities.dart';
import 'package:maktoob/features/identity/domain/repositories/identity_repository.dart';
import 'package:maktoob/features/identity/domain/usecases/get_identity_usecase.dart';
import 'package:maktoob/features/identity/domain/usecases/submit_identity_usecase.dart';
import 'package:maktoob/features/identity/presentation/cubit/identity_cubit.dart';
import 'package:maktoob/features/identity/presentation/screens/identity_verification_screen.dart';
import 'package:maktoob/features/institution/domain/entities/institution_entity.dart';
import 'package:maktoob/features/institution/domain/repositories/institution_repository.dart';
import 'package:maktoob/features/institution/presentation/cubit/institution_cubit.dart';
import 'package:maktoob/features/institution/presentation/screens/institution_profile_form_screen.dart';
import 'package:maktoob/features/institution/presentation/screens/institution_screen.dart';

class _Auth extends Cubit<AuthState> implements AuthCubit {
  _Auth() : super(AuthInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Identity implements IdentityRepository {
  @override
  Future<Either<Failure, IdentityOverviewEntity>> getOverview({String? locale}) async =>
      const Right(IdentityOverviewEntity());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _institution = InstitutionEntity(
  id: 4,
  status: InstitutionStatus.pending,
  nameAr: 'جمعية الأمل الخيرية للتنمية والإغاثة في قطاع غزة',
);

class _Institutions implements InstitutionRepository {
  @override
  Future<Either<Failure, InstitutionOverviewEntity>> getOverview() async =>
      const Right(InstitutionOverviewEntity(isInstitutionAccount: true, institution: _institution));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _viewports = <(String, Size, double)>[
  ('small phone', Size(320, 568), 1.0),
  ('phone, very large text', Size(390, 844), 2.0),
  ('desktop', Size(1280, 800), 1.0),
];

void main() {
  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final (name, size, textScale) in _viewports) {
      for (final brightness in Brightness.values) {
        testWidgets('${locale.languageCode}, ${brightness.name}: $name', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = textScale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          final auth = _Auth();
          final identityRepo = _Identity();
          final identity = IdentityCubit(
            getIdentity: GetIdentityUseCase(identityRepo),
            submitIdentity: SubmitIdentityUseCase(identityRepo),
          );
          final institution = InstitutionCubit(repository: _Institutions());
          addTearDown(auth.close);
          addTearDown(identity.close);
          addTearDown(institution.close);
          await tester.runAsync(institution.load);

          Future<void> show(Widget page, String what) async {
            await tester.runAsync(() async {
              await tester.pumpWidget(MultiBlocProvider(
                providers: [
                  BlocProvider<AuthCubit>.value(value: auth),
                  BlocProvider<IdentityCubit>.value(value: identity),
                  BlocProvider<InstitutionCubit>.value(value: institution),
                ],
                child: MaterialApp(
                  locale: locale,
                  theme: ThemeData(brightness: brightness),
                  supportedLocales: AppLocalizationsSetup.supportedLocales,
                  localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
                  home: page,
                ),
              ));
              await Future<void>.delayed(const Duration(milliseconds: 300));
            });
            await tester.pump();
            // The screen asks for its data when it opens: let the answer land.
            await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
            await tester.pump();
            expect(tester.takeException(), isNull, reason: what);
          }

          // Nothing sent yet: the status and the form to send a document.
          await show(const IdentityVerificationScreen(), 'identity');
          await tester.scrollUntilVisible(find.byKey(const Key('identity_document_type')), 150, scrollable: find.byType(Scrollable).first);
          expect(tester.takeException(), isNull, reason: 'identity form');

          await show(const InstitutionScreen(), 'institution');
          expect(find.textContaining('جمعية الأمل'), findsWidgets);

          await show(const InstitutionProfileFormScreen(), 'institution form top');
          await tester.scrollUntilVisible(find.byKey(const Key('institution_name_ar')), 150, scrollable: find.byType(Scrollable).first);
          expect(tester.takeException(), isNull, reason: 'institution form');
        });
      }
    }
  }
}
