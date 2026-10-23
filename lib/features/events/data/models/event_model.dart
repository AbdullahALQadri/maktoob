import 'package:flutter/material.dart';
import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  final List<Color> gradient;
  final IconData icon;

  const EventModel({
    required super.id,
    required super.name,
    required super.type,
    required super.date,
    required super.time,
    required super.venue,
    super.venueId,
    super.venueAddress,
    super.description,
    required super.invitations,
    required super.responses,
    required super.attending,
    super.declined,
    super.pending,
    super.checkedIn,
    required super.status,
    super.eventDate,
    super.rsvpDeadline,
    super.packageName,
    super.packagePrice,
    super.templateName,
    super.maxCompanions,
    super.allowCompanions,
    super.imageUrl,
    super.rawStatus,
    super.invoiceTotal,
    super.checkedInCompanions,
    super.attendees,
    super.myRole,
    super.allowedChannels,
    super.invitationsSentAt,
    super.invitationLimit,
    super.remainingInvitations,
    required this.gradient,
    required this.icon,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Handle both frontend format and backend API format
    final id = json['id'];
    final eventDate = json['event_date'];

    return EventModel(
      id: id is int ? id.toString() : (id as String? ?? ''),
      // `title` is the unified column (title_ar/title_en were merged); keep the
      // old keys as fallbacks for any cached/legacy payloads.
      name: json['name'] as String? ?? json['title'] as String? ?? json['title_ar'] as String? ?? json['title_en'] as String? ?? '',
      type: json['type'] as String? ?? _nameFrom(json['event_type']) ?? '',
      date: json['date'] as String? ?? _formatDateFromApi(eventDate),
      time: json['time'] as String? ?? json['event_time'] as String? ?? '',
      // venue may be a plain string OR a loaded relation Map — handle both
      // (casting a Map `as String?` would throw and fail the whole parse).
      venue: _nameFrom(json['venue']) ?? _nameFrom(json['venue_data']) ?? json['custom_venue_name_ar'] as String? ?? '',
      venueId: _parseInt(json['venue_id']) ??
          _parseInt(json['venue'] is Map ? json['venue']['id'] : null) ??
          _parseInt(json['venue_data'] is Map ? json['venue_data']['id'] : null),
      venueAddress: json['venue_address'] as String? ?? json['custom_venue_address_ar'] as String?,
      description: json['description'] as String? ?? json['description_ar'] as String?,
      invitations: _parseIntOrListLength(json['invitations']) ?? _parseIntOrListLength(json['max_invitations']) ?? 0,
      responses: _parseIntOrListLength(json['responses']) ?? 0,
      attending: _parseIntOrListLength(json['attending']) ?? 0,
      declined: _parseIntOrListLength(json['declined']) ?? 0,
      pending: _parseIntOrListLength(json['pending']) ?? 0,
      // `invitations_used` is the capacity ledger (invitations created), not
      // door check-ins — never fall back to it here.
      checkedIn: _parseIntOrListLength(json['checked_in']) ?? 0,
      status: _parseStatus(json['status'] as String? ?? 'draft'),
      eventDate: eventDate != null
          ? (eventDate is String ? DateTime.tryParse(eventDate) : null)
          : null,
      rsvpDeadline: json['rsvp_deadline'] != null || json['response_deadline'] != null
          ? DateTime.tryParse(json['rsvp_deadline'] as String? ?? json['response_deadline'] as String? ?? '')
          : null,
      packageName: json['package_name'] as String? ?? json['package']?['name_ar'] as String?,
      packagePrice: json['package_price'] as String? ?? (json['price'] != null ? '₪${json['price']}' : null),
      templateName: json['template_name'] as String? ?? json['template']?['name_ar'] as String?,
      maxCompanions: _parseIntOrListLength(json['max_companions']) ?? 2,
      allowCompanions: json['allow_companions'] as bool? ?? true,
      imageUrl: json['image_url'] as String? ??
          (json['final_ai_image'] is Map ? json['final_ai_image']['image_url'] as String? : null),
      rawStatus: json['status']?.toString(),
      invoiceTotal: double.tryParse('${json['invoice_total'] ?? ''}'),
      checkedInCompanions: _parseIntOrListLength(json['checked_in_companions']) ?? 0,
      attendees: _parseIntOrListLength(json['attendees']) ?? 0,
      myRole: json['my_role']?.toString(),
      allowedChannels: json['allowed_channels'] is List && (json['allowed_channels'] as List).isNotEmpty
          ? (json['allowed_channels'] as List).map((e) => '$e').toList()
          : const ['whatsapp'],
      invitationsSentAt: DateTime.tryParse('${json['invitations_sent_at'] ?? ''}'),
      invitationLimit: _parseInvitationLimit(json),
      remainingInvitations: _parseRemaining(json),
      gradient: _parseGradient(json['gradient']),
      icon: _parseIcon(json['icon']),
    );
  }

  /// Mirrors Event::getEffectiveInvitationsLimit(): the attached packages'
  /// `pivot.invitations_included` total, else `max_invitations`.
  /// Null (or 0) means no limit.
  static int? _parseInvitationLimit(Map<String, dynamic> json) {
    final explicit = _parseInt(json['invitation_limit']);
    if (explicit != null) return explicit > 0 ? explicit : null;
    final packages = json['packages'];
    if (packages is List) {
      var total = 0;
      for (final p in packages) {
        if (p is Map && p['pivot'] is Map) {
          total += _parseInt(p['pivot']['invitations_included']) ?? 0;
        }
      }
      if (total > 0) return total;
    }
    final max = _parseInt(json['max_invitations']);
    return (max != null && max > 0) ? max : null;
  }

  /// Mirrors Event::getRemainingInvitationsAttribute(). Null = unlimited.
  static int? _parseRemaining(Map<String, dynamic> json) {
    if (json.containsKey('remaining_invitations')) {
      return _parseInt(json['remaining_invitations']);
    }
    final limit = _parseInvitationLimit(json);
    if (limit == null) return null;
    final used = _parseInt(json['invitations_used']) ?? 0;
    return (limit - used).clamp(0, limit);
  }

  /// Returns a display name from a value that may be a plain String or a
  /// loaded relation Map ({name_ar / name_en / name}).
  static String? _nameFrom(dynamic value) {
    if (value is String) return value;
    if (value is Map) {
      return (value['name_ar'] ?? value['name_en'] ?? value['name']) as String?;
    }
    return null;
  }

  /// Parses an int from an int or numeric string; null otherwise.
  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parses a value that could be an int, a List (returns length), or null
  static int? _parseIntOrListLength(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is List) return value.length;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _formatDateFromApi(dynamic eventDate) {
    if (eventDate == null) return '';
    if (eventDate is String) {
      try {
        final date = DateTime.parse(eventDate);
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      } catch (_) {
        return eventDate;
      }
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'date': date,
      'time': time,
      'venue': venue,
      'venue_address': venueAddress,
      'description': description,
      'invitations': invitations,
      'responses': responses,
      'attending': attending,
      'declined': declined,
      'pending': pending,
      'checked_in': checkedIn,
      'status': _statusToString(status),
      'event_date': eventDate?.toIso8601String(),
      'rsvp_deadline': rsvpDeadline?.toIso8601String(),
      'package_name': packageName,
      'package_price': packagePrice,
      'template_name': templateName,
      'max_companions': maxCompanions,
      'allow_companions': allowCompanions,
      'image_url': imageUrl,
    };
  }

  factory EventModel.fromEntity(EventEntity entity, {
    required List<Color> gradient,
    required IconData icon,
  }) {
    return EventModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      date: entity.date,
      time: entity.time,
      venue: entity.venue,
      venueAddress: entity.venueAddress,
      description: entity.description,
      invitations: entity.invitations,
      responses: entity.responses,
      attending: entity.attending,
      declined: entity.declined,
      pending: entity.pending,
      checkedIn: entity.checkedIn,
      status: entity.status,
      eventDate: entity.eventDate,
      rsvpDeadline: entity.rsvpDeadline,
      packageName: entity.packageName,
      packagePrice: entity.packagePrice,
      templateName: entity.templateName,
      maxCompanions: entity.maxCompanions,
      allowCompanions: entity.allowCompanions,
      imageUrl: entity.imageUrl,
      rawStatus: entity.rawStatus,
      invoiceTotal: entity.invoiceTotal,
      checkedInCompanions: entity.checkedInCompanions,
      attendees: entity.attendees,
      myRole: entity.myRole,
      gradient: gradient,
      icon: icon,
      allowedChannels: entity.allowedChannels,
      invitationsSentAt: entity.invitationsSentAt,
      venueId: entity.venueId,
      invitationLimit: entity.invitationLimit,
      remainingInvitations: entity.remainingInvitations,
    );
  }

  EventEntity toEntity() {
    return EventEntity(
      id: id,
      name: name,
      type: type,
      date: date,
      time: time,
      venue: venue,
      venueAddress: venueAddress,
      description: description,
      invitations: invitations,
      responses: responses,
      attending: attending,
      declined: declined,
      pending: pending,
      checkedIn: checkedIn,
      status: status,
      eventDate: eventDate,
      rsvpDeadline: rsvpDeadline,
      packageName: packageName,
      packagePrice: packagePrice,
      templateName: templateName,
      maxCompanions: maxCompanions,
      allowCompanions: allowCompanions,
      imageUrl: imageUrl,
      rawStatus: rawStatus,
      invoiceTotal: invoiceTotal,
      checkedInCompanions: checkedInCompanions,
      attendees: attendees,
      myRole: myRole,
      allowedChannels: allowedChannels,
      invitationsSentAt: invitationsSentAt,
      venueId: venueId,
      invitationLimit: invitationLimit,
      remainingInvitations: remainingInvitations,
    );
  }

  static EventStatus _parseStatus(String status) => EventStatusApi.parse(status);

  static String _statusToString(EventStatus status) => status.apiValue;

  static List<Color> _parseGradient(dynamic gradient) {
    if (gradient is List) {
      return gradient.map((c) => Color(c as int)).toList();
    }
    return [Colors.purple, Colors.pink];
  }

  static const _knownIcons = [
    Icons.event,
    Icons.calendar_today,
    Icons.people,
    Icons.check_circle,
    Icons.cancel,
    Icons.celebration,
    Icons.cake,
    Icons.business,
    Icons.school,
    Icons.sports,
  ];

  static IconData _parseIcon(dynamic icon) {
    if (icon is int) {
      for (final knownIcon in _knownIcons) {
        if (knownIcon.codePoint == icon) return knownIcon;
      }
    }
    return Icons.event;
  }

  EventModel copyWith({
    String? id,
    String? name,
    String? type,
    String? date,
    String? time,
    String? venue,
    String? venueAddress,
    String? description,
    int? invitations,
    int? responses,
    int? attending,
    int? declined,
    int? pending,
    int? checkedIn,
    EventStatus? status,
    DateTime? eventDate,
    DateTime? rsvpDeadline,
    String? packageName,
    String? packagePrice,
    String? templateName,
    int? maxCompanions,
    bool? allowCompanions,
    String? imageUrl,
    List<Color>? gradient,
    IconData? icon,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      venueAddress: venueAddress ?? this.venueAddress,
      description: description ?? this.description,
      invitations: invitations ?? this.invitations,
      responses: responses ?? this.responses,
      attending: attending ?? this.attending,
      declined: declined ?? this.declined,
      pending: pending ?? this.pending,
      checkedIn: checkedIn ?? this.checkedIn,
      status: status ?? this.status,
      eventDate: eventDate ?? this.eventDate,
      rsvpDeadline: rsvpDeadline ?? this.rsvpDeadline,
      packageName: packageName ?? this.packageName,
      packagePrice: packagePrice ?? this.packagePrice,
      templateName: templateName ?? this.templateName,
      maxCompanions: maxCompanions ?? this.maxCompanions,
      allowCompanions: allowCompanions ?? this.allowCompanions,
      imageUrl: imageUrl ?? this.imageUrl,
      rawStatus: rawStatus,
      invoiceTotal: invoiceTotal,
      checkedInCompanions: checkedInCompanions,
      attendees: attendees,
      myRole: myRole,
      allowedChannels: allowedChannels,
      invitationsSentAt: invitationsSentAt,
      venueId: venueId,
      invitationLimit: invitationLimit,
      remainingInvitations: remainingInvitations,
      gradient: gradient ?? this.gradient,
      icon: icon ?? this.icon,
    );
  }
}
