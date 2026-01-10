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
    required this.gradient,
    required this.icon,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      venue: json['venue'] as String,
      venueAddress: json['venue_address'] as String?,
      description: json['description'] as String?,
      invitations: json['invitations'] as int,
      responses: json['responses'] as int,
      attending: json['attending'] as int,
      declined: json['declined'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      checkedIn: json['checked_in'] as int? ?? 0,
      status: _parseStatus(json['status'] as String),
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'] as String)
          : null,
      rsvpDeadline: json['rsvp_deadline'] != null
          ? DateTime.parse(json['rsvp_deadline'] as String)
          : null,
      packageName: json['package_name'] as String?,
      packagePrice: json['package_price'] as String?,
      templateName: json['template_name'] as String?,
      maxCompanions: json['max_companions'] as int? ?? 2,
      allowCompanions: json['allow_companions'] as bool? ?? true,
      gradient: _parseGradient(json['gradient']),
      icon: _parseIcon(json['icon']),
    );
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
      gradient: gradient,
      icon: icon,
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
    );
  }

  static EventStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return EventStatus.active;
      case 'draft':
        return EventStatus.draft;
      case 'completed':
        return EventStatus.completed;
      default:
        return EventStatus.draft;
    }
  }

  static String _statusToString(EventStatus status) {
    switch (status) {
      case EventStatus.active:
        return 'active';
      case EventStatus.draft:
        return 'draft';
      case EventStatus.completed:
        return 'completed';
    }
  }

  static List<Color> _parseGradient(dynamic gradient) {
    if (gradient is List) {
      return gradient.map((c) => Color(c as int)).toList();
    }
    return [Colors.purple, Colors.pink];
  }

  static IconData _parseIcon(dynamic icon) {
    if (icon is int) {
      return IconData(icon, fontFamily: 'MaterialIcons');
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
      gradient: gradient ?? this.gradient,
      icon: icon ?? this.icon,
    );
  }
}
