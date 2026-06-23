/// A scanner-staff venue/event assignment returned by
/// GET /scanner/assignments/active.
class ScannerAssignment {
  final int id;
  final int venueId;
  final String venueName;
  final int? eventId;
  final String? eventTitle;
  final String? eventDate;
  final String? eventTime;

  const ScannerAssignment({
    required this.id,
    required this.venueId,
    required this.venueName,
    this.eventId,
    this.eventTitle,
    this.eventDate,
    this.eventTime,
  });

  factory ScannerAssignment.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'] is Map ? json['venue'] as Map : const {};
    final event = json['event'] is Map ? json['event'] as Map : null;

    int toInt(dynamic v) =>
        v is int ? v : (v is String ? int.tryParse(v) ?? 0 : 0);

    return ScannerAssignment(
      id: toInt(json['id']),
      venueId: toInt(venue['id']),
      venueName: (venue['name_ar'] ?? venue['name'] ?? '') as String,
      eventId: event != null ? toInt(event['id']) : null,
      eventTitle: event?['title'] as String?,
      eventDate: event?['event_date'] as String?,
      eventTime: event?['event_time'] as String?,
    );
  }
}
