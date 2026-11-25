import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../config/locale/app_localizations.dart';
import '../../../../../core/core.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';
import 'outlined_draft_button.dart';


class CheckoutActionBar extends StatelessWidget {
  final InvitationState state;
  final GlobalKey invoiceKey;
  final VoidCallback? onComplete;

  const CheckoutActionBar({
    super.key,
    required this.state,
    required this.invoiceKey,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.creditsCoverSelectedPackage)
              Padding(
                key: const Key('wizard_credits_cover_notice'),
                padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        size: 18, color: AppColors.primaryColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l?.translate('wizard_credits_will_be_deducted') ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: PrimaryButton(
                    text:
                        l?.translate('wizard_send_and_finish') ??
                        'إرسال وإنهاء',
                    icon: Icons.send_rounded,
                    isLoading: state.isSaving && !state.isSaveAsDraft,
                    onPressed: state.isSaving || !state.canProceedFromPackage
                        ? null
                        : () async {
                            final cubit = context.read<InvitationCubit>();
                            // Freemium: activated immediately, no invoice.
                            // Paid: save (pending_payment), then the listener
                            // opens the payment screen. Sharing the invoice is a
                            // secondary action below.
                            final isFree =
                                state.selectedPackage?.isFree ?? false;
                            await cubit.saveAndSend(
                              invoiceImage: null,
                              openWhatsApp: isFree,
                            );
                          },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: OutlinedDraftButton(
                    label: l?.translate('wizard_save_as_draft') ?? 'حفظ كمسودة',
                    isLoading: state.isSaving && state.isSaveAsDraft,
                    onPressed: state.isSaving
                        ? null
                        : () => context.read<InvitationCubit>().saveDraft(),
                  ),
                ),
              ],
            ),
            ?shareAction(context, l),
          ],
        ),
      ),
    );
  }

  /// Secondary action for paid packages: share the invoice image.
  Widget? shareAction(BuildContext context, AppLocalizations? l) {
    if (state.selectedPackage?.isFree ?? true) return null;
    return TextButton.icon(
      key: const Key('wizard_share_invoice'),
      onPressed: state.isSaving
          ? null
          : () async {
              final image = await _captureInvoice(invoiceKey);
              if (context.mounted && image != null) {
                await _shareInvoice(context, image, state, l);
              }
            },
      icon: const Icon(Icons.ios_share, size: 18),
      label: Text(l?.translate('wizard_share_invoice') ?? ''),
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

  Future<void> _shareInvoice(
    BuildContext context,
    Uint8List imageBytes,
    InvitationState state,
    AppLocalizations? l,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/invoice_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

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

      await SharePlus.instance.share(ShareParams(files: [XFile(filePath)], text: shareText));
    } catch (e) {
      debugPrint('Error sharing invoice: $e');
      if (!context.mounted) return;

      AppSnackBar.showError(
        context,
        message:
            l?.translate('invitation_share_error') ??
            'Error sharing invoice. Please try again.',
      );
    }
  }
}
