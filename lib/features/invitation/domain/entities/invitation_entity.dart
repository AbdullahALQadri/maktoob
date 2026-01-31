import 'package:equatable/equatable.dart';

/// Represents an event type available for invitation creation.
class EventTypeEntity extends Equatable {
  final int id;
  final String name;
  final String? nameAr;
  final String? icon;
  final bool isCustom;

  const EventTypeEntity({
    required this.id,
    required this.name,
    this.nameAr,
    this.icon,
    this.isCustom = false,
  });

  @override
  List<Object?> get props => [id, name, nameAr, icon, isCustom];
}

/// Represents an invitation template.
class TemplateEntity extends Equatable {
  final int id;
  final String name;
  final String? previewUrl;
  final int eventTypeId;

  const TemplateEntity({
    required this.id,
    required this.name,
    this.previewUrl,
    required this.eventTypeId,
  });

  @override
  List<Object?> get props => [id, name, previewUrl, eventTypeId];
}

/// Represents a guest in the invitation.
enum GuestSource { contacts, excel, manual }
enum GuestStatus { pending, confirmed, declined }

class GuestEntity extends Equatable {
  final String? id;
  final String name;
  final String phone;
  final String? email;
  final GuestStatus status;
  final GuestSource source;

  const GuestEntity({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.status = GuestStatus.pending,
    this.source = GuestSource.manual,
  });

  @override
  List<Object?> get props => [id, name, phone, email, status, source];
}

/// Represents a selectable package for the invitation.
class PackageEntity extends Equatable {
  final int id;
  final String name;
  final String? nameAr;
  final double price;
  final int guestLimit;
  final List<String> features;

  const PackageEntity({
    required this.id,
    required this.name,
    this.nameAr,
    required this.price,
    required this.guestLimit,
    this.features = const [],
  });

  @override
  List<Object?> get props => [id, name, price, guestLimit];
}

/// Represents an extra service that can be added to the invitation.
class ExtraServiceEntity extends Equatable {
  final int id;
  final String name;
  final String? nameAr;
  final String? description;
  final double price;
  final bool isSelected;

  const ExtraServiceEntity({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    required this.price,
    this.isSelected = false,
  });

  ExtraServiceEntity copyWith({bool? isSelected}) => ExtraServiceEntity(
        id: id,
        name: name,
        nameAr: nameAr,
        description: description,
        price: price,
        isSelected: isSelected ?? this.isSelected,
      );

  @override
  List<Object?> get props => [id, name, price, isSelected];
}

/// Represents the invoice summary for an invitation.
class InvoiceEntity extends Equatable {
  final double packagePrice;
  final double servicesPrice;
  final double totalPrice;
  final String? packageName;
  final int guestCount;
  final List<InvoiceLineItem> lineItems;

  const InvoiceEntity({
    required this.packagePrice,
    required this.servicesPrice,
    required this.totalPrice,
    this.packageName,
    required this.guestCount,
    this.lineItems = const [],
  });

  @override
  List<Object?> get props => [packagePrice, servicesPrice, totalPrice, guestCount];
}

/// A single line item on the invoice.
class InvoiceLineItem extends Equatable {
  final String description;
  final double amount;

  const InvoiceLineItem({required this.description, required this.amount});

  @override
  List<Object?> get props => [description, amount];
}
