import '../../../../core/utils/venue_text.dart';
import '../../domain/entities/wizard_results.dart';
import '../models/event_type_model.dart';
import '../models/invitation_draft_model.dart';
import '../models/invoice_model.dart';

/// A number the API may send as a number or as text.
double parseNum(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int? parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// A blank value from the API (an unset setting) is "nothing", not "".
String? nonBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

/// The design chosen for an event, from the wizard's `event` payload.
String? designUrlOf(dynamic event) {
  final image = event is Map ? event['final_ai_image'] : null;
  return nonBlank(image is Map ? image['image_url'] : null);
}

/// `GET {id}/state` → the draft. Null when the answer holds no event.
WizardDraft? parseDraft(dynamic response, int fallbackId) {
  final data = response is Map ? response['data'] : null;
  final event = data is Map ? data['event'] : null;
  if (event is! Map) return null;

  final type = event['event_type'];
  // PHP serialises an empty array as `[]`.
  final values = event['event_type_form_values'];
  final drafts = event['draft_guests'];
  final companions = parseInt(event['partner_count'] ?? event['max_companions']);

  return WizardDraft(
    id: parseInt(event['id']) ?? fallbackId,
    // `title` / `description` are the unified columns (title_ar is legacy).
    title: (event['title'] ?? event['title_ar'])?.toString(),
    description: event['description']?.toString(),
    date: DateTime.tryParse('${event['event_date'] ?? ''}'),
    endDate: DateTime.tryParse('${event['end_date'] ?? ''}'),
    typeId: parseInt(event['event_type_id']),
    type: type is Map ? EventTypeModel.fromJson(Map<String, dynamic>.from(type)) : null,
    formValues: values is Map ? values.map((k, v) => MapEntry('$k', v)) : const {},
    latitude: double.tryParse('${event['custom_venue_lat'] ?? ''}'),
    longitude: double.tryParse('${event['custom_venue_lng'] ?? ''}'),
    place: VenueText.line(
      event['custom_venue_name_ar']?.toString(),
      event['custom_venue_address_ar']?.toString(),
    ),
    companions: companions != null && companions > 0 ? companions : null,
    replyDeadline: DateTime.tryParse('${event['response_deadline'] ?? ''}'),
    message: nonBlank(event['message_ar']),
    guests: [
      if (drafts is List)
        for (final g in drafts.whereType<Map>())
          if (g['is_duplicate'] != true && g['is_duplicate'] != 1)
            GuestInfoModel(name: '${g['guest_name'] ?? ''}', phone: '${g['phone'] ?? ''}'),
    ],
    designUrl: designUrlOf(event),
    deliveryMethod: event['default_delivery_method'] == 'email' ? 'email' : 'whatsapp',
    requireResponse: event['require_response'] != false && event['require_response'] != 0,
  );
}

/// `GET {id}/invoice` → the invoice the review shows.
WizardInvoice parseInvoice(dynamic response) {
  final data = response is Map && response['data'] is Map ? response['data'] as Map : const {};
  final event = data['event'];
  final items = [
    for (final item in (data['items'] as List? ?? const []).whereType<Map>())
      InvoiceLineItem(
        description: '${item['name_en'] ?? item['name_ar'] ?? ''}',
        descriptionAr: '${item['name_ar'] ?? ''}',
        amount: parseNum(item['price']),
      ),
  ];
  return WizardInvoice(
    summary: InvoiceSummaryModel(
      invoiceNumber: data['invoice_number']?.toString() ?? 'INV-${DateTime.now().millisecondsSinceEpoch}',
      basePrice: parseNum(data['subtotal']),
      servicesTotal: 0,
      templateFee: 0,
      totalPrice: parseNum(data['total']),
      taxRate: parseNum(data['tax_rate']),
      taxAmount: parseNum(data['tax_amount']),
      lineItems: items,
      createdAt: DateTime.now(),
      eventName: event is Map ? event['title']?.toString() : null,
      guestCount: parseInt(data['guest_count']),
    ),
    // Never a made-up number: without one, WhatsApp sharing is unavailable.
    whatsappNumber: nonBlank(data['whatsapp_number']),
  );
}
