import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Enum for Golden Scenario event types with dynamic field configuration
enum GoldenEventType {
  birthday,
  wedding,
  aqiqah,
  storeOpening,
  custom,
}

/// Extension to provide event type metadata
extension GoldenEventTypeExtension on GoldenEventType {
  String get name {
    switch (this) {
      case GoldenEventType.birthday:
        return 'Birthday';
      case GoldenEventType.wedding:
        return 'Wedding';
      case GoldenEventType.aqiqah:
        return 'Aqiqah';
      case GoldenEventType.storeOpening:
        return 'Store Opening';
      case GoldenEventType.custom:
        return 'Custom Event';
    }
  }

  String get nameAr {
    switch (this) {
      case GoldenEventType.birthday:
        return 'عيد ميلاد';
      case GoldenEventType.wedding:
        return 'زفاف';
      case GoldenEventType.aqiqah:
        return 'عقيقة';
      case GoldenEventType.storeOpening:
        return 'افتتاح متجر';
      case GoldenEventType.custom:
        return 'مناسبة مخصصة';
    }
  }

  String get emoji {
    switch (this) {
      case GoldenEventType.birthday:
        return '🎂';
      case GoldenEventType.wedding:
        return '👰';
      case GoldenEventType.aqiqah:
        return '👶';
      case GoldenEventType.storeOpening:
        return '🏪';
      case GoldenEventType.custom:
        return '➕';
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case GoldenEventType.birthday:
        return const [Color(0xFFF59E0B), Color(0xFFEA580C)];
      case GoldenEventType.wedding:
        return const [Color(0xFFEC4899), Color(0xFFBE185D)];
      case GoldenEventType.aqiqah:
        return const [Color(0xFF22C55E), Color(0xFF16A34A)];
      case GoldenEventType.storeOpening:
        return const [Color(0xFF3B82F6), Color(0xFF1D4ED8)];
      case GoldenEventType.custom:
        return const [Color(0xFF9333EA), Color(0xFFDB2777)];
    }
  }

  /// Number of name fields required for this event type
  int get nameFieldCount {
    switch (this) {
      case GoldenEventType.birthday:
        return 1;
      case GoldenEventType.wedding:
        return 2;
      case GoldenEventType.aqiqah:
        return 2;
      case GoldenEventType.storeOpening:
        return 1;
      case GoldenEventType.custom:
        return 1;
    }
  }

  /// Labels for name fields
  List<String> get nameFieldLabels {
    switch (this) {
      case GoldenEventType.birthday:
        return ['Celebrant Name'];
      case GoldenEventType.wedding:
        return ['Bride Name', 'Groom Name'];
      case GoldenEventType.aqiqah:
        return ['Baby Name', 'Parent Name'];
      case GoldenEventType.storeOpening:
        return ['Store Name'];
      case GoldenEventType.custom:
        return ['Event Name'];
    }
  }

  /// Arabic labels for name fields
  List<String> get nameFieldLabelsAr {
    switch (this) {
      case GoldenEventType.birthday:
        return ['اسم المحتفل به'];
      case GoldenEventType.wedding:
        return ['اسم العروس', 'اسم العريس'];
      case GoldenEventType.aqiqah:
        return ['اسم المولود', 'اسم الوالد'];
      case GoldenEventType.storeOpening:
        return ['اسم المتجر'];
      case GoldenEventType.custom:
        return ['اسم المناسبة'];
    }
  }
}

/// Source of guest data for duplicate handling priority
enum GuestSource {
  contacts, // From mobile contacts
  excel, // From Excel file import
  manual, // Manually entered via form
}

/// Guest information model
class GuestInfoModel extends Equatable {
  final String name;
  final String phone;
  final String email;
  final GuestStatus status;
  final GuestSource source;

  const GuestInfoModel({
    required this.name,
    this.phone = '',
    this.email = '',
    this.status = GuestStatus.pending,
    this.source = GuestSource.manual,
  });

  bool get isValid => name.isNotEmpty;

  /// Validate phone number format (+972 or +970)
  bool get hasValidPhone {
    if (phone.isEmpty) return false;
    final normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return normalized.startsWith('+972') ||
        normalized.startsWith('+970') ||
        normalized.startsWith('972') ||
        normalized.startsWith('970');
  }

  /// Normalize phone number to +972/+970 format
  String get normalizedPhone {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }

  /// Create from JSON response
  factory GuestInfoModel.fromJson(Map<String, dynamic> json) {
    return GuestInfoModel(
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: GuestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GuestStatus.pending,
      ),
      source: GuestSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => GuestSource.manual,
      ),
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': normalizedPhone,
      if (email.isNotEmpty) 'email': email,
      'status': status.name,
      'source': source.name,
    };
  }

  GuestInfoModel copyWith({
    String? name,
    String? phone,
    String? email,
    GuestStatus? status,
    GuestSource? source,
  }) {
    return GuestInfoModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [name, phone, email, status, source];
}

enum GuestStatus {
  pending,
  confirmed,
  declined,
}

/// Template model for invitation templates
class InvitationTemplateModel extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String preview;
  final List<Color> gradientColors;

  const InvitationTemplateModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.preview,
    required this.gradientColors,
  });

  @override
  List<Object?> get props => [id, name, nameAr, preview, gradientColors];

  /// Predefined templates
  static List<InvitationTemplateModel> get templates => [
        const InvitationTemplateModel(
          id: 'elegant_gold',
          name: 'Elegant Gold',
          nameAr: 'ذهبي أنيق',
          preview: '✨',
          gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        const InvitationTemplateModel(
          id: 'modern_minimal',
          name: 'Modern Minimal',
          nameAr: 'عصري بسيط',
          preview: '◻️',
          gradientColors: [Color(0xFF6B7280), Color(0xFF4B5563)],
        ),
        const InvitationTemplateModel(
          id: 'floral_dream',
          name: 'Floral Dream',
          nameAr: 'حلم الزهور',
          preview: '🌸',
          gradientColors: [Color(0xFFF472B6), Color(0xFFEC4899)],
        ),
        const InvitationTemplateModel(
          id: 'classic_white',
          name: 'Classic White',
          nameAr: 'أبيض كلاسيكي',
          preview: '🤍',
          gradientColors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
        ),
        const InvitationTemplateModel(
          id: 'luxury_black',
          name: 'Luxury Black',
          nameAr: 'أسود فاخر',
          preview: '🖤',
          gradientColors: [Color(0xFF1F2937), Color(0xFF111827)],
        ),
        const InvitationTemplateModel(
          id: 'colorful_joy',
          name: 'Colorful Joy',
          nameAr: 'فرح ملون',
          preview: '🎨',
          gradientColors: [Color(0xFF9333EA), Color(0xFFDB2777)],
        ),
      ];
}

/// Complete invitation draft model
class InvitationDraftModel extends Equatable {
  final String? id;
  final GoldenEventType? eventType;
  final String? customEventTypeName;
  final List<String> names;
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final String? location;
  final String? locationAddress;
  final String? selectedTemplateId;
  final List<GuestInfoModel> guests;
  final String? selectedPackageId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvitationDraftModel({
    this.id,
    this.eventType,
    this.customEventTypeName,
    this.names = const [],
    this.eventDate,
    this.eventTime,
    this.location,
    this.locationAddress,
    this.selectedTemplateId,
    this.guests = const [],
    this.selectedPackageId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvitationDraftModel.empty() {
    final now = DateTime.now();
    return InvitationDraftModel(
      createdAt: now,
      updatedAt: now,
    );
  }

  InvitationDraftModel copyWith({
    String? id,
    GoldenEventType? eventType,
    String? customEventTypeName,
    List<String>? names,
    DateTime? eventDate,
    TimeOfDay? eventTime,
    String? location,
    String? locationAddress,
    String? selectedTemplateId,
    List<GuestInfoModel>? guests,
    String? selectedPackageId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvitationDraftModel(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      customEventTypeName: customEventTypeName ?? this.customEventTypeName,
      names: names ?? this.names,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      location: location ?? this.location,
      locationAddress: locationAddress ?? this.locationAddress,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      guests: guests ?? this.guests,
      selectedPackageId: selectedPackageId ?? this.selectedPackageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Get guest stats
  int get totalGuests => guests.length;
  int get confirmedGuests =>
      guests.where((g) => g.status == GuestStatus.confirmed).length;
  int get declinedGuests =>
      guests.where((g) => g.status == GuestStatus.declined).length;
  int get pendingGuests =>
      guests.where((g) => g.status == GuestStatus.pending).length;

  @override
  List<Object?> get props => [
        id,
        eventType,
        customEventTypeName,
        names,
        eventDate,
        eventTime,
        location,
        locationAddress,
        selectedTemplateId,
        guests,
        selectedPackageId,
        createdAt,
        updatedAt,
      ];
}
