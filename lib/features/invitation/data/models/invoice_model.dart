import 'package:equatable/equatable.dart';

/// Model for individual invoice line items
class InvoiceLineItem extends Equatable {
  final String description;
  final String descriptionAr;
  final double amount;
  final int quantity;

  const InvoiceLineItem({
    required this.description,
    required this.descriptionAr,
    required this.amount,
    this.quantity = 1,
  });

  double get total => amount * quantity;

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      description: json['description'] as String,
      descriptionAr: json['description_ar'] as String? ?? json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'description_ar': descriptionAr,
      'amount': amount,
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => [description, descriptionAr, amount, quantity];
}

/// Model for invoice summary
class InvoiceSummaryModel extends Equatable {
  final String? invoiceNumber;
  final double basePrice;
  final double servicesTotal;
  final double templateFee;
  final double discount;
  final double totalPrice;
  final List<InvoiceLineItem> lineItems;
  final DateTime? createdAt;
  final String? eventName;
  final String? packageName;
  final int? guestCount;

  const InvoiceSummaryModel({
    this.invoiceNumber,
    required this.basePrice,
    required this.servicesTotal,
    this.templateFee = 0,
    this.discount = 0,
    required this.totalPrice,
    required this.lineItems,
    this.createdAt,
    this.eventName,
    this.packageName,
    this.guestCount,
  });

  /// Calculate subtotal before discount
  double get subtotal => basePrice + servicesTotal + templateFee;

  /// Create empty invoice
  factory InvoiceSummaryModel.empty() {
    return const InvoiceSummaryModel(
      basePrice: 0,
      servicesTotal: 0,
      templateFee: 0,
      discount: 0,
      totalPrice: 0,
      lineItems: [],
    );
  }

  /// Create from JSON response
  factory InvoiceSummaryModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSummaryModel(
      invoiceNumber: json['invoice_number'] as String?,
      basePrice: (json['base_price'] as num).toDouble(),
      servicesTotal: (json['services_total'] as num).toDouble(),
      templateFee: (json['template_fee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['total_price'] as num).toDouble(),
      lineItems: (json['line_items'] as List<dynamic>?)
              ?.map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      eventName: json['event_name'] as String?,
      packageName: json['package_name'] as String?,
      guestCount: json['guest_count'] as int?,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      'base_price': basePrice,
      'services_total': servicesTotal,
      'template_fee': templateFee,
      'discount': discount,
      'total_price': totalPrice,
      'line_items': lineItems.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (eventName != null) 'event_name': eventName,
      if (packageName != null) 'package_name': packageName,
      if (guestCount != null) 'guest_count': guestCount,
    };
  }

  InvoiceSummaryModel copyWith({
    String? invoiceNumber,
    double? basePrice,
    double? servicesTotal,
    double? templateFee,
    double? discount,
    double? totalPrice,
    List<InvoiceLineItem>? lineItems,
    DateTime? createdAt,
    String? eventName,
    String? packageName,
    int? guestCount,
  }) {
    return InvoiceSummaryModel(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      basePrice: basePrice ?? this.basePrice,
      servicesTotal: servicesTotal ?? this.servicesTotal,
      templateFee: templateFee ?? this.templateFee,
      discount: discount ?? this.discount,
      totalPrice: totalPrice ?? this.totalPrice,
      lineItems: lineItems ?? this.lineItems,
      createdAt: createdAt ?? this.createdAt,
      eventName: eventName ?? this.eventName,
      packageName: packageName ?? this.packageName,
      guestCount: guestCount ?? this.guestCount,
    );
  }

  @override
  List<Object?> get props => [
        invoiceNumber,
        basePrice,
        servicesTotal,
        templateFee,
        discount,
        totalPrice,
        lineItems,
        createdAt,
        eventName,
        packageName,
        guestCount,
      ];
}
