import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
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

  // Tracks the package id we last triggered a `loadInvoice` for. The listener
  // guards against re-firing while loading (which itself emits state changes
  // and would otherwise trigger an infinite loop).
  int? _invoiceFetchedForPackageId;

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
          previous.saveError != current.saveError ||
          previous.selectedPackage?.id != current.selectedPackage?.id,
      listener: (context, state) {
        if (state.customPackageLimit != null &&
            _customLimitController.text != state.customPackageLimit.toString()) {
          _customLimitController.text = state.customPackageLimit.toString();
        }

        // Re-fetch the invoice when the user picks a different package (or the
        // very first time). `_invoiceFetchedForPackageId` prevents a loop with
        // listenWhen, which fires whenever selectedPackage changes — including
        // any reference change loadInvoice itself produces in state.
        final pkgId = state.selectedPackage?.id;
        if (pkgId != null && pkgId != _invoiceFetchedForPackageId) {
          _invoiceFetchedForPackageId = pkgId;
          context.read<InvitationCubit>().loadInvoice();
        }

        if (state.saveSuccess) {
          if (state.isSaveAsDraft) {
            AppSnackBar.showSuccess(
              context,
              message: l?.translate('invitation_draft_saved_success') ?? '',
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
        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          appBar: MaktoobAppBar(
            title: l?.translate('app_name') ?? 'Maktoob',
            titleFontSize: 20,
            titleFontWeight: FontWeight.w800,
            onForward: () => context.read<InvitationCubit>().previousStep(),
          ),
          body: Column(
            children: [
              WizardStepHeader(
                currentStep: 3,
                totalSteps: 3,
                title: l?.translate('wizard_step3_label') ?? 'المراجعة والإرسال',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.05),
                    vertical: context.dynamicHeight(0.018),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PageHeader(
                        title: l?.translate('wizard_review_request_title') ??
                            'مراجعة طلبك',
                        subtitle: l?.translate('wizard_review_request_subtitle') ??
                            'يرجى مراجعة تفاصيل دعوتك قبل الإرسال النهائي.',
                      ),
                      const SizedBox(height: 20),
                      _SectionLabel(
                        text: l?.translate('wizard_selected_package') ??
                            'الباقة المختارة',
                      ),
                      const SizedBox(height: 10),
                      _PackageOverview(
                        state: state,
                        isEnglish: isEnglish,
                        customLimitController: _customLimitController,
                      ),
                      const SizedBox(height: 20),
                      _GlassInvoiceCard(
                        state: state,
                        invoiceKey: _invoiceKey,
                        isEnglish: isEnglish,
                      ),
                      const SizedBox(height: 16),
                      const _LiveStatusBanner(),
                      const SizedBox(height: 20),
                      _FinalPreviewCard(state: state),
                      const SizedBox(height: 24),
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
// Page header (title + subtitle)
// =============================================================================

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PageHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Section label (small, uppercase-ish)
// =============================================================================

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.gray500,
        letterSpacing: 0.6,
      ),
    );
  }
}

// =============================================================================
// Selected package overview (single-row card with gradient border)
// =============================================================================

class _PackageOverview extends StatelessWidget {
  final InvitationState state;
  final bool isEnglish;
  final TextEditingController customLimitController;

  const _PackageOverview({
    required this.state,
    required this.isEnglish,
    required this.customLimitController,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingPackages) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final selected = state.selectedPackage;
    final l = AppLocalizations.of(context);

    if (selected == null) {
      return _PackagePicker(state: state, isEnglish: isEnglish);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish ? selected.name : selected.nameAr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l?.translate('invitation_package_subtitle') ??
                        'خدمة شاملة مع تصميم مخصص',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  selected.price.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  l?.translate('currency_ils') ?? 'ر.س',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PackagePicker extends StatelessWidget {
  final InvitationState state;
  final bool isEnglish;
  const _PackagePicker({required this.state, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    if (state.availablePackages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray200),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        for (final package in state.availablePackages) ...[
          PackageCard(
            package: package,
            isSelected: false,
            guestCount: state.allGuests.length,
            customPrice: state.customPackagePrice,
            isLoadingPrice: state.isLoadingCustomPrice,
            customLimit: state.customPackageLimit,
            isEnglish: isEnglish,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// =============================================================================
// Glass invoice card
// =============================================================================

class _GlassInvoiceCard extends StatelessWidget {
  final InvitationState state;
  final GlobalKey invoiceKey;
  final bool isEnglish;

  const _GlassInvoiceCard({
    required this.state,
    required this.invoiceKey,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final summary = state.invoiceSummary;
    final isLoading = state.isLoadingInvoice;
    final selected = state.selectedPackage;

    final subtotal = summary?.basePrice ?? selected?.price ?? 0.0;
    final extras = summary?.servicesTotal ??
        state.selectedServices.fold<double>(
            0, (sum, s) => sum + s.price);
    final extrasCount = state.selectedServices.length;
    // The API's InvoiceSummaryModel doesn't return a separate tax field, so
    // VAT and total are both computed client-side. Computing total locally
    // (rather than reading summary.totalPrice) guarantees the displayed rows
    // always sum to the displayed total — no rounding mismatch with the
    // server. If the server later returns a discount, surface it as a row
    // here so reconciliation stays visible.
    final vat = (subtotal + extras) * 0.15;
    final total = subtotal + extras + vat;

    return RepaintBoundary(
      key: invoiceKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  l?.translate('wizard_invoice_summary') ?? 'ملخص الفاتورة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.gray200),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _InvoiceRow(
                label: l?.translate('wizard_invoice_subtotal') ??
                    'المجموع الفرعي (الباقة)',
                value: '${subtotal.toStringAsFixed(2)} ${l?.translate('currency_ils') ?? 'ر.س'}',
              ),
              const SizedBox(height: 14),
              _InvoiceRow(
                label: l?.translate('wizard_invoice_extras') ?? 'خدمات إضافية',
                value: '${extras.toStringAsFixed(2)} ${l?.translate('currency_ils') ?? 'ر.س'}',
                badge: extrasCount > 0 ? '$extrasCount' : null,
              ),
              const SizedBox(height: 14),
              _InvoiceRow(
                label: l?.translate('wizard_invoice_vat') ??
                    'ضريبة القيمة المضافة (15%)',
                value: '${vat.toStringAsFixed(2)} ${l?.translate('currency_ils') ?? 'ر.س'}',
              ),
              const SizedBox(height: 16),
              CustomPaint(
                painter: _DashedLinePainter(color: AppColors.gray200),
                child: const SizedBox(height: 1, width: double.infinity),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l?.translate('wizard_invoice_total') ?? 'الإجمالي',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTotal(total),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          l?.translate('currency_ils') ?? 'ر.س',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTotal(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '${buf.toString()}.${parts[1]}';
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final String? badge;
  const _InvoiceRow({required this.label, required this.value, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const dashWidth = 5.0;
    const dashGap = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

// =============================================================================
// Live status banner with pulsing dot
// =============================================================================

class _LiveStatusBanner extends StatefulWidget {
  const _LiveStatusBanner();

  @override
  State<_LiveStatusBanner> createState() => _LiveStatusBannerState();
}

class _LiveStatusBannerState extends State<_LiveStatusBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final t = _controller.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 16 * t,
                      height: 16 * t,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor.withValues(alpha: (1 - t) * 0.5),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l?.translate('wizard_instant_execution_notice') ??
                  'هذا الطلب سيتم تنفيذه بشكل فوري عند التأكيد.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.tertiaryColor.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Final preview card
// =============================================================================

class _FinalPreviewCard extends StatelessWidget {
  final InvitationState state;
  const _FinalPreviewCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final imageUrl = state.generatedImageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.gray100),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.gray100),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.2),
                      AppColors.tertiaryColor.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.image_outlined,
                      color: Colors.white.withValues(alpha: 0.6), size: 48),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    l?.translate('wizard_final_preview_label') ??
                        'معاينة المسودة النهائية',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Action bar — primary "Send & Finish" + outlined "Save Draft"
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
      padding: EdgeInsets.fromLTRB(
        context.dynamicWidth(0.05),
        14,
        context.dynamicWidth(0.05),
        14,
      ),
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
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: PrimaryButton(
                text: l?.translate('wizard_send_and_finish') ?? 'إرسال وإنهاء',
                icon: Icons.send_rounded,
                isLoading: state.isSaving && !state.isSaveAsDraft,
                onPressed: state.isSaving || !state.canProceedFromPackage
                    ? null
                    : () async {
                        final cubit = context.read<InvitationCubit>();
                        // Freemium package: activate the event without an
                        // invoice — skip capture and the share sheet.
                        if (state.selectedPackage?.isFree ?? false) {
                          await cubit.saveAndSend(invoiceImage: null);
                          return;
                        }
                        final image = await _captureInvoice(invoiceKey);
                        if (context.mounted && image != null) {
                          await _saveAndShareInvoice(context, image, state, l);
                        } else if (context.mounted) {
                          await cubit.saveAndSend(invoiceImage: image);
                        }
                      },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: _OutlinedDraftButton(
                label: l?.translate('wizard_save_as_draft') ?? 'حفظ كمسودة',
                isLoading: state.isSaving && state.isSaveAsDraft,
                onPressed: state.isSaving
                    ? null
                    : () => context.read<InvitationCubit>().saveDraft(),
              ),
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

class _OutlinedDraftButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _OutlinedDraftButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tertiaryColor,
          side: BorderSide(color: AppColors.tertiaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.tertiaryColor,
                ),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
