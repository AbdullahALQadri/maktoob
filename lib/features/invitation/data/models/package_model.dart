import 'dart:convert';

import 'package:equatable/equatable.dart';


/// Package model from API
class PackageModel extends Equatable {
  final int id;
  final String name;
  final String nameAr;
  final double price;
  final int? invitationLimit; // null for unlimited or custom
  final bool isCustom;
  final int? minInvitations;
  final List<String> features;
  final List<String> featuresAr;
  final bool isHighlighted;

  /// False for the free trial when this phone already used it (backend
  /// `is_available`); such a package is shown but cannot be selected.
  final bool isAvailable;

  /// Price after the institution discount (backend `final_price`).
  final double? finalPrice;
  final double discountPercent;

  /// A private package assigned to this institution only.
  final bool isPrivate;

  /// Price of one invitation (backend `price_per_invitation`); null for free
  /// or unlimited packages. Bigger packages cost less per invitation.
  final double? pricePerInvitation;

  /// Saving vs the dearest per-invitation package (backend
  /// `volume_saving_percent`); 0 when none.
  final int volumeSavingPercent;

  const PackageModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    this.invitationLimit,
    this.isCustom = false,
    this.minInvitations,
    this.features = const [],
    this.featuresAr = const [],
    this.isHighlighted = false,
    this.isAvailable = true,
    this.finalPrice,
    this.discountPercent = 0,
    this.isPrivate = false,
    this.pricePerInvitation,
    this.volumeSavingPercent = 0,
  });

  /// What the client actually pays (discounted when applicable).
  double get effectivePrice => finalPrice ?? price;

  bool get hasDiscount => finalPrice != null && finalPrice! < price;

  bool get hasUnlimitedInvitations => invitationLimit == null || invitationLimit == -1;

  /// Free / freemium package: a non-custom package with no price.
  /// Such events skip invoicing and are activated immediately.
  bool get isFree => !isCustom && price <= 0;

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    // API returns name_en/name_ar, fallback to name for compatibility
    final nameEn = json['name_en'] as String? ?? json['name'] as String?;
    final nameAr = json['name_ar'] as String?;

    // Parse price from various formats (String or num)
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Parse features from JSON string or list
    List<String> features = [];
    List<String> featuresAr = [];
    final featuresRaw = json['features'];
    if (featuresRaw is String) {
      // Features is a JSON string like {"ar":["..."],"en":["..."]}
      try {
        final parsed = jsonDecode(featuresRaw) as Map<String, dynamic>;
        features = (parsed['en'] as List?)?.map((e) => e.toString()).toList() ?? [];
        featuresAr = (parsed['ar'] as List?)?.map((e) => e.toString()).toList() ?? [];
      } catch (_) {
        // Ignore parsing errors
      }
    } else if (featuresRaw is List) {
      features = featuresRaw.map((e) => e.toString()).toList();
    }
    // Override featuresAr if provided separately
    if (json['features_ar'] is List) {
      featuresAr = (json['features_ar'] as List).map((e) => e.toString()).toList();
    }

    return PackageModel(
      id: json['id'] as int? ?? 0,
      name: nameEn ?? nameAr ?? '',
      nameAr: nameAr ?? nameEn ?? '',
      price: parsePrice(json['price']),
      // API uses invitations_limit, code expects invitation_limit
      invitationLimit: json['invitations_limit'] as int? ?? json['invitation_limit'] as int?,
      isCustom: json['is_custom'] as bool? ?? false,
      minInvitations: json['min_invitations'] as int?,
      features: features,
      featuresAr: featuresAr,
      isHighlighted: json['is_highlighted'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      finalPrice: json['final_price'] == null ? null : parsePrice(json['final_price']),
      discountPercent: parsePrice(json['discount_percent']),
      isPrivate: json['is_private'] == true || json['is_private'] == 1,
      pricePerInvitation: json['price_per_invitation'] == null ? null : parsePrice(json['price_per_invitation']),
      volumeSavingPercent: parsePrice(json['volume_saving_percent']).round(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'price': price,
      if (invitationLimit != null) 'invitation_limit': invitationLimit,
      'is_custom': isCustom,
      if (minInvitations != null) 'min_invitations': minInvitations,
      'features': features,
      'features_ar': featuresAr,
      'is_highlighted': isHighlighted,
    };
  }

  PackageModel copyWith({
    int? id,
    String? name,
    String? nameAr,
    double? price,
    int? invitationLimit,
    bool? isCustom,
    int? minInvitations,
    List<String>? features,
    List<String>? featuresAr,
    bool? isHighlighted,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      price: price ?? this.price,
      invitationLimit: invitationLimit ?? this.invitationLimit,
      isCustom: isCustom ?? this.isCustom,
      minInvitations: minInvitations ?? this.minInvitations,
      features: features ?? this.features,
      featuresAr: featuresAr ?? this.featuresAr,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isAvailable: isAvailable,
      finalPrice: finalPrice,
      discountPercent: discountPercent,
      isPrivate: isPrivate,
      pricePerInvitation: pricePerInvitation,
      volumeSavingPercent: volumeSavingPercent,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        price,
        invitationLimit,
        isCustom,
        minInvitations,
        features,
        featuresAr,
        isHighlighted,
        pricePerInvitation,
        volumeSavingPercent,
      ];
}
