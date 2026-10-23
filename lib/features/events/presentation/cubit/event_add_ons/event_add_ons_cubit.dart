import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';

import '../../../domain/entities/event_add_ons_entity.dart';
import '../../../domain/usecases/get_event_add_ons_usecase.dart';
import '../../../domain/usecases/request_event_add_on_usecase.dart';
import '../../../domain/usecases/withdraw_event_add_on_usecase.dart';
import 'event_add_ons_state.dart';

/// Extra services on a paid event: list, request, withdraw. Paying goes
/// through the shared payment screen (POST /events/{id}/add-ons/pay).
class EventAddOnsCubit extends Cubit<EventAddOnsState> {
  final GetEventAddOnsUseCase getAddOns;
  final RequestEventAddOnUseCase requestAddOn;
  final WithdrawEventAddOnUseCase withdrawAddOn;

  EventAddOnsCubit({
    required this.getAddOns,
    required this.requestAddOn,
    required this.withdrawAddOn,
  }) : super(const EventAddOnsInitial());

  int? _eventId;

  Future<void> load(int eventId) async {
    _eventId = eventId;
    if (state is! EventAddOnsLoaded) emit(const EventAddOnsLoading());
    final result = await getAddOns(eventId);
    if (isClosed) return;
    result.fold(
      (f) => emit(EventAddOnsError(f.message ?? 'error')),
      (addOns) => emit(EventAddOnsLoaded(addOns)),
    );
  }

  Future<void> request(int serviceId, {String? notes}) =>
      _act(() => requestAddOn(_eventId!, serviceId, notes: notes), 'add_on_request_sent');

  Future<void> withdraw(int serviceId) =>
      _act(() => withdrawAddOn(_eventId!, serviceId), 'add_on_withdrawn');

  Future<void> _act(
    Future<Either<Failure, EventAddOnsEntity>> Function() call,
    String successKey,
  ) async {
    final current = state;
    if (_eventId == null || current is! EventAddOnsLoaded) return;
    emit(EventAddOnsLoaded(current.addOns, busy: true));
    final result = await call();
    if (isClosed) return;
    result.fold(
      (f) => emit(EventAddOnsLoaded(current.addOns, notice: f.message)),
      (addOns) => emit(EventAddOnsLoaded(addOns, notice: successKey)),
    );
  }
}
