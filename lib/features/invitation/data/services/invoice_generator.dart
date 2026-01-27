import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/utils/app_colors.dart';
import '../models/invoice_model.dart';

/// Service for generating invoice images using Flutter's built-in rendering
class InvoiceGenerator {
  /// Generate an invoice image from invoice data
  /// Returns a File containing the PNG image
  Future<File> generateInvoiceImage({
    required InvoiceSummaryModel invoice,
    required String eventName,
    required String packageName,
    required int guestCount,
    String? eventType,
  }) async {
    // Create the widget to render
    final widget = MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: InvoiceWidget(
            invoice: invoice,
            eventName: eventName,
            packageName: packageName,
            guestCount: guestCount,
            eventType: eventType,
          ),
        ),
      ),
    );

    // Render the widget to an image using the picture recorder approach
    final bytes = await _captureWidget(widget);

    // Save to file
    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/maktoob_invoice_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);

    return file;
  }

  /// Capture a widget as PNG bytes using dart:ui
  Future<List<int>> _captureWidget(Widget widget) async {
    final repaintBoundary = RenderRepaintBoundary();

    final renderView = RenderView(
      view: ui.PlatformDispatcher.instance.implicitView!,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        devicePixelRatio: 2.0,
      ),
    );

    final pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: widget,
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}

/// Widget for invoice rendering - made public for use in screens
class InvoiceWidget extends StatelessWidget {
  final InvoiceSummaryModel invoice;
  final String eventName;
  final String packageName;
  final int guestCount;
  final String? eventType;

  const InvoiceWidget({
    super.key,
    required this.invoice,
    required this.eventName,
    required this.packageName,
    required this.guestCount,
    this.eventType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 20),
          const Divider(thickness: 1),
          const SizedBox(height: 16),

          // Invoice Details
          _buildInvoiceDetails(),
          const SizedBox(height: 20),

          // Line Items
          if (invoice.lineItems.isNotEmpty) ...[
            _buildLineItems(),
            const SizedBox(height: 16),
          ],

          // Summary
          const Divider(thickness: 1),
          const SizedBox(height: 12),
          _buildSummary(),
          const SizedBox(height: 20),

          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo/App Name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.tertiaryColor],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Maktoob',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'فاتورة / Invoice',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        if (invoice.invoiceNumber != null) ...[
          const SizedBox(height: 4),
          Text(
            '#${invoice.invoiceNumber}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInvoiceDetails() {
    return Column(
      children: [
        _buildDetailRow('المناسبة / Event', eventName),
        if (eventType != null) _buildDetailRow('النوع / Type', eventType!),
        _buildDetailRow('الباقة / Package', packageName),
        _buildDetailRow('عدد الضيوف / Guests', guestCount.toString()),
        _buildDetailRow(
          'التاريخ / Date',
          _formatDate(invoice.createdAt ?? DateTime.now()),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التفاصيل / Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 8),
        ...invoice.lineItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.descriptionAr,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
                  Text(
                    '${item.total.toStringAsFixed(2)} ILS',
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        if (invoice.servicesTotal > 0)
          _buildSummaryRow(
              'خدمات إضافية / Services', invoice.servicesTotal, false),
        if (invoice.templateFee > 0)
          _buildSummaryRow(
              'رسوم القالب / Template Fee', invoice.templateFee, false),
        if (invoice.discount > 0)
          _buildSummaryRow('خصم / Discount', -invoice.discount, false),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المجموع / Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${invoice.totalPrice.toStringAsFixed(2)} ILS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, bool isTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: AppColors.gray600,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} ILS',
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'شكراً لاختياركم مكتوب',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Thank you for choosing Maktoob',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gray500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Generated: ${_formatDateTime(DateTime.now())}',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.gray400,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
