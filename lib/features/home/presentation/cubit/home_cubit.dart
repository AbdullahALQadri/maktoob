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
            // Calculate response rate from actual stats
            int totalGuests = 0;
            int totalResponded = 0;
            for (final stat in stats) {
              if (stat.label == 'Total Guests') {
                totalGuests = int.tryParse(stat.value.replaceAll(',', '')) ?? 0;
              }
              if (stat.label == 'Attending' || stat.label == 'Not Attending') {
                totalResponded += int.tryParse(stat.value.replaceAll(',', '')) ?? 0;
              }
            }
            final responseRate = totalGuests > 0 ? totalResponded.toDouble() / totalGuests : 0.0;

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
