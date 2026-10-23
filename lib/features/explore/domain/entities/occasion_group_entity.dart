import 'package:equatable/equatable.dart';

/// A platform event type (زفاف، خطوبة، ...) shown while browsing.
class OccasionTypeEntity extends Equatable {
  final int id;
  final String slug;
  final String nameAr;
  final String nameEn;

  const OccasionTypeEntity({
    required this.id,
    required this.slug,
    required this.nameAr,
    required this.nameEn,
  });

  String localizedName(String languageCode) =>
      languageCode == 'ar' || nameEn.isEmpty ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, slug, nameAr, nameEn];
}

/// An occasion group (أفراح، مواليد، ...) with its event types.
class OccasionGroupEntity extends Equatable {
  final int id;
  final String slug;
  final String nameAr;
  final String nameEn;
  final List<OccasionTypeEntity> types;

  const OccasionGroupEntity({
    required this.id,
    required this.slug,
    required this.nameAr,
    required this.nameEn,
    required this.types,
  });

  String localizedName(String languageCode) =>
      languageCode == 'ar' || nameEn.isEmpty ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, slug, nameAr, nameEn, types];
}
