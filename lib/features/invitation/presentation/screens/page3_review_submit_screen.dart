import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';

/// Page 3 (of 3): Review & Submit
/// Combines package selection, invoice, and submit actions.
class Page3ReviewSubmitScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const Page3ReviewSubmitScreen({super.key, this.onComplete});

  @override
  State<Page3ReviewSubmitScreen> createState() =>
      _Page3ReviewSubmitScreenState();
}

class _Page3ReviewSubmitScreenState extends State<Page3ReviewSubmitScreen> {
  final GlobalKey _invoiceKey = GlobalKey();
  final TextEditingController _customLimitController = TextEditingController();

  // Track which sections are expanded
  bool _packageExpanded = true;
  bool _invoiceExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<InvitationCubit>();
      final state = cubit.state;
      if (state.customPackageLimit != null && state.customPackageLimit! > 0) {
        _customLimitController.text = state.customPackageLimit.toString();
      }
      cubit.loadPackages();
    });
  }

  @override
  void dispose() {
    _customLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (previous, current) =>
          previous.customPackageLimit != current.customPackageLimit ||
          previous.saveSuccess != current.saveSuccess ||
          previous.saveError != current.saveError,
      listener: (context, state) {
        // Sync custom limit controller
        if (state.customPackageLimit != null &&
            _customLimitController.text !=
                state.customPackageLimit.toString()) {
          _customLimitController.text = state.customPackageLimit.toString();
        }

        // Handle save result
        if (state.saveSuccess) {
          if (state.isSaveAsDraft) {
            AppSnackBar.showSuccess(
              context,
              message: l?.translate('invitation_draft_saved_success') ??
                  'Draft saved successfully',
              duration: const Duration(seconds: 2),
            );
            if (widget.onComplete != null) {
              widget.onComplete!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } else {
            _showSuccessDialog(context, l);
          }
        }

        if (state.saveError != null) {
          AppSnackBar.showError(context, message: state.saveError!);
        }
      },
      builder: (context, state) {
        // Auto-expand invoice when package is selected
        if (state.selectedPackage != null && !_invoiceExpanded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _invoiceExpanded = true);
              // Load invoice when package is selected
              context.read<InvitationCubit>().loadInvoice();
            }
          });
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              _ModernStepHeader3(
                stepNumber: 3,
                title: l?.translate('wizard_step3_review_title') ??
                    'Review & Submit',
                subtitle: l?.translate('wizard_step3_review_subtitle') ??
                    'Choose a package and confirm your event',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.04),
                    vertical: context.dynamicHeight(0.02),
                  ),
                  child: Column(
                    children: [
                      // Guest count info
                      GuestCountInfoBar(state: state),
                      SizedBox(height: context.dynamicHeight(0.015)),

                      // Section 1: Package Selection
                      _CollapsibleSection(
                        title: l?.translate('invitation_package_selection') ??
                            'Package',
                        subtitle: state.selectedPackage != null
                            ? (isEnglish
                                ? state.selectedPackage!.name
                                : state.selectedPackage!.nameAr)
                            : null,
                        icon: Icons.inventory_2_rounded,
                        isExpanded: _packageExpanded,
                        isComplete: state.canProceedFromPackage,
                        onToggle: () => setState(
                            () => _packageExpanded = !_packageExpanded),
                        child: _PackageSection(
                          state: state,
                          isEnglish: isEnglish,
                          customLimitController: _customLimitController,
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.015)),

                      // Section 2: Invoice Preview
                      _CollapsibleSection(
                        title: l?.translate('invitation_invoice') ?? 'Invoice',
                        subtitle: state.invoiceSummary != null
                            ? '${state.invoiceSummary!.totalPrice.toStringAsFixed(0)} ILS'
                            : null,
                        icon: Icons.receipt_long_rounded,
                        isExpanded: _invoiceExpanded,
                        isComplete: state.invoiceSummary != null,
                        onToggle: () => setState(
                            () => _invoiceExpanded = !_invoiceExpanded),
                        child: _InvoiceSection(
                          state: state,
                          invoiceKey: _invoiceKey,
                          isEnglish: isEnglish,
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.1)),
                    ],
                  ),
                ),
              ),
              _ActionBar(
                state: state,
                invoiceKey: _invoiceKey,
                onComplete: widget.onComplete,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, AppLocalizations? l) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: context.dynamicHeight(0.02)),
            Container(
              width: context.dynamicWidth(0.2),
              height: context.dynamicWidth(0.2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: context.dynamicWidth(0.12),
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.025)),
            Text(
              l?.translate('invitation_saved_successfully') ??
                  'Saved Successfully!',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.05),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              l?.translate('invitation_sent_via_whatsapp') ??
                  'Invoice sent via WhatsApp',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            text: l?.translate('invitation_back_to_home') ?? 'Back to Home',
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (widget.onComplete != null) {
                widget.onComplete!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// STEP HEADER
// =============================================================================

class _ModernStepHeader3 extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String? subtitle;

  const _ModernStepHeader3({
    required this.stepNumber,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: context.dynamicWidth(0.05),
        right: context.dynamicWidth(0.05),
        top: context.dynamicHeight(0.02),
        bottom: context.dynamicHeight(0.025),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      context.read<InvitationCubit>().previousStep(),
                  child: Container(
                    width: context.dynamicWidth(0.09),
                    height: context.dynamicWidth(0.09),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: context.dynamicWidth(0.05),
                    ),
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.04)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.dynamicWidth(0.055),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: context.dynamicHeight(0.003)),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: context.dynamicWidth(0.032),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            _StepDotsIndicator(currentStep: stepNumber),
          ],
        ),
      ),
    );
  }
}

class _StepDotsIndicator extends StatelessWidget {
  final int currentStep;

  const _StepDotsIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final step = index + 1;
        final isActive = step <= currentStep;
        final isCurrent = step == currentStep;

        return Expanded(
          child: Container(
            margin:
                EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.01)),
            height: context.dynamicHeight(0.005),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius:
                  BorderRadius.circular(context.dynamicWidth(0.01)),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.4),
                        blurRadius: 6,
                      )
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// =============================================================================
// COLLAPSIBLE SECTION (same pattern as Page 1)
// =============================================================================

class _CollapsibleSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isExpanded;
  final bool isComplete;
  final VoidCallback onToggle;
  final Widget child;

  const _CollapsibleSection({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.isExpanded,
    required this.isComplete,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        border: Border.all(
          color: isComplete
              ? AppColors.primaryColor.withValues(alpha: 0.3)
              : context.borderColor,
          width: isComplete ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.dynamicWidth(0.04)),
              bottom: isExpanded
                  ? Radius.zero
                  : Radius.circular(context.dynamicWidth(0.04)),
            ),
            child: Padding(
              padding: EdgeInsets.all(context.dynamicWidth(0.04)),
              child: Row(
                children: [
                  Container(
                    width: context.dynamicWidth(0.1),
                    height: context.dynamicWidth(0.1),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppColors.primaryColor.withValues(alpha: 0.1)
                          : context.inputFill,
                      borderRadius: BorderRadius.circular(
                          context.dynamicWidth(0.03)),
                    ),
                    child: Icon(
                      isComplete ? Icons.check_circle_rounded : icon,
                      color: isComplete
                          ? AppColors.primaryColor
                          : context.iconSecondary,
                      size: context.dynamicWidth(0.055),
                    ),
                  ),
                  SizedBox(width: context.dynamicWidth(0.035)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: context.dynamicWidth(0.04),
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                        if (subtitle != null && !isExpanded) ...[
                          SizedBox(height: context.dynamicHeight(0.003)),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: context.dynamicWidth(0.032),
                              color: context.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.iconSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: EdgeInsets.only(
                left: context.dynamicWidth(0.04),
                right: context.dynamicWidth(0.04),
                bottom: context.dynamicWidth(0.04),
              ),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PACKAGE SECTION
// =============================================================================

class _PackageSection extends StatelessWidget {
  final InvitationState state;
  final bool isEnglish;
  final TextEditingController customLimitController;

  const _PackageSection({
    required this.state,
    required this.isEnglish,
    required this.customLimitController,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (state.isLoadingPackages) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.04)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.packagesError != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.02)),
        child: Column(
          children: [
            Icon(Icons.error_outline,
                size: context.dynamicWidth(0.1), color: Colors.red.shade300),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(state.packagesError!,
                style: TextStyle(color: context.textSecondary)),
            SizedBox(height: context.dynamicHeight(0.01)),
            PrimaryButton(
              text: l?.translate('common_retry') ?? 'Retry',
              onPressed: () =>
                  context.read<InvitationCubit>().loadPackages(),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: context.borderColor),
        SizedBox(height: context.dynamicHeight(0.005)),
        // Validation error
        if (!state.canProceedFromPackage && state.selectedPackage != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.dynamicWidth(0.025)),
            margin: EdgeInsets.only(bottom: context.dynamicHeight(0.01)),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius:
                  BorderRadius.circular(context.dynamicWidth(0.02)),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline,
                    color: Colors.red.shade700,
                    size: context.dynamicWidth(0.045)),
                SizedBox(width: context.dynamicWidth(0.02)),
                Expanded(
                  child: Text(
                    l?.translate(
                            'invitation_guest_exceeds_package_message') ??
                        'Guest count exceeds package limit.',
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.028),
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Package cards
        ...state.availablePackages.map((package) {
          final isSelected = state.selectedPackage?.id == package.id;
          return PackageCard(
            package: package,
            isSelected: isSelected,
            guestCount: state.allGuests.length,
            customPrice: state.customPackagePrice,
            isLoadingPrice: state.isLoadingCustomPrice,
            customLimit: state.customPackageLimit,
            isEnglish: isEnglish,
            customLimitController:
                package.isCustom ? customLimitController : null,
          );
        }),
      ],
    );
  }
}

// =============================================================================
// INVOICE SECTION
// =============================================================================

class _InvoiceSection extends StatelessWidget {
  final InvitationState state;
  final GlobalKey invoiceKey;
  final bool isEnglish;

  const _InvoiceSection({
    required this.state,
    required this.invoiceKey,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (state.isLoadingInvoice) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.04)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.invoiceError != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.02)),
        child: Column(
          children: [
            Icon(Icons.error_outline,
                size: context.dynamicWidth(0.1), color: Colors.red.shade300),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(state.invoiceError!,
                style: TextStyle(color: context.textSecondary)),
            SizedBox(height: context.dynamicHeight(0.01)),
            PrimaryButton(
              text: l?.translate('common_retry') ?? 'Retry',
              onPressed: () =>
                  context.read<InvitationCubit>().loadInvoice(),
            ),
          ],
        ),
      );
    }

    if (state.invoiceSummary == null && state.selectedPackage == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.03)),
        child: Center(
          child: Text(
            l?.translate('invitation_select_package_first') ??
                'Select a package above to see the invoice',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: context.dynamicWidth(0.035),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Divider(color: context.borderColor),
        SizedBox(height: context.dynamicHeight(0.005)),
        RepaintBoundary(
          key: invoiceKey,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(context.dynamicWidth(0.03)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InvoiceHeader(state: state),
                InvoiceEventDetails(state: state, isEnglish: isEnglish),
                InvoiceItemsSection(state: state, isEnglish: isEnglish),
                InvoiceTotalSection(state: state),
                const InvoiceFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// ACTION BAR
// =============================================================================

class _ActionBar extends StatelessWidget {
  final InvitationState state;
  final GlobalKey invoiceKey;
  final VoidCallback? onComplete;

  const _ActionBar({
    required this.state,
    required this.invoiceKey,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // WhatsApp notice
            Container(
              padding: EdgeInsets.all(context.dynamicWidth(0.025)),
              margin: EdgeInsets.only(bottom: context.dynamicHeight(0.01)),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius:
                    BorderRadius.circular(context.dynamicWidth(0.02)),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: context.dynamicWidth(0.04),
                      color: Colors.green.shade700),
                  SizedBox(width: context.dynamicWidth(0.02)),
                  Expanded(
                    child: Text(
                      l?.translate('invitation_invoice_delivery_notice') ??
                          'Invoice will be sent via WhatsApp or within the app',
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.028),
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // Save & Send button
                Expanded(
                  flex: 3,
                  child: PrimaryButton(
                    text: l?.translate('invitation_save_send') ?? 'Save & Send',
                    icon: Icons.send,
                    isLoading: state.isSaving && !state.isSaveAsDraft,
                    onPressed: state.isSaving || !state.canProceedFromPackage
                        ? null
                        : () async {
                            final cubit = context.read<InvitationCubit>();
                            final image = await _captureInvoice(invoiceKey);
                            if (context.mounted && image != null) {
                              await _saveAndShareInvoice(
                                  context, image, state, l);
                            } else if (context.mounted) {
                              await cubit.saveAndSend(invoiceImage: image);
                            }
                          },
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.02)),
                // Save Draft button
                Expanded(
                  flex: 2,
                  child: Material(
                    color: Colors.orange.shade100,
                    borderRadius:
                        BorderRadius.circular(context.dynamicWidth(0.029)),
                    child: InkWell(
                      onTap: state.isSaving
                          ? null
                          : () async => await context
                              .read<InvitationCubit>()
                              .saveDraft(),
                      borderRadius: BorderRadius.circular(
                          context.dynamicWidth(0.029)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dynamicWidth(0.02),
                          vertical: context.dynamicHeight(0.018),
                        ),
                        alignment: Alignment.center,
                        child: state.isSaving && state.isSaveAsDraft
                            ? SizedBox(
                                width: context.dynamicWidth(0.05),
                                height: context.dynamicWidth(0.05),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.orange.shade800,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  l?.translate('invitation_save_draft') ??
                                      'Save Draft',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: context.dynamicWidth(0.035),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _captureInvoice(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing invoice: $e');
      return null;
    }
  }

  Future<void> _saveAndShareInvoice(
    BuildContext context,
    Uint8List imageBytes,
    InvitationState state,
    AppLocalizations? l,
  ) async {
    final cubit = context.read<InvitationCubit>();

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/invoice_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      if (!context.mounted) return;

      await cubit.saveAndSend(invoiceImage: imageBytes);

      if (!context.mounted) return;

      final eventName = state.eventName ?? 'Event';
      final packageName = l?.isEnLocale == true
          ? (state.selectedPackage?.name ?? 'N/A')
          : (state.selectedPackage?.nameAr ?? 'N/A');
      final guestCount = state.totalGuestCount;
      final totalPrice = state.selectedPackage?.price ?? 0.0;

      final isArabic = l?.isEnLocale == false;
      final shareText = isArabic
          ? 'مرحباً! هذه فاتورة حجز دعوة من تطبيق مكتوب\n\n'
            'المناسبة: $eventName\n'
            'الباقة: $packageName\n'
            'عدد الضيوف: $guestCount\n'
            'المبلغ الإجمالي: $totalPrice شيكل\n\n'
            'أرفقت صورة الفاتورة.\n'
            'شكراً لكم!\n\n'
            '---\n'
            'Maktoob Events'
          : 'Hello! This is an invoice from Maktoob App\n\n'
            'Event: $eventName\n'
            'Package: $packageName\n'
            'Number of Guests: $guestCount\n'
            'Total Amount: $totalPrice ILS\n\n'
            'Invoice image attached.\n'
            'Thank you!\n\n'
            '---\n'
            'Maktoob Events';

      await Share.shareXFiles([XFile(filePath)], text: shareText);
    } catch (e) {
      debugPrint('Error sharing invoice: $e');
      if (!context.mounted) return;

      AppSnackBar.showError(
        context,
        message: l?.translate('invitation_share_error') ??
            'Error sharing invoice. Please try again.',
      );
    }
  }
}
