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

/// Page 7: Invoice and Save Screen
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationCubit>().loadInvoice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return BlocConsumer<InvitationCubit, InvitationState>(
      listener: (context, state) => _handleStateChange(context, state, l),
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                WizardStepHeader(
                  currentStep: 7,
                  totalSteps: 7,
                  title: l?.translate('invitation_step7_title') ??
                      'Invoice & Save',
                ),
                Expanded(
                  child: _InvoiceContent(
                    state: state,
                    invoiceKey: _invoiceKey,
                    isEnglish: isEnglish,
                  ),
                ),
                _InvoiceActionButtons(
                  state: state,
                  invoiceKey: _invoiceKey,
                  onComplete: widget.onComplete,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStateChange(
    BuildContext context,
    InvitationState state,
    AppLocalizations? l,
  ) {
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
        _showSuccessDialog(context, state.isSaveAsDraft, l);
      }
    }

    if (state.saveError != null) {
      AppSnackBar.showError(context, message: state.saveError!);
    }
  }

  void _showSuccessDialog(
    BuildContext context,
    bool isDraft,
    AppLocalizations? l,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            SizedBox(height: context.dynamicHeight(0.03)),
            Text(
              isDraft
                  ? (l?.translate('invitation_saved_as_draft') ??
                      'Saved as Draft')
                  : (l?.translate('invitation_saved_successfully') ??
                      'Saved Successfully!'),
              style: TextStyle(
                fontSize: context.dynamicWidth(0.051),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              isDraft
                  ? (l?.translate('invitation_continue_later') ??
                      'You can continue creating the event later')
                  : (l?.translate('invitation_sent_via_whatsapp') ??
                      'Invoice sent via WhatsApp'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                color: Colors.grey.shade600,
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

class _InvoiceContent extends StatelessWidget {
  final InvitationState state;
  final GlobalKey invoiceKey;
  final bool isEnglish;

  const _InvoiceContent({
    required this.state,
    required this.invoiceKey,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (state.isLoadingInvoice) {
      return _LoadingState(l: l);
    }

    if (state.invoiceError != null) {
      return _ErrorState(error: state.invoiceError!, l: l);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: RepaintBoundary(
        key: invoiceKey,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: context.dynamicWidth(0.051),
                offset: Offset(0, context.dynamicHeight(0.01)),
              ),
            ],
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
    );
  }
}

class _LoadingState extends StatelessWidget {
  final AppLocalizations? l;

  const _LoadingState({this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: context.dynamicHeight(0.02)),
          Text(
            l?.translate('invitation_loading_invoice') ?? 'Loading invoice...',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.04),
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final AppLocalizations? l;

  const _ErrorState({required this.error, this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.061)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: context.dynamicWidth(0.16), color: Colors.red.shade300),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              l?.translate('invitation_invoice_error') ??
                  'Error loading invoice',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            SizedBox(
              width: context.dynamicWidth(0.501),
              child: PrimaryButton(
                text: l?.translate('common_retry') ?? 'Retry',
                onPressed: () {
                  context.read<InvitationCubit>().loadInvoice();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceActionButtons extends StatelessWidget {
  final InvitationState state;
  final GlobalKey invoiceKey;
  final VoidCallback? onComplete;

  const _InvoiceActionButtons({
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.024),
            offset: Offset(0, -context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _WhatsAppNotice(l: l),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: l?.translate('common_back') ?? 'Back',
                    onPressed: state.isSaving
                        ? null
                        : () => context.read<InvitationCubit>().previousStep(),
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.029)),
                Expanded(
                  child: _DraftButton(state: state, l: l),
                ),
                SizedBox(width: context.dynamicWidth(0.029)),
                Expanded(
                  flex: 2,
                  child: _SaveSendButton(
                    state: state,
                    invoiceKey: invoiceKey,
                    l: l,
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

class _WhatsAppNotice extends StatelessWidget {
  final AppLocalizations? l;

  const _WhatsAppNotice({this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.029)),
      margin: EdgeInsets.only(bottom: context.dynamicHeight(0.015)),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: context.dynamicWidth(0.045), color: Colors.green.shade700),
          SizedBox(width: context.dynamicWidth(0.021)),
          Expanded(
            child: Text(
              l?.translate('invitation_invoice_delivery_notice') ??
                  'Invoice will be sent via WhatsApp or within the app',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftButton extends StatelessWidget {
  final InvitationState state;
  final AppLocalizations? l;

  const _DraftButton({required this.state, this.l});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state.isSaving
          ? null
          : () async => await context.read<InvitationCubit>().saveDraft(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.018),
        ),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        ),
        child: state.isSaving && state.isSaveAsDraft
            ? Center(
                child: SizedBox(
                  width: context.dynamicWidth(0.05),
                  height: context.dynamicWidth(0.05),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.orange.shade800,
                  ),
                ),
              )
            : Text(
                l?.translate('invitation_save_draft') ?? 'Save Draft',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: context.dynamicWidth(0.035),
                ),
              ),
      ),
    );
  }
}

class _SaveSendButton extends StatelessWidget {
  final InvitationState state;
  final GlobalKey invoiceKey;
  final AppLocalizations? l;

  const _SaveSendButton({
    required this.state,
    required this.invoiceKey,
    this.l,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: l?.translate('invitation_save_send') ?? 'Save & Send',
      icon: Icons.send,
      isLoading: state.isSaving && !state.isSaveAsDraft,
      onPressed: state.isSaving
          ? null
          : () async {
              final cubit = context.read<InvitationCubit>();
              final image = await _captureInvoice(invoiceKey);
              if (context.mounted && image != null) {
                await _saveAndShareInvoice(context, image, state, l);
              } else if (context.mounted) {
                await cubit.saveAndSend(invoiceImage: image);
              }
            },
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
      final shareText = l?.translate('invitation_share_invoice_text') ??
          'Invoice for $eventName - Maktoob App';

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
