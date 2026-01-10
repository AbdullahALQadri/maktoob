import 'package:flutter/material.dart';

import '../../domain/entities/recent_event_entity.dart';

class RecentEventModel extends RecentEventEntity {
  const RecentEventModel({
    required super.id,
    required super.name,
    required super.date,
    required super.venue,
    required super.invitations,
    required super.responses,
    required super.attending,
    required super.gradientColors,
  });

  factory RecentEventModel.fromJson(Map<String, dynamic> json) {
    return RecentEventModel(
      id: json['id'] as int,
      name: json['name'] as String,
      date: json['date'] as String,
      venue: json['venue'] as String,
      invitations: json['invitations'] as int,
      responses: json['responses'] as int,
      attending: json['attending'] as int,
      gradientColors: (json['gradientColors'] as List<dynamic>)
          .map((c) => Color(c as int))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'venue': venue,
      'invitations': invitations,
      'responses': responses,
      'attending': attending,
      'gradientColors': gradientColors.map((c) => c.value).toList(),
    };
  }

  factory RecentEventModel.fromEntity(RecentEventEntity entity) {
    return RecentEventModel(
      id: entity.id,
      name: entity.name,
      date: entity.date,
      venue: entity.venue,
      invitations: entity.invitations,
      responses: entity.responses,
      attending: entity.attending,
      gradientColors: entity.gradientColors,
    );
  }
}
