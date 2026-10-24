import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_home_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.getHome}) : super(const HomeInitial());

  final GetHomeUseCase getHome;

  /// Loads the home screen. A refresh keeps what is on screen until the new
  /// answer arrives, so pulling to refresh never flashes the skeleton, and a
  /// failed refresh keeps the last good screen.
  Future<void> load() async {
    final hadContent = state is HomeLoaded;
    if (!hadContent) emit(const HomeLoading());

    final result = await getHome();
    if (isClosed) return;

    result.fold((failure) {
      if (!hadContent) emit(HomeError(failure.message ?? ''));
    }, (summary) => emit(HomeLoaded(summary)));
  }
}
