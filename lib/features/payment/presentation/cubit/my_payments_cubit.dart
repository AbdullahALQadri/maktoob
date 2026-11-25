import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_my_payments_usecase.dart';
import 'my_payments_state.dart';

/// "My payments": receipts, what is due and the receipts under review.
class MyPaymentsCubit extends Cubit<MyPaymentsState> {
  final GetMyPaymentsUseCase getMyPayments;

  MyPaymentsCubit({required this.getMyPayments}) : super(const MyPaymentsInitial());

  Future<void> load() async {
    // Keep what is shown while refreshing (pull to refresh, back online).
    if (state is! MyPaymentsLoaded) emit(const MyPaymentsLoading());
    final result = await getMyPayments(NoParams());
    if (isClosed) return;
    result.fold(
      (failure) {
        if (state is! MyPaymentsLoaded) emit(MyPaymentsError(failure.message ?? ''));
      },
      (payments) => emit(MyPaymentsLoaded(payments)),
    );
  }

  /// The receipt link is signed for a short time and the list may come from
  /// the offline cache: fetch a fresh one just before opening it. Falls back
  /// to the link already shown when the phone is offline.
  Future<String?> freshReceiptUrl(int paymentId) async {
    final result = await getMyPayments(NoParams());
    if (isClosed) return null;
    return result.fold(
      (_) => _shownUrl(paymentId),
      (payments) {
        emit(MyPaymentsLoaded(payments));
        for (final r in payments.receipts) {
          if (r.id == paymentId) return r.receiptUrl;
        }
        return null;
      },
    );
  }

  String? _shownUrl(int paymentId) {
    final current = state;
    if (current is! MyPaymentsLoaded) return null;
    for (final r in current.payments.receipts) {
      if (r.id == paymentId) return r.receiptUrl;
    }
    return null;
  }
}
