import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/venues/data/models/venue_model.dart';

Map<String, dynamic> _json(dynamic icon) => {
      'id': '1',
      'name': 'قاعة الأندلس',
      'address': 'غزة',
      'phone': '0599000000',
      'email': 'a@b.c',
      'capacity': 300,
      'icon': icon,
    };

void main() {
  // A release build tree-shakes the icon font: the icon must come back as a
  // constant, never IconData(codePoint) built at runtime.
  test('a stored icon round-trips to the same constant', () {
    final venue = VenueModel.fromJson(_json(Icons.location_on.codePoint));
    expect(venue.icon, Icons.location_on);
    expect(VenueModel.fromJson(venue.toJson()).icon, Icons.location_on);
  });

  test('an unknown or missing icon falls back to business', () {
    expect(VenueModel.fromJson(_json(1)).icon, Icons.business);
    expect(VenueModel.fromJson(_json(null)).icon, Icons.business);
  });
}
