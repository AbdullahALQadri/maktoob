import 'package:flutter/material.dart';

class PackageModel {
  final String id;
  final String name;
  final String price;
  final int invitations; // -1 for unlimited
  final List<String> features;
  final List<Color> gradientColors;
  final IconData icon;
  final bool recommended;

  const PackageModel({
    required this.id,
    required this.name,
    required this.price,
    required this.invitations,
    required this.features,
    required this.gradientColors,
    required this.icon,
    this.recommended = false,
  });

  bool get isUnlimited => invitations == -1;
  String get invitationsDisplay => isUnlimited ? 'Unlimited' : invitations.toString();
}

class VenueModel {
  final String id;
  final String name;
  final int capacity;
  final String icon;

  const VenueModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.icon,
  });
}

class CustomVenue {
  String name;
  String address;
  String capacity;

  CustomVenue({
    this.name = '',
    this.address = '',
    this.capacity = '',
  });

  bool get isValid => name.isNotEmpty && address.isNotEmpty;
}

class EventTypeModel {
  final String id;
  final String name;
  final String icon;
  final List<Color> gradientColors;

  const EventTypeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.gradientColors,
  });
}

class TemplateModel {
  final String id;
  final String name;
  final String preview;
  final List<Color> gradientColors;

  const TemplateModel({
    required this.id,
    required this.name,
    required this.preview,
    required this.gradientColors,
  });
}

class EventDetails {
  String name;
  DateTime? date;
  TimeOfDay? time;
  DateTime? responseDeadline;
  int maxCompanions;
  bool allowCompanions;

  EventDetails({
    this.name = '',
    this.date,
    this.time,
    this.responseDeadline,
    this.maxCompanions = 2,
    this.allowCompanions = true,
  });

  bool get isValid => name.isNotEmpty && date != null && time != null;
}

class GuestInfo {
  String name;
  String email;
  String phone;

  GuestInfo({
    this.name = '',
    this.email = '',
    this.phone = '',
  });

  bool get isValid => name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty;

  GuestInfo copy() => GuestInfo(name: name, email: email, phone: phone);
}

enum GuestMethod { invite, excel, manual }
