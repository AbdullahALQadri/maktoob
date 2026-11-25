import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../injection_container.dart' as di;
import '../../../events/presentation/screens/event_details_screen.dart';
import '../../domain/entities/my_payments.dart';
import '../cubit/my_payments_cubit.dart';
import '../cubit/my_payments_state.dart';
import '../widgets/my_payments_tiles.dart';

/// "مدفوعاتي" (My account → My payments), the portal's page in the app:
///  1. what is still due, with a way to pay (bank / wallet + receipt);
///  2. receipts the host sent that the team is reviewing or refused;
///  3. every confirmed payment, however it was paid (a receipt the team
///     approved, or cash / a transfer staff recorded), with its receipt.
class MyPaymentsScreen extends StatelessWidget {
  const MyPaymentsScreen({super.key});

  /// The screen with its own cubit, already loading.
  static Widget provided() => BlocProvider(
    create: (_) => di.sl<MyPaymentsCubit>()..load(),
    child: const MyPaymentsScreen(),
  );

  static Route<void> route() => MaterialPageRoute(builder: (_) => provided());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(title: Text(context.tr('my_payments_title'))),
      body: BlocBuilder<MyPaymentsCubit, MyPaymentsState>(
        builder: (context, state) {
          if (state is MyPaymentsError) {
            return _Message(
              icon: Icons.cloud_off_outlined,
              text: context.tr('my_payments_error'),
              action: TextButton(
                onPressed: () => context.read<MyPaymentsCubit>().load(),
                child: Text(context.tr('common_retry')),
              ),
            );
          }
          if (state is! MyPaymentsLoaded) return const Center(child: MkSpinner());
          return RefreshIndicator(
            onRefresh: () => context.read<MyPaymentsCubit>().load(),
            child: _List(payments: state.payments),
          );
        },
      ),
    );
  }
}

class _List extends StatelessWidget {
  final MyPayments payments;

  const _List({required this.payments});

  void _openEvent(BuildContext context, String? eventId) {
    if (eventId == null || eventId.isEmpty) return;
    final cubit = context.read<MyPaymentsCubit>();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
          builder: (page) => EventDetailsScreen(eventId: eventId, onBack: () => Navigator.of(page).pop()),
        ))
        // Back from the event: a receipt may have been sent meanwhile.
        .then((_) => cubit.load());
  }

  Future<void> _openReceipt(BuildContext context, PaymentReceipt receipt) async {
    final url = await context.read<MyPaymentsCubit>().freshReceiptUrl(receipt.id);
    if (url == null) {
      if (context.mounted) AppSnackBar.showError(context, message: context.tr('my_payments_receipt_unavailable'));
      return;
    }
    await LegalLinks.open(url);
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.sm);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.symmetric(horizontal: context.pageGutter, vertical: AppSpacing.md),
      children: [
        PaidTotalCard(total: payments.paidTotal),
        if (payments.due.isNotEmpty) ...[
          MyPaymentsSectionTitle(context.tr('my_payments_due')),
          for (final due in payments.due) ...[
            PaymentDueTile(due: due, onPay: () => _openEvent(context, due.eventId)),
            gap,
          ],
        ],
        if (payments.sent.isNotEmpty) ...[
          MyPaymentsSectionTitle(context.tr('my_payments_sent')),
          for (final sent in payments.sent) ...[
            SentReceiptTile(
              sent: sent,
              // A refused receipt is fixed and resent from the event's page.
              onTap: sent.isRejected ? () => _openEvent(context, sent.eventId) : null,
            ),
            gap,
          ],
        ],
        MyPaymentsSectionTitle(context.tr('my_payments_receipts')),
        if (payments.receipts.isEmpty)
          _Message(icon: Icons.receipt_long_outlined, text: context.tr('my_payments_empty'))
        else
          for (final receipt in payments.receipts) ...[
            PaymentReceiptTile(receipt: receipt, onOpen: () => _openReceipt(context, receipt)),
            gap,
          ],
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;

  const _Message({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: context.textSecondary),
        AppSpacing.verticalSpace12,
        Text(text, textAlign: TextAlign.center, style: TextStyle(color: context.textSecondary, height: 1.5)),
        ?action,
      ],
    ),
  );
}
