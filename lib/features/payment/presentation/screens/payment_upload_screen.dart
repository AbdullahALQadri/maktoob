import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../cubit/pay_currency_cubit.dart';
import '../cubit/pay_currency_state.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/pay_currency_picker.dart';
import '../widgets/payment_content.dart';
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
    // Extras bought after payment (their own endpoint) are paid in shekels.
    if (widget.endpoint == null) context.read<PayCurrencyCubit>().load(widget.eventId ?? '');
  }

  /// Another currency may have an account of its own: show that one.
  void _onCurrency(String code) {
    final currencies = context.read<PayCurrencyCubit>()..select(code);
    context.read<PaymentCubit>().loadBankDetails(currency: currencies.state.currencyToSend);
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
          currency: context.read<PayCurrencyCubit>().state.currencyToSend,
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
                    child: BlocBuilder<PayCurrencyCubit, PayCurrencyState>(
                      builder: (context, pay) => BlocBuilder<PaymentCubit, PaymentState>(
                        builder: (context, state) {
                          final choices = PaymentChoice.available(state.bankDetails);
                          final choice = choices.contains(_choice) ? _choice : null;
                          final busy = state is Uploading || state is UploadSuccess;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (pay.hasChoice && state is! UploadSuccess)
                                PayCurrencyPicker(
                                  currencies: pay.currencies!,
                                  selectedCode: pay.selectedCode,
                                  onChanged: busy ? null : _onCurrency,
                                ),
                              PaymentContent(
                                state: state,
                                choices: choices,
                                choice: choice,
                                amount: widget.amount ?? pay.currencies?.ilsTotal,
                                currency: pay.selected,
                                eventLabel: (widget.eventId?.isNotEmpty ?? false)
                                    ? widget.eventId!
                                    : (widget.eventTitle ?? ''),
                                onChoice: (c) => setState(() => _choice = c),
                                onSubmit: () => _handleSubmit(state),
                                onSkip: widget.onComplete,
                              ),
                            ],
                          );
                        },
                      ),
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
