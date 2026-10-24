import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/events/domain/entities/event_card.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';
import 'package:maktoob/features/events/domain/entities/event_page.dart';
import 'package:maktoob/features/events/domain/repositories/my_events_repository.dart';
import 'package:maktoob/features/events/domain/usecases/get_my_events_usecase.dart';
import 'package:maktoob/features/events/presentation/cubit/my_events/my_events_cubit.dart';
import 'package:maktoob/features/events/presentation/cubit/my_events/my_events_state.dart';

EventCard card(int id) => EventCard(
  id: id,
  title: 'e$id',
  status: EventStatus.active,
  role: EventRole.owner,
  nextAction: NextAction.viewResults,
);

/// Answers from a script; each call records what was asked.
class _Repository implements MyEventsRepository {
  final calls = <(EventStatus?, String, int)>[];
  final answers = <Completer<Either<Failure, EventPage>>>[];

  @override
  Future<Either<Failure, EventPage>> getPage({EventStatus? status, String query = '', int page = 1}) {
    calls.add((status, query, page));
    final answer = Completer<Either<Failure, EventPage>>();
    answers.add(answer);
    return answer.future;
  }

  void answer(int index, List<int> ids, {int page = 1, int lastPage = 1}) => answers[index].complete(
    Right(
      EventPage(
        items: ids.map(card).toList(),
        page: page,
        lastPage: lastPage,
        counts: EventCounts(all: 9, byStatus: const {EventStatus.active: 4}),
      ),
    ),
  );
}

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _Repository repo;
  late MyEventsCubit cubit;

  setUp(() {
    repo = _Repository();
    cubit = MyEventsCubit(getPage: GetMyEventsUseCase(repo));
  });
  tearDown(() => cubit.close());

  test('loads the first page with its counts, then the next one', () async {
    cubit.load();
    repo.answer(0, [1, 2], lastPage: 2);
    await settle();
    expect(cubit.state.items.map((e) => e.id), [1, 2]);
    expect(cubit.state.counts.of(EventStatus.active), 4);
    expect(cubit.state.hasMore, isTrue);

    cubit.loadMore();
    expect(cubit.state.phase, MyEventsPhase.loadingMore);
    repo.answer(1, [3], page: 2, lastPage: 2);
    await settle();
    expect(cubit.state.items.map((e) => e.id), [1, 2, 3]);
    expect(repo.calls.last, (null, '', 2));
  });

  test('a status tab starts the list over with that status', () async {
    cubit.load();
    repo.answer(0, [1]);
    await settle();

    cubit.showStatus(EventStatus.active);
    expect(cubit.state.items, isEmpty);
    expect(cubit.state.phase, MyEventsPhase.loading);
    expect(repo.calls.last, (EventStatus.active, '', 1));
  });

  test('search waits for the typing to stop', () async {
    cubit.search('ز');
    cubit.search('زف');
    cubit.search(' زفاف ');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(repo.calls, [(null, 'زفاف', 1)]);
  });

  test('a slow older answer never replaces a newer one', () async {
    cubit.load();
    cubit.showStatus(EventStatus.draft);
    repo.answer(1, [7]);
    await settle();
    repo.answer(0, [1, 2]);
    await settle();
    expect(cubit.state.items.map((e) => e.id), [7]);
  });

  test('clearing the filters asks for every event again', () async {
    cubit.showStatus(EventStatus.draft);
    cubit.clearFilters();
    expect(cubit.state.isFiltered, isFalse);
    expect(repo.calls.last, (null, '', 1));
  });

  test('a failed next page keeps what is on screen', () async {
    cubit.load();
    repo.answer(0, [1], lastPage: 2);
    await settle();
    cubit.loadMore();
    repo.answers[1].complete(const Left(NetworkFailure(message: 'offline')));
    await settle();
    expect(cubit.state.phase, MyEventsPhase.loaded);
    expect(cubit.state.items.map((e) => e.id), [1]);
  });
}
