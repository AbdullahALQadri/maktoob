import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/payment_method.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/widgets.dart';

/// Manual payment for Gaza (no card gateways): cash in person, bank transfer
/// (IBAN) or a local wallet. The admin confirms in the dashboard and the
/// event activates.
class PaymentUploadScreen extends StatefulWidget {
  final String? eventId;
  final VoidCallback? onComplete;

  /// The event's invoice total in ₪ (shown and put in the WhatsApp message).
  final double? amount;

  /// Used in the WhatsApp message when there is no event id.
  final String? eventTitle;

  /// Submit to this path instead of `/payment-requests` (e.g. paying for
  /// extra services added after the event was paid).
  final String? endpoint;

  const PaymentUploadScreen({
    super.key,
    this.eventId,
    this.onComplete,
    this.amount,
    this.eventTitle,
    this.endpoint,
  });

  @override
  State<PaymentUploadScreen> createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  PaymentChoice? _choice;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    context.read<PaymentCubit>().loadBankDetails();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubmit(PaymentState state) {
    if (state is UploadSuccess) {
      widget.onComplete?.call();
      return;
    }
    final choice = _choice;
    if (choice == null) return;
    context.read<PaymentCubit>().uploadInvoice(
          eventId: widget.eventId ?? '',
          method: choice.method,
          walletProvider: choice.wallet?.providerName,
          endpoint: widget.endpoint,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is UploadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.red500),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.overlayBg,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                const PaymentHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    child: BlocBuilder<PaymentCubit, PaymentState>(
                      builder: (context, state) {
                        final choices = PaymentChoice.available(state.bankDetails);
                        final choice = choices.contains(_choice) ? _choice : null;
                        return _PaymentContent(
                          state: state,
                          choices: choices,
                          choice: choice,
                          amount: widget.amount,
                          eventLabel: (widget.eventId?.isNotEmpty ?? false)
                              ? widget.eventId!
                              : (widget.eventTitle ?? ''),
                          onChoice: (c) => setState(() => _choice = c),
                          onSubmit: () => _handleSubmit(state),
                          onSkip: widget.onComplete,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentContent extends StatelessWidget {
  final PaymentState state;
  final List<PaymentChoice> choices;
  final PaymentChoice? choice;
  final double? amount;
  final String eventLabel;
  final ValueChanged<PaymentChoice> onChoice;
  final VoidCallback onSubmit;
  final VoidCallback? onSkip;

  const _PaymentContent({
    required this.state,
    required this.choices,
    required this.choice,
    required this.amount,
    required this.eventLabel,
    required this.onChoice,
    required this.onSubmit,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final current = state;
    final isUploading = current is Uploading;
    final uploadProgress = current is Uploading ? current.progress : 0.0;
    final details = current.bankDetails;
    final whatsapp = details?.paymentWhatsapp;
    final c = choice;

    // Done: friendly confirmation + WhatsApp + continue.
    if (current is UploadSuccess) {
      final cash = current.method == PaymentMethod.cash;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AmountLine(amount: amount),
          Container(
            key: const Key('payment_success'),
            padding: const EdgeInsetsDirectional.all(AppSpacing.mdl),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppSpacing.borderRadiusLg,
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, color: context.brandInk, size: 48),
                AppSpacing.verticalSpace12,
                Text(
                  l.translate(cash ? 'payment_cash_success' : 'payment_transfer_success'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpace16,
          PaymentWhatsappButton(
            number: whatsapp,
            event: eventLabel,
            amount: amount,
            methodLabel: c?.label(l) ?? l.translate('payment_method_cash'),
          ),
          AppSpacing.verticalSpace12,
          PaymentSubmitButton(
            isUploading: false,
            uploadSuccess: true,
            canSubmit: true,
            onPressed: onSubmit,
          ),
          AppSpacing.verticalSpace32,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AmountLine(amount: amount),
        // null = still loading; a failed request arrives as
        // BankDetailsEntity.loadFailed() (retry card). Cash stays available.
        if (details == null)
          const BankDetailsCardSkeleton()
        else ...[
          if (details.loadFailed) ...[
            BankDetailsCardWidget(
              bankDetails: details,
              onRetry: () => context.read<PaymentCubit>().loadBankDetails(),
            ),
            AppSpacing.verticalSpace16,
          ],
          PaymentMethodSelector(
            choices: choices,
            selected: c,
            onChanged: isUploading ? null : onChoice,
          ),
        ],
        if (c != null) ...[
          const Divider(height: AppSpacing.xl, color: AppColors.gray200),
          PaymentMethodDetails(choice: c, details: details),
          AppSpacing.verticalSpace16,
          if (c.method.requiresReceipt) ...[
            UploadAreaWidget(
              selectedFiles: current.selectedFiles,
              isUploading: isUploading,
              uploadProgress: uploadProgress,
              onPickFile: () => context.read<PaymentCubit>().pickFile(),
              onRemoveFile: (i) => context.read<PaymentCubit>().removeFile(i),
            ),
            AppSpacing.verticalSpace16,
            if (current.selectedFiles.isNotEmpty) ...[
              PaymentSubmitButton(
                isUploading: isUploading,
                uploadSuccess: false,
                canSubmit: !isUploading,
                onPressed: onSubmit,
              ),
              AppSpacing.verticalSpace12,
            ],
          ] else ...[
            PrimaryButton(
              key: const Key('payment_confirm_cash'),
              text: l.translate('payment_confirm_cash'),
              icon: Icons.check,
              isLoading: isUploading,
              onPressed: isUploading ? null : onSubmit,
            ),
            AppSpacing.verticalSpace12,
          ],
          PaymentWhatsappButton(
            number: whatsapp,
            event: eventLabel,
            amount: amount,
            methodLabel: c.label(l),
          ),
        ],
        AppSpacing.verticalSpace8,
        TextButton(
          onPressed: onSkip,
          child: Text(
            l.translate('payment_skip'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        AppSpacing.verticalSpace32,
      ],
    );
  }
}

class _AmountLine extends StatelessWidget {
  final double? amount;

  const _AmountLine({required this.amount});

  @override
  Widget build(BuildContext context) {
    final a = amount;
    if (a == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
      child: Text(
        '${l.translate('payment_amount_label')}: ${formatPaymentAmount(a)} ${l.translate('currency_ils')}',
        key: const Key('payment_amount'),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
      ),
    );
  }
}
