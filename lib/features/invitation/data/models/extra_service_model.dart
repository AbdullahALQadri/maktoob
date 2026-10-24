import 'package:equatable/equatable.dart';

/// One level of a service ("4 hours / full day"), priced for the whole event.
class ExtraServiceOptionModel extends Equatable {
  final int id;
  final String name;
  final String nameAr;
  final double price;
  final List<String> includes;
  final List<String> includesAr;

  const ExtraServiceOptionModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    this.includes = const [],
    this.includesAr = const [],
  });

  factory ExtraServiceOptionModel.fromJson(Map<String, dynamic> json) {
    final nameAr = json['name_ar']?.toString() ?? '';
    final nameEn = json['name_en']?.toString();
    final ar = ExtraServiceModel._lines(json['includes_ar']);
    final en = ExtraServiceModel._lines(json['includes_en']);
    return ExtraServiceOptionModel(
      id: int.tryParse('${json['id']}') ?? 0,
      name: (nameEn == null || nameEn.isEmpty) ? nameAr : nameEn,
      nameAr: nameAr,
      price: ExtraServiceModel._parsePrice(json['price']),
      includes: en.isNotEmpty ? en : ar,
      includesAr: ar,
    );
  }

  @override
  List<Object?> get props => [id, name, nameAr, price, includes, includesAr];
}

/// Model for extra paid services related to event types
class ExtraServiceModel extends Equatable {
  final int id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final double price;
  final String? iconUrl;
  final int? eventTypeId;

  /// "What the service includes", one item per entry (admin writes one per line).
  final List<String> includes;
  final List<String> includesAr;

  /// Days ahead the service must be booked (0 = any time).
  final int leadTimeDays;

  /// Levels to choose from (empty = one price). [price] is then the "from" price.
  final List<ExtraServiceOptionModel> options;

  /// The level the host picked (set on the copy kept in the selection).
  final int? selectedOptionId;

  const ExtraServiceModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    this.iconUrl,
    this.eventTypeId,
    this.includes = const [],
    this.includesAr = const [],
    this.leadTimeDays = 0,
    this.options = const [],
    this.selectedOptionId,
  });

  bool get hasLevels => options.length > 1;

  ExtraServiceOptionModel? get selectedOption {
    if (options.isEmpty) return null;
    for (final o in options) {
      if (o.id == selectedOptionId) return o;
    }
    // Same default as the server: the cheapest level.
    return options.reduce((a, b) => b.price < a.price ? b : a);
  }

  /// What this service adds to the bill: the picked level's price, else the price.
  double get effectivePrice => selectedOption?.price ?? price;

  /// Create from JSON response
  factory ExtraServiceModel.fromJson(Map<String, dynamic> json) {
    // API returns name_en/name_ar, fallback to name for compatibility
    final nameEn = json['name_en'] as String? ?? json['name'] as String?;
    final nameAr = json['name_ar'] as String?;

    return ExtraServiceModel(
      id: json['id'] as int,
      name: nameEn ?? nameAr ?? '',
      nameAr: nameAr ?? nameEn ?? '',
      description: json['description_en'] as String? ?? json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      price: _parsePrice(json['price'] ?? json['base_price']),
      // `icon` is a web icon-font class (e.g. "bx bx-camera"), not an image.
      iconUrl: _url(json['icon_url']) ?? _url(json['image_url']) ?? _url(json['icon']),
      eventTypeId: json['event_type_id'] as int?,
      includes: _lines(json['includes_en']).isNotEmpty
          ? _lines(json['includes_en'])
          : _lines(json['includes_ar']),
      includesAr: _lines(json['includes_ar']),
      leadTimeDays: int.tryParse('${json['lead_time_days'] ?? 0}') ?? 0,
      options: ((json['active_options'] ?? json['options']) as List? ?? const [])
          .whereType<Map>()
          .map((o) => ExtraServiceOptionModel.fromJson(Map<String, dynamic>.from(o)))
          .toList(),
    );
  }

  static String? _url(dynamic value) {
    final s = value?.toString() ?? '';
    return s.startsWith('http') ? s : null;
  }

  static List<String> _lines(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return (value?.toString() ?? '')
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Parse price from various formats (String or num)
  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      if (description != null) 'description': description,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      'price': price,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (eventTypeId != null) 'event_type_id': eventTypeId,
    };
  }

  ExtraServiceModel copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    String? iconUrl,
    int? eventTypeId,
    int? selectedOptionId,
  }) {
    return ExtraServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
      iconUrl: iconUrl ?? this.iconUrl,
      eventTypeId: eventTypeId ?? this.eventTypeId,
      includes: includes,
      includesAr: includesAr,
      leadTimeDays: leadTimeDays,
      options: options,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        description,
        descriptionAr,
        price,
        iconUrl,
        eventTypeId,
        includes,
        includesAr,
        leadTimeDays,
        options,
        selectedOptionId,
      ];
}
