import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_pay_currencies_usecase.dart';
import 'pay_currency_state.dart';

/// "Pay in": which currency the client pays an event in.
class PayCurrencyCubit extends Cubit<PayCurrencyState> {
  PayCurrencyCubit({required this.getPayCurrencies}) : super(const PayCurrencyState());

  final GetPayCurrenciesUseCase getPayCurrencies;

  Future<void> load(String eventId) async {
    if (eventId.isEmpty) return;
    final result = await getPayCurrencies(eventId);
    if (isClosed) return;
    // A failure leaves the shekel as the only way: paying is never blocked.
    result.fold((_) {}, (currencies) => emit(PayCurrencyState(currencies: currencies)));
  }

  void select(String code) {
    if (code == state.selectedCode) return;
    emit(PayCurrencyState(currencies: state.currencies, selectedCode: code));
  }
}
