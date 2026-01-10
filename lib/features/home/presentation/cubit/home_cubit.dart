import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_recent_events_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetStatsUseCase getStatsUseCase;
  final GetRecentEventsUseCase getRecentEventsUseCase;

  HomeCubit({
    required this.getStatsUseCase,
    required this.getRecentEventsUseCase,
  }) : super(const HomeInitial());

  Future<void> loadHomeData() async {
    emit(const HomeLoading());

    final statsResult = await getStatsUseCase();
    final eventsResult = await getRecentEventsUseCase();

    statsResult.fold(
      (failure) => emit(HomeError(message: failure.toString())),
      (stats) {
        eventsResult.fold(
          (failure) => emit(HomeError(message: failure.toString())),
          (events) {
            // Calculate response rate from stats
            // Default values based on mock data
            const totalGuests = 1234;
            const totalResponded = 1048;
            const responseRate = 0.85;

            emit(HomeLoaded(
              stats: stats,
              recentEvents: events,
              responseRate: responseRate,
              totalResponded: totalResponded,
              totalGuests: totalGuests,
            ));
          },
        );
      },
    );
  }

  void refresh() {
    loadHomeData();
  }
}
