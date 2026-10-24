import 'package:equatable/equatable.dart';

import 'event_entity.dart';

/// What the client should do next on an event. Same order and meaning as
/// the web portal (backend `ClientEventProgress::nextAction`).
enum NextAction {
  completeDetails,
  addGuests,
  chooseDesign,
  pay,
  trackPayment,
  sendInvitations,
  viewResults;

  static NextAction fromKey(String? key) => switch (key) {
    'complete_details' => NextAction.completeDetails,
    'add_guests' => NextAction.addGuests,
    'choose_design' => NextAction.chooseDesign,
    'pay' => NextAction.pay,
    'track_payment' => NextAction.trackPayment,
    'send_invitations' => NextAction.sendInvitations,
    _ => NextAction.viewResults,
  };

  /// Translation key of the action's button.
  String get labelKey => switch (this) {
    NextAction.completeDetails => 'home_next_complete_details',
    NextAction.addGuests => 'home_next_add_guests',
    NextAction.chooseDesign => 'home_next_choose_design',
    NextAction.pay => 'home_next_pay',
    NextAction.trackPayment => 'home_next_track_payment',
    NextAction.sendInvitations => 'home_next_send',
    NextAction.viewResults => 'home_next_results',
  };
}

/// One event as the home cards show it (backend `ClientEventCard`).
class EventCard extends Equatable {
  const EventCard({
    required this.id,
    required this.title,
    required this.status,
    required this.role,
    required this.nextAction,
    this.typeNameAr,
    this.typeNameEn,
    this.date,
    this.imageUrl,
    this.invitations = 0,
    this.opened = 0,
    this.responded = 0,
    this.countdownDays,
    this.stepNumber,
    this.stepsTotal = 6,
  });

  final int id;
  final String title;
  final EventStatus status;
  final EventRole role;
  final NextAction nextAction;
  final String? typeNameAr;
  final String? typeNameEn;

  /// Wall-clock date and time in Gaza, as the host announced it.
  final DateTime? date;
  final String? imageUrl;
  final int invitations;
  final int opened;
  final int responded;

  /// Whole days to the event; 0 is today, negative has passed.
  final int? countdownDays;

  /// 1-based setup step while the event is a draft or awaits payment.
  final int? stepNumber;
  final int stepsTotal;

  bool get inSetup => stepNumber != null;

  /// Share of guests who answered, 0..1.
  double get responseShare => invitations == 0 ? 0 : responded / invitations;

  String? typeName(String languageCode) =>
      languageCode == 'ar' ? (typeNameAr ?? typeNameEn) : (typeNameEn ?? typeNameAr);

  @override
  List<Object?> get props => [
    id,
    title,
    status,
    role,
    nextAction,
    date,
    imageUrl,
    invitations,
    opened,
    responded,
    countdownDays,
    stepNumber,
  ];
}
