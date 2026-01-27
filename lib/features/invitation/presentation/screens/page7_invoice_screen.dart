import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
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
    final l = AppLocalizations.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return BlocConsumer<InvitationCubit, InvitationState>(
      listener: (context, state) {
        // Handle save success
        if (state.saveSuccess) {
          if (state.isSaveAsDraft) {
            // For draft saves, navigate directly to home
            AppSnackBar.showSuccess(
              context,
              message: l?.translate('invitation_draft_saved_success') ?? 'Draft saved successfully',
              duration: const Duration(seconds: 2),
            );
            // Navigate to home
            if (widget.onComplete != null) {
              widget.onComplete!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } else {
            // For full save, show success dialog
            _showSuccessDialog(context, state.isSaveAsDraft, l);
          }
        }

        // Handle save error
        if (state.saveError != null) {
          AppSnackBar.showError(
            context,
            message: state.saveError!,
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
                WizardStepHeader(
                  currentStep: 7,
                  totalSteps: 7,
                  title: l?.translate('invitation_step7_title') ?? 'Invoice & Save',
                ),

                // Content
                Expanded(
                  child: _buildContent(context, state, l, isEnglish),
                ),

                // Action Buttons
                _buildActionButtons(context, state, l),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, InvitationState state, AppLocalizations? l, bool isEnglish) {
    if (state.isLoadingInvoice) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              l?.translate('invitation_loading_invoice') ?? 'Loading invoice...',
              style: TextStyle(
                fontSize: 15.sp,
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
          padding: EdgeInsets.all(23.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60.w,
                color: Colors.red.shade300,
              ),
              SizedBox(height: 16.h),
              Text(
                l?.translate('invitation_invoice_error') ?? 'Error loading invoice',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                state.invoiceError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 24.h),
              AppButton(
                text: l?.translate('common_retry') ?? 'Retry',
                onPressed: () {
                  context.read<InvitationCubit>().loadInvoice();
                },
                width: 188.w,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(15.w),
      child: RepaintBoundary(
        key: _invoiceKey,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 19.w,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Invoice Header
              _buildInvoiceHeader(context, state, l),

              // Event Details
              _buildEventDetails(context, state, l, isEnglish),

              // Invoice Items
              _buildInvoiceItems(context, state, l, isEnglish),

              // Total
              _buildTotal(context, state, l),

              // Footer
              _buildInvoiceFooter(context, l),
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

  /// Save invoice image to temp file and share via WhatsApp
  Future<void> _saveAndShareInvoice(
    BuildContext context,
    Uint8List imageBytes,
    InvitationState state,
    AppLocalizations? l,
  ) async {
    final cubit = context.read<InvitationCubit>();

    try {
      // Get temp directory and save image
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/invoice_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      if (!mounted) return;

      // Save the invitation first
      await cubit.saveAndSend(invoiceImage: imageBytes);

      if (!mounted) return;

      // Share the invoice image via WhatsApp
      final eventName = state.eventName ?? 'Event';
      final shareText = l?.translate('invitation_share_invoice_text') ??
          'Invoice for $eventName - Maktoob App';

      await Share.shareXFiles(
        [XFile(filePath)],
        text: shareText,
      );
    } catch (e) {
      debugPrint('Error sharing invoice: $e');
      if (!mounted) return;

      AppSnackBar.showError(
        context,
        message: l?.translate('invitation_share_error') ??
            'Error sharing invoice. Please try again.',
      );
    }
  }

  Widget _buildInvoiceHeader(BuildContext context, InvitationState state, AppLocalizations? l) {
    return Container(
      padding: EdgeInsets.all(23.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.w),
          topRight: Radius.circular(15.w),
        ),
      ),
      child: Column(
        children: [
          // Logo or App Name
          Icon(
            Icons.receipt_long,
            color: Colors.white,
            size: 45.w,
          ),
          SizedBox(height: 12.h),
          Text(
            l?.translate('invitation_event_invoice') ?? 'Event Invoice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${l?.translate('invitation_invoice_number') ?? 'Invoice number'}: ${state.invoiceSummary?.invoiceNumber ?? (l?.translate('invitation_new') ?? 'New')}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13.sp,
            ),
          ),
          Text(
            '${l?.translate('invitation_date') ?? 'Date'}: ${_formatDate(DateTime.now())}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(BuildContext context, InvitationState state, AppLocalizations? l, bool isEnglish) {
    return Container(
      padding: EdgeInsets.all(19.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l?.translate('invitation_event_details') ?? 'Event Details',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailItem(
            context,
            l?.translate('invitation_event_name_label') ?? 'Event Name',
            state.eventName ?? '-',
            Icons.celebration,
          ),
          _buildDetailItem(
            context,
            l?.translate('invitation_event_type_label') ?? 'Event Type',
            isEnglish
                ? (state.selectedEventType?.name ?? state.customEventTypeName ?? '-')
                : (state.selectedEventType?.nameAr ?? state.customEventTypeName ?? '-'),
            Icons.category,
          ),
          _buildDetailItem(
            context,
            l?.translate('invitation_template') ?? 'Template',
            state.uploadedTemplateFile != null
                ? (l?.translate('invitation_custom_template') ?? 'Custom Template')
                : (isEnglish ? (state.selectedTemplate?.name ?? '-') : (state.selectedTemplate?.nameAr ?? '-')),
            Icons.photo_library,
          ),
          if (state.eventDate != null)
            _buildDetailItem(
              context,
              l?.translate('invitation_event_date') ?? 'Event Date',
              _formatDate(state.eventDate!),
              Icons.calendar_today,
            ),
          if (state.selectedVenue != null || state.customLocation != null)
            _buildDetailItem(
              context,
              l?.translate('invitation_location_label') ?? 'Location',
              isEnglish
                  ? (state.selectedVenue?.name ?? state.customLocation?.address ?? '-')
                  : (state.selectedVenue?.nameAr ?? state.customLocation?.address ?? '-'),
              Icons.location_on,
            ),
          _buildDetailItem(
            context,
            l?.translate('invitation_guest_count') ?? 'Guest Count',
            '${state.allGuests.length} ${l?.translate('invitation_guests') ?? 'guests'}',
            Icons.people,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17.w,
            color: Colors.grey.shade500,
          ),
          SizedBox(width: 9.w),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItems(BuildContext context, InvitationState state, AppLocalizations? l, bool isEnglish) {
    final invoice = state.invoiceSummary;

    return Container(
      padding: EdgeInsets.all(19.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l?.translate('invitation_invoice_details') ?? 'Invoice Details',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),

          // Table Header
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 15.w,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.w),
                topRight: Radius.circular(8.w),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    l?.translate('invitation_item') ?? 'Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l?.translate('invitation_price') ?? 'Price',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Package
          _buildInvoiceRow(
            context,
            '${l?.translate('invitation_package') ?? 'Package'}: ${isEnglish ? (state.selectedPackage?.name ?? '-') : (state.selectedPackage?.nameAr ?? '-')}',
            state.selectedPackage?.isCustom == true &&
                    state.customPackagePrice != null
                ? state.customPackagePrice!
                : state.selectedPackage?.price ?? 0,
          ),

          // Custom Template Fee
          if (state.uploadedTemplateFile != null)
            _buildInvoiceRow(
              context,
              l?.translate('invitation_custom_template_fee') ?? 'Custom Template Fee',
              invoice?.templateFee ?? 50,
            ),

          // Extra Services
          if (state.selectedServices.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 8.h,
                horizontal: 15.w,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${l?.translate('invitation_extra_services') ?? 'Extra Services'}:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            ...state.selectedServices.map(
              (service) => _buildInvoiceRow(
                context,
                '  • ${isEnglish ? service.name : service.nameAr}',
                service.price,
                indent: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(BuildContext context, String label, double price, {bool indent = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12.h,
        horizontal: 15.w,
      ),
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
                fontSize: 12.sp,
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
                fontSize: 12.sp,
                fontWeight: indent ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(BuildContext context, InvitationState state, AppLocalizations? l) {
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
      padding: EdgeInsets.all(19.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l?.translate('invitation_total') ?? 'Total',
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 23.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(11.w),
            ),
            child: Text(
              '${total.toStringAsFixed(0)} ₪',
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceFooter(BuildContext context, AppLocalizations? l) {
    return Container(
      padding: EdgeInsets.all(19.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.w),
          bottomRight: Radius.circular(15.w),
        ),
      ),
      child: Column(
        children: [
          Text(
            l?.translate('invitation_thank_you') ?? 'Thank you for using Maktoob app',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${l?.translate('invitation_support') ?? 'For support'}: support@maktoob.app',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, InvitationState state, AppLocalizations? l) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 9.w,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // WhatsApp notice
          Container(
            padding: EdgeInsets.all(11.w),
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 17.w,
                  color: Colors.green.shade700,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    l?.translate('invitation_invoice_delivery_notice') ?? 'Invoice will be sent via WhatsApp or within the app',
                    style: TextStyle(
                      fontSize: 11.sp,
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
                  text: l?.translate('common_back') ?? 'Back',
                  onPressed: state.isSaving
                      ? null
                      : () {
                          context.read<InvitationCubit>().previousStep();
                        },
                  backgroundColor: Colors.grey.shade200,
                  textColor: Colors.black87,
                ),
              ),

              SizedBox(width: 11.w),

              // Save as Draft Button
              Expanded(
                child: AppButton(
                  text: l?.translate('invitation_save_draft') ?? 'Save Draft',
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

              SizedBox(width: 11.w),

              // Save & Send Button
              Expanded(
                flex: 2,
                child: AppButton(
                  text: l?.translate('invitation_save_send') ?? 'Save & Send',
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          // Capture cubit before async gap
                          final cubit = context.read<InvitationCubit>();
                          // Capture invoice screenshot first
                          final image = await _captureInvoice();
                          if (mounted && image != null) {
                            // Save image to temp file and share via WhatsApp
                            await _saveAndShareInvoice(this.context, image, state, l);
                          } else if (mounted) {
                            // If image capture fails, just save without sharing
                            await cubit.saveAndSend(invoiceImage: image);
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

  void _showSuccessDialog(BuildContext context, bool isDraft, AppLocalizations? l) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75.w,
              height: 75.w,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 45.w,
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              isDraft
                  ? (l?.translate('invitation_saved_as_draft') ?? 'Saved as Draft')
                  : (l?.translate('invitation_saved_successfully') ?? 'Saved Successfully!'),
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isDraft
                  ? (l?.translate('invitation_continue_later') ?? 'You can continue creating the event later')
                  : (l?.translate('invitation_sent_via_whatsapp') ?? 'Invoice sent via WhatsApp'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            text: l?.translate('invitation_back_to_home') ?? 'Back to Home',
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
