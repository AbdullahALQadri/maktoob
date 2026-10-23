import '../../domain/entities/event_add_ons_entity.dart';

double _num(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

String? _str(dynamic v) => v == null || '$v'.isEmpty ? null : '$v';

class EventAddOnsModel extends EventAddOnsEntity {
  const EventAddOnsModel({
    required super.canRequest,
    required super.services,
    required super.available,
    required super.amountDue,
    required super.paymentUnderReview,
  });

  /// Accepts the ApiResponse envelope `{success, message, data}` or `data`.
  factory EventAddOnsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json;
    final due = data['payment_due'] is Map ? data['payment_due'] as Map : const {};

    return EventAddOnsModel(
      canRequest: data['can_request'] == true,
      services: (data['services'] as List? ?? const [])
          .whereType<Map>()
          .map((s) => EventAddOnEntity(
                serviceId: _int(s['extra_service_id'] ?? s['id']),
                nameAr: '${s['name_ar'] ?? ''}',
                nameEn: _str(s['name_en']),
                quantity: _int(s['quantity'] ?? 1),
                totalPrice: _num(s['total_price']),
                status: AddOnStatus.fromApi(s['status']?.toString()),
                decisionNote: _str(s['decision_note']),
                canWithdraw: s['can_withdraw'] == true,
              ))
          .toList(),
      available: (data['available_services'] as List? ?? const [])
          .whereType<Map>()
          .map((s) => OfferedServiceEntity(
                id: _int(s['id']),
                nameAr: '${s['name_ar'] ?? s['name'] ?? ''}',
                nameEn: _str(s['name_en']),
                descriptionAr: _str(s['description_ar']),
                descriptionEn: _str(s['description_en']),
                price: _num(s['base_price'] ?? s['price']),
              ))
          .toList(),
      amountDue: _num(due['total']),
      paymentUnderReview: data['pending_payment_request'] is Map,
    );
  }
}
