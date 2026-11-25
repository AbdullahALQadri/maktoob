import 'package:equatable/equatable.dart';

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
      name: json['name'] as String? ?? '',
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
