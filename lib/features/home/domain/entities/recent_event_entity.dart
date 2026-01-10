import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RecentEventEntity extends Equatable {
  final int id;
  final String name;
  final String date;
  final String venue;
  final int invitations;
  final int responses;
  final int attending;
  final List<Color> gradientColors;

  const RecentEventEntity({
    required this.id,
    required this.name,
    required this.date,
    required this.venue,
    required this.invitations,
    required this.responses,
    required this.attending,
    required this.gradientColors,
  });

  double get responseRate => invitations > 0 ? responses / invitations : 0;
  double get attendingRate => invitations > 0 ? attending / invitations : 0;

  @override
  List<Object?> get props => [
        id,
        name,
        date,
        venue,
        invitations,
        responses,
        attending,
        gradientColors,
      ];
}
