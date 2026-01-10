import 'package:equatable/equatable.dart';

import '../../domain/entities/recent_event_entity.dart';
import '../../domain/entities/stat_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<StatEntity> stats;
  final List<RecentEventEntity> recentEvents;
  final double responseRate;
  final int totalResponded;
  final int totalGuests;

  const HomeLoaded({
    required this.stats,
    required this.recentEvents,
    required this.responseRate,
    required this.totalResponded,
    required this.totalGuests,
  });

  @override
  List<Object?> get props => [
        stats,
        recentEvents,
        responseRate,
        totalResponded,
        totalGuests,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
