import 'api_consumer.dart';

/// Reads the backend's paginated responses, whatever shape they come in,
/// and walks every page of a list endpoint (bounded).
///
/// The shapes the backend returns:
/// * raw Laravel paginator: `{data: [...], current_page, last_page, ...}`
///   (GET /events, GET /venues);
/// * `ApiResponse::paginated`: `{success, message, data: [...], meta: {last_page, ...}}`
///   (GET /notifications);
/// * API Resource collection: `{data: [...], links: {...}, meta: {last_page, ...}}`
///   (GET /events/{id}/invitations);
/// * `{<items>: [...], pagination: {last_page, ...}}` (pass the list key
///   through `listKeys`).
class Pagination {
  Pagination._();

  /// The `last_page` of [response], or null when it carries none.
  static int? lastPageOf(dynamic response) {
    if (response is! Map) return null;
    int? read(dynamic m) => m is Map ? _toInt(m['last_page']) : null;
    return _toInt(response['last_page']) ??
        read(response['meta']) ??
        read(response['pagination']) ??
        // A paginator nested under data: {success, data: {data: [], last_page}}.
        read(response['data']);
  }

  /// The `current_page` of [response], or null when it carries none.
  static int? currentPageOf(dynamic response) {
    if (response is! Map) return null;
    int? read(dynamic m) => m is Map ? _toInt(m['current_page']) : null;
    return _toInt(response['current_page']) ??
        read(response['meta']) ??
        read(response['pagination']) ??
        read(response['data']);
  }

  /// The list of items in [response]: the first of [listKeys] that holds a
  /// list, then `data.data` (a nested paginator), then [response] itself
  /// when it is already a list.
  static List<Map<String, dynamic>> itemsOf(
    dynamic response, {
    List<String> listKeys = const ['data'],
  }) {
    List? list;
    if (response is List) {
      list = response;
    } else if (response is Map) {
      for (final key in listKeys) {
        if (response[key] is List) {
          list = response[key] as List;
          break;
        }
      }
      final data = response['data'];
      if (list == null && data is Map && data['data'] is List) {
        list = data['data'] as List;
      }
    }
    return (list ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// GETs [path] page by page (`per_page` = [perPage], `page` = 1, 2, ...)
  /// until the response's `last_page` is reached, a page comes back empty,
  /// the response carries no `last_page`, or [maxPages] pages were read.
  static Future<List<T>> fetchAll<T>(
    ApiConsumer api,
    String path, {
    required T Function(Map<String, dynamic> json) parse,
    Map<String, dynamic> query = const {},
    int perPage = 50,
    int maxPages = 20,
    List<String> listKeys = const ['data'],
  }) async {
    final items = <T>[];
    for (var page = 1; page <= maxPages; page++) {
      final response = await api.get(
        path,
        queryParameters: {...query, 'per_page': perPage, 'page': page},
      );
      final list = itemsOf(response, listKeys: listKeys);
      items.addAll(list.map(parse));
      final lastPage = lastPageOf(response);
      if (lastPage == null || page >= lastPage || list.isEmpty) break;
    }
    return items;
  }

  static int? _toInt(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('${v ?? ''}'));
}
