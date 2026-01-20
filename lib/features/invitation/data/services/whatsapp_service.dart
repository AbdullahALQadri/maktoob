import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for WhatsApp integration
class WhatsAppService {
  /// Open WhatsApp with pre-filled message
  Future<bool> openWhatsAppWithMessage({
    required String phoneNumber,
    required String message,
  }) async {
    // Clean phone number
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Try WhatsApp deep link first
    final whatsappUrl = Uri.parse(
        'whatsapp://send?phone=$cleanedPhone&text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(whatsappUrl)) {
      return await launchUrl(whatsappUrl,
          mode: LaunchMode.externalApplication);
    }

    // Fallback to wa.me URL
    final webUrl = Uri.parse(
        'https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(webUrl)) {
      return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }

    return false;
  }

  /// Share invoice image via system share sheet (which includes WhatsApp)
  Future<bool> shareInvoiceImage({
    required File invoiceImage,
    required String message,
  }) async {
    try {
      // Copy to shareable location if needed
      final tempDir = await getTemporaryDirectory();
      final shareFile = File(
          '${tempDir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.png');
      await invoiceImage.copy(shareFile.path);

      // Share via system share sheet
      final result = await Share.shareXFiles(
        [XFile(shareFile.path)],
        text: message,
        subject: 'Maktoob Invoice',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      return false;
    }
  }

  /// Open WhatsApp and then share invoice image
  Future<bool> openWhatsAppWithInvoice({
    required String phoneNumber,
    required File invoiceImage,
    required String message,
  }) async {
    // First open WhatsApp with message
    final opened = await openWhatsAppWithMessage(
      phoneNumber: phoneNumber,
      message: message,
    );

    if (opened) {
      // Small delay then share image
      await Future.delayed(const Duration(milliseconds: 500));
      await shareInvoiceImage(
        invoiceImage: invoiceImage,
        message: message,
      );
    }

    return opened;
  }

  /// Generate Arabic invoice message
  String generateInvoiceMessage({
    required String eventName,
    required String packageName,
    required double totalPrice,
    required int guestCount,
  }) {
    return '''
مرحباً! هذه فاتورة حجز دعوة من تطبيق مكتوب

المناسبة: $eventName
الباقة: $packageName
عدد الضيوف: $guestCount
المبلغ الإجمالي: $totalPrice شيكل

أرفقت صورة الفاتورة.
شكراً لكم!

---
Maktoob Events
''';
  }

  /// Generate English invoice message
  String generateInvoiceMessageEn({
    required String eventName,
    required String packageName,
    required double totalPrice,
    required int guestCount,
  }) {
    return '''
Hello! This is an invoice from Maktoob App

Event: $eventName
Package: $packageName
Number of Guests: $guestCount
Total Amount: $totalPrice ILS

Invoice image attached.
Thank you!

---
Maktoob Events
''';
  }

  /// Check if WhatsApp is installed
  Future<bool> isWhatsAppInstalled() async {
    final whatsappUrl = Uri.parse('whatsapp://send?phone=1234567890');
    return await canLaunchUrl(whatsappUrl);
  }

  /// Get WhatsApp URL for a phone number with message
  String getWhatsAppUrl(String phoneNumber, String message) {
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return 'https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}';
  }
}

/// Exception thrown when WhatsApp is not installed
class WhatsAppNotInstalledException implements Exception {
  final String message;
  WhatsAppNotInstalledException(
      [this.message = 'WhatsApp is not installed on this device']);

  @override
  String toString() => message;
}
