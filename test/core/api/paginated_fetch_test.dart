import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/api/api_consumer.dart';
import 'package:maktoob/core/api/paginated_fetch.dart';

/// Serves one response per page from GET and records every query it got.
class _PagedApi implements ApiConsumer {
  final dynamic Function(int page) pageFor;
  final queries = <Map<String, dynamic>>[];
  _PagedApi(this.pageFor);

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    queries.add(Map.of(queryParameters ?? const {}));
    return pageFor(queryParameters?['page'] as int? ?? 1);
  }

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async => {};
  @override
  Future<dynamic> put(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async => {};
  @override
  Future<dynamic> delete(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async => {};
  @override
  Future<dynamic> postWithImage(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async => {};
  @override
  Future<dynamic> postCreateService(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async => {};
  @override
  Future<dynamic> postRegister(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async => {};
}

List<Map<String, dynamic>> _items(int page, [int n = 2]) =>
    [for (var i = 0; i < n; i++) {'id': page * 10 + i}];

int _id(Map<String, dynamic> j) => j['id'] as int;

void main() {
  group('Pagination.lastPageOf reads every backend shape', () {
    test('raw Laravel paginator', () {
      expect(Pagination.lastPageOf({'data': [], 'current_page': 1, 'last_page': 4}), 4);
    });
    test('ApiResponse::paginated meta', () {
      expect(Pagination.lastPageOf({'success': true, 'data': [], 'meta': {'last_page': 3}}), 3);
    });
    test('Resource collection with links + meta', () {
      expect(
        Pagination.lastPageOf({
          'data': [],
          'links': {'next': 'x'},
          'meta': {'current_page': 1, 'last_page': '5'},
        }),
        5,
      );
    });
    test('{items, pagination}', () {
      expect(Pagination.lastPageOf({'payment_requests': [], 'pagination': {'last_page': 2}}), 2);
    });
    test('none', () {
      expect(Pagination.lastPageOf({'data': []}), isNull);
      expect(Pagination.lastPageOf([1, 2]), isNull);
      expect(Pagination.lastPageOf(null), isNull);
    });
  });

  group('Pagination.fetchAll', () {
    test('raw paginator: walks to last_page and sends per_page/page', () async {
      final api = _PagedApi((p) => {'data': _items(p), 'current_page': p, 'last_page': 3});
      final ids = await Pagination.fetchAll(api, '/venues',
          query: {'search': 'x'}, perPage: 100, parse: _id);
      expect(ids, [10, 11, 20, 21, 30, 31]);
      expect(api.queries.length, 3);
      expect(api.queries.first, {'search': 'x', 'per_page': 100, 'page': 1});
      expect(api.queries.last['page'], 3);
    });

    test('ApiResponse meta shape', () async {
      final api = _PagedApi((p) => {'success': true, 'data': _items(p), 'meta': {'last_page': 2}});
      expect(await Pagination.fetchAll(api, '/n', parse: _id), [10, 11, 20, 21]);
      expect(api.queries.length, 2);
    });

    test('Resource collection shape', () async {
      final api = _PagedApi((p) => {
            'data': _items(p),
            'links': {'next': p < 2 ? 'next' : null},
            'meta': {'current_page': p, 'last_page': 2},
          });
      expect(await Pagination.fetchAll(api, '/events/1/invitations', perPage: 200, parse: _id),
          [10, 11, 20, 21]);
      expect(api.queries.first['per_page'], 200);
    });

    test('{items, pagination} shape via listKeys', () async {
      final api = _PagedApi((p) => {'payment_requests': _items(p), 'pagination': {'last_page': 2}});
      expect(
        await Pagination.fetchAll(api, '/payment-requests',
            listKeys: const ['payment_requests', 'data'], parse: _id),
        [10, 11, 20, 21],
      );
    });

    test('stops at last_page even if more would be served', () async {
      final api = _PagedApi((p) => {'data': _items(p), 'last_page': 1});
      expect(await Pagination.fetchAll(api, '/x', parse: _id), [10, 11]);
      expect(api.queries.length, 1);
    });

    test('respects maxPages', () async {
      final api = _PagedApi((p) => {'data': _items(p, 1), 'last_page': 999});
      final ids = await Pagination.fetchAll(api, '/x', maxPages: 4, parse: _id);
      expect(ids, [10, 20, 30, 40]);
      expect(api.queries.length, 4);
    });

    test('stops on an empty page or a response without last_page', () async {
      final empty = _PagedApi((p) => {'data': p == 1 ? _items(1) : [], 'last_page': 9});
      expect(await Pagination.fetchAll(empty, '/x', parse: _id), [10, 11]);
      expect(empty.queries.length, 2);

      final noMeta = _PagedApi((p) => {'data': _items(p)});
      expect(await Pagination.fetchAll(noMeta, '/x', parse: _id), [10, 11]);
      expect(noMeta.queries.length, 1);
    });
  });
}
