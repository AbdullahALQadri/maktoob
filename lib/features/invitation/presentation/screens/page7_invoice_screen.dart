import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/wizard_step_header.dart';

class Page7InvoiceScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const Page7InvoiceScreen({super.key, this.onComplete});

  @override
  State<Page7InvoiceScreen> createState() => _Page7InvoiceScreenState();
}

class _Page7InvoiceScreenState extends State<Page7InvoiceScreen> {
  final GlobalKey _invoiceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Load invoice when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationCubit>().loadInvoice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvitationCubit, InvitationState>(
      listener: (context, state) {
        // Handle save success
        if (state.saveSuccess) {
          if (state.isSaveAsDraft) {
            // For draft saves, navigate directly to home
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('تم الحفظ كمسودة بنجاح'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Navigate to home
            if (widget.onComplete != null) {
              widget.onComplete!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } else {
            // For full save, show success dialog
            _showSuccessDialog(context, state.isSaveAsDraft);
          }
        }

        // Handle save error
        if (state.saveError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.saveError!)),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Step Header
                const WizardStepHeader(
                  currentStep: 7,
                  totalSteps: 7,
                  title: 'الفاتورة والحفظ',
                ),

                // Content
                Expanded(
                  child: _buildContent(context, state),
                ),

                // Action Buttons
                _buildActionButtons(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, InvitationState state) {
    if (state.isLoadingInvoice) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'جاري تحميل الفاتورة...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (state.invoiceError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ أثناء تحميل الفاتورة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.invoiceError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'إعادة المحاولة',
                onPressed: () {
                  context.read<InvitationCubit>().loadInvoice();
                },
                width: 200,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RepaintBoundary(
        key: _invoiceKey,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Invoice Header
              _buildInvoiceHeader(state),

              // Event Details
              _buildEventDetails(state),

              // Invoice Items
              _buildInvoiceItems(state),

              // Total
              _buildTotal(state),

              // Footer
              _buildInvoiceFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Capture the invoice widget as PNG bytes
  Future<Uint8List?> _captureInvoice() async {
    try {
      final boundary = _invoiceKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing invoice: $e');
      return null;
    }
  }

  Widget _buildInvoiceHeader(InvitationState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Logo or App Name
          const Icon(
            Icons.receipt_long,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'فاتورة الحدث',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'رقم الفاتورة: ${state.invoiceSummary?.invoiceNumber ?? 'جديد'}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          Text(
            'التاريخ: ${_formatDate(DateTime.now())}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(InvitationState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الحدث',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            'اسم الحدث',
            state.eventName ?? '-',
            Icons.celebration,
          ),
          _buildDetailItem(
            'نوع الحدث',
            state.selectedEventType?.nameAr ??
                state.customEventTypeName ??
                '-',
            Icons.category,
          ),
          _buildDetailItem(
            'القالب',
            state.uploadedTemplateFile != null
                ? 'قالب مخصص'
                : state.selectedTemplate?.nameAr ?? '-',
            Icons.photo_library,
          ),
          if (state.eventDate != null)
            _buildDetailItem(
              'تاريخ الحدث',
              _formatDate(state.eventDate!),
              Icons.calendar_today,
            ),
          if (state.selectedVenue != null || state.customLocation != null)
            _buildDetailItem(
              'الموقع',
              state.selectedVenue?.nameAr ??
                  state.customLocation?.address ??
                  '-',
              Icons.location_on,
            ),
          _buildDetailItem(
            'عدد المدعوين',
            '${state.allGuests.length} مدعو',
            Icons.people,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItems(InvitationState state) {
    final invoice = state.invoiceSummary;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الفاتورة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'البند',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'السعر',
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Package
          _buildInvoiceRow(
            'الباقة: ${state.selectedPackage?.nameAr ?? '-'}',
            state.selectedPackage?.isCustom == true &&
                    state.customPackagePrice != null
                ? state.customPackagePrice!
                : state.selectedPackage?.price ?? 0,
          ),

          // Custom Template Fee
          if (state.uploadedTemplateFile != null)
            _buildInvoiceRow(
              'رسوم القالب المخصص',
              invoice?.templateFee ?? 50,
            ),

          // Extra Services
          if (state.selectedServices.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'الخدمات الإضافية:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            ...state.selectedServices.map(
              (service) => _buildInvoiceRow(
                '  • ${service.nameAr}',
                service.price,
                indent: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, double price, {bool indent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: indent ? Colors.grey.shade600 : Colors.grey.shade800,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${price.toStringAsFixed(0)} ₪',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 13,
                fontWeight: indent ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(InvitationState state) {
    final invoice = state.invoiceSummary;
    double total = 0;

    // Calculate total
    // Package price
    if (state.selectedPackage?.isCustom == true &&
        state.customPackagePrice != null) {
      total += state.customPackagePrice!;
    } else {
      total += state.selectedPackage?.price ?? 0;
    }

    // Custom template fee
    if (state.uploadedTemplateFile != null) {
      total += invoice?.templateFee ?? 50;
    }

    // Extra services
    for (var service in state.selectedServices) {
      total += service.price;
    }

    // Use invoice total if available (from API)
    total = invoice?.totalPrice ?? total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'الإجمالي',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${total.toStringAsFixed(0)} ₪',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Text(
            'شكراً لاستخدامكم تطبيق مكتوب',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'للدعم الفني: support@maktoob.app',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, InvitationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // WhatsApp notice
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سيتم إرسال الفاتورة عبر واتساب أو داخل التطبيق',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              // Back Button
              Expanded(
                child: AppButton(
                  text: 'السابق',
                  onPressed: state.isSaving
                      ? null
                      : () {
                          context.read<InvitationCubit>().previousStep();
                        },
                  backgroundColor: Colors.grey.shade200,
                  textColor: Colors.black87,
                ),
              ),

              const SizedBox(width: 12),

              // Save as Draft Button
              Expanded(
                child: AppButton(
                  text: 'حفظ كمسودة',
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          await context.read<InvitationCubit>().saveDraft();
                        },
                  backgroundColor: Colors.orange.shade100,
                  textColor: Colors.orange.shade800,
                  isLoading: state.isSaving && state.isSaveAsDraft,
                ),
              ),

              const SizedBox(width: 12),

              // Save & Send Button
              Expanded(
                flex: 2,
                child: AppButton(
                  text: 'حفظ وإرسال',
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          // Capture invoice screenshot first
                          final image = await _captureInvoice();
                          if (mounted && image != null) {
                            await context
                                .read<InvitationCubit>()
                                .saveAndSend(invoiceImage: image);
                          }
                        },
                  isLoading: state.isSaving && !state.isSaveAsDraft,
                  icon: Icons.send,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, bool isDraft) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isDraft ? 'تم الحفظ كمسودة' : 'تم الحفظ بنجاح!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDraft
                  ? 'يمكنك متابعة إنشاء الحدث لاحقاً'
                  : 'تم إرسال الفاتورة عبر واتساب',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            text: 'العودة للرئيسية',
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
              // Call onComplete callback if provided, otherwise pop wizard
              if (widget.onComplete != null) {
                widget.onComplete!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(); // Close wizard
              }
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
