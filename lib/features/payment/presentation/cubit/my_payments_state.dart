import 'package:equatable/equatable.dart';

import '../../domain/entities/my_payments.dart';

abstract class MyPaymentsState extends Equatable {
  const MyPaymentsState();

  @override
  List<Object?> get props => [];
}

class MyPaymentsInitial extends MyPaymentsState {
  const MyPaymentsInitial();
}

class MyPaymentsLoading extends MyPaymentsState {
  const MyPaymentsLoading();
}

class MyPaymentsLoaded extends MyPaymentsState {
  final MyPayments payments;

  const MyPaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class MyPaymentsError extends MyPaymentsState {
  final String message;

  const MyPaymentsError(this.message);

  @override
  List<Object?> get props => [message];
}
