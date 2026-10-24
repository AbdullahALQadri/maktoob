import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/home/domain/entities/home_summary.dart';
import 'package:maktoob/features/home/domain/repositories/home_repository.dart';
import 'package:maktoob/features/home/domain/usecases/get_home_usecase.dart';
import 'package:maktoob/features/home/presentation/cubit/home_cubit.dart';
import 'package:maktoob/features/home/presentation/cubit/home_state.dart';

class _ScriptedRepository implements HomeRepository {
  _ScriptedRepository(this.answers);

  final List<Either<Failure, HomeSummary>> answers;

  @override
  Future<Either<Failure, HomeSummary>> getHome() async => answers.removeAt(0);
}

const _home = HomeSummary(totals: HomeTotals(events: 2), events: [], gazaOffset: Duration(hours: 2));
const _failure = NetworkFailure(message: 'offline');

HomeCubit _cubit(List<Either<Failure, HomeSummary>> answers) =>
    HomeCubit(getHome: GetHomeUseCase(_ScriptedRepository(answers)));

void main() {
  test('first load shows the skeleton, then the home', () async {
    final cubit = _cubit([const Right(_home)]);
    final states = expectLater(cubit.stream, emitsInOrder([const HomeLoading(), const HomeLoaded(_home)]));

    await cubit.load();
    await states;
  });

  test('a failed first load shows the error with its message', () async {
    final cubit = _cubit([const Left(_failure)]);
    await cubit.load();
    expect(cubit.state, const HomeError('offline'));
  });

  test('a failed refresh keeps the last good home on screen', () async {
    final cubit = _cubit([const Right(_home), const Left(_failure)]);
    await cubit.load();
    final states = <HomeState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.load();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states, isEmpty);
    expect(cubit.state, const HomeLoaded(_home));
  });
}
