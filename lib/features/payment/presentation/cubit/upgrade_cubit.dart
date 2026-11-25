import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/billing_usecases.dart';
import 'upgrade_state.dart';

/// "Increase invitations" for one active event.
class UpgradeCubit extends Cubit<UpgradeState> {
  UpgradeCubit({required this.getOptions, required this.getCustomQuote, required this.eventId})
      : super(const UpgradeState());

  final GetUpgradeOptionsUseCase getOptions;
  final GetCustomUpgradeQuoteUseCase getCustomQuote;
  final String eventId;

  Future<void> load() async {
    emit(const UpgradeState());
    final result = await getOptions(eventId);
    if (isClosed) return;
    emit(result.fold(
      (failure) => UpgradeState(loading: false, error: failure.message ?? ''),
      (options) => UpgradeState(loading: false, options: options),
    ));
  }

  void selectPackage(int id) => emit(state.copyWith(clearChoice: true).copyWith(packageId: id));

  /// Prices the number the host typed. It must be more than the event has.
  Future<void> calculateCustom(int? invitations) async {
    final current = state.options?.currentLimit ?? 0;
    if (invitations == null || invitations <= current) {
      return emit(state.copyWith(clearChoice: true, customError: 'upgrade_need_more'));
    }
    emit(state.copyWith(clearChoice: true, calculating: true));
    final result = await getCustomQuote(CustomUpgradeParams(eventId: eventId, invitations: invitations));
    if (isClosed) return;
    emit(result.fold(
      (failure) => state.copyWith(calculating: false, customError: failure.message ?? 'upgrade_need_more'),
      (quote) => state.copyWith(calculating: false, customInvitations: invitations, customQuote: quote),
    ));
  }
}
