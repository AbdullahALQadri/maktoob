import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/identity_entities.dart';
import '../../domain/identity_failures.dart';
import '../../domain/usecases/get_identity_usecase.dart';
import '../../domain/usecases/submit_identity_usecase.dart';
import 'identity_state.dart';

/// Identity verification (KYC): the client's state, submissions and form options.
class IdentityCubit extends Cubit<IdentityState> {
  final GetIdentityUseCase getIdentity;
  final SubmitIdentityUseCase submitIdentity;

  IdentityCubit({required this.getIdentity, required this.submitIdentity}) : super(const IdentityInitial());

  /// The app language for the option labels; set by the screen.
  String? locale;

  Future<void> load({bool silent = false, String? locale}) async {
    if (locale != null) this.locale = locale;
    final current = state;
    if (!silent || current is! IdentityLoaded) emit(const IdentityLoading());
    final result = await getIdentity(GetIdentityParams(locale: this.locale));
    result.fold(
      (f) {
        // Keep what is on screen when a silent refresh fails.
        if (silent && current is IdentityLoaded) return;
        emit(IdentityError(f.message ?? 'identity_load_failed'));
      },
      (overview) => emit(IdentityLoaded(overview)),
    );
  }

  /// `POST /auth/identity`. Returns true when the server accepted it.
  Future<bool> submit(IdentitySubmissionInput input) async {
    final current = state;
    final base = current is IdentityLoaded ? current : const IdentityLoaded(IdentityOverviewEntity());
    emit(base.copyWith(isSubmitting: true, fieldErrors: const {}));

    final result = await submitIdentity(input);
    return result.fold(
      (f) {
        emit(base.copyWith(
          isSubmitting: false,
          message: f.message ?? 'identity_submit_failed',
          messageIsError: true,
          fieldErrors: f is IdentityValidationFailure ? f.fieldErrors : const {},
        ));
        return false;
      },
      (identity) {
        emit(base.copyWith(
          overview: base.overview.copyWith(identity: identity),
          isSubmitting: false,
          justSubmitted: true,
          message: 'identity_submitted_message',
          fieldErrors: const {},
        ));
        // The submissions list comes from GET.
        load(silent: true);
        return true;
      },
    );
  }
}
