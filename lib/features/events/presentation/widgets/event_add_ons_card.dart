import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/event_add_ons_entity.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/event_add_ons/event_add_ons_cubit.dart';
import '../cubit/event_add_ons/event_add_ons_state.dart';

/// "Extra services" on a paid (active) event. The host asks for a service,
/// the team confirms it is available on the event date, then the host pays
/// ONLY that service's price — never the package again.
class EventAddOnsCard extends StatelessWidget {
  final EventEntity event;

  const EventAddOnsCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(event.id);
    if (id == null) return const SizedBox.shrink();
    return BlocProvider(
      create: (_) => sl<EventAddOnsCubit>()..load(id),
      child: _AddOnsBody(event: event, eventId: id),
    );
  }
}

class _AddOnsBody extends StatelessWidget {
  final EventEntity event;
  final int eventId;

  const _AddOnsBody({required this.event, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocConsumer<EventAddOnsCubit, EventAddOnsState>(
      listenWhen: (_, s) => s is EventAddOnsLoaded && s.notice != null,
      listener: (context, s) {
        final notice = (s as EventAddOnsLoaded).notice!;
        final translated = t.translate(notice);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translated == notice || translated.isEmpty ? notice : translated)),
        );
      },
      builder: (context, state) {
        if (state is! EventAddOnsLoaded) return const SizedBox.shrink();
        final addOns = state.addOns;
        if (!addOns.canRequest && addOns.services.isEmpty) return const SizedBox.shrink();
        final isAr = Localizations.localeOf(context).languageCode == 'ar';

        return Container(
          key: const Key('event_add_ons_card'),
          width: double.infinity,
          margin: const EdgeInsetsDirectional.only(top: AppSpacing.md),
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppSpacing.borderRadiusLg,
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.translate('add_ons_title'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary),
              ),
              AppSpacing.verticalSpace4,
              Text(
                t.translate('add_ons_paid_note'),
                style: TextStyle(fontSize: 13, height: 1.5, color: context.textSecondary),
              ),
              AppSpacing.verticalSpace12,
              for (final s in addOns.services) _ServiceRow(service: s, isAr: isAr, busy: state.busy),
              if (addOns.canPay && event.role.canOwn) ...[
                AppSpacing.verticalSpace8,
                PrimaryButton(
                  key: const Key('add_ons_pay'),
                  text: t.translate('add_ons_pay').replaceAll('{amount}', addOns.amountDue.toStringAsFixed(2)),
                  icon: Icons.payments_outlined,
                  onPressed: () => _openPayment(context, addOns.amountDue),
                ),
              ] else if (addOns.paymentUnderReview) ...[
                AppSpacing.verticalSpace8,
                Row(children: [
                  const Icon(Icons.hourglass_top_rounded, color: AppColors.primaryColor, size: AppSpacing.iconMd),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(t.translate('event_payment_under_review'), style: TextStyle(color: context.textPrimary))),
                ]),
              ],
              if (addOns.canRequest && addOns.available.isNotEmpty) ...[
                AppSpacing.verticalSpace8,
                OutlinedButton.icon(
                  key: const Key('add_ons_request'),
                  onPressed: state.busy ? null : () => _pickService(context, addOns.available, isAr),
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(t.translate('add_ons_request')),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openPayment(BuildContext context, double amount) {
    final nav = Navigator.of(context);
    final cubit = context.read<EventAddOnsCubit>();
    nav.pushNamed(Routes.payment, arguments: {
      'eventId': event.id,
      'amount': amount,
      'eventTitle': event.name,
      'endpoint': Endpoints.eventAddOnsPay(eventId),
      'onComplete': () => nav.pop(),
    }).then((_) => cubit.load(eventId));
  }

  Future<void> _pickService(BuildContext context, List<OfferedServiceEntity> offered, bool isAr) async {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<EventAddOnsCubit>();
    final notes = TextEditingController();
    final picked = await showModalBottomSheet<OfferedServiceEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (sheet) => Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md + MediaQuery.of(sheet).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(sheet).size.height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.translate('add_ons_request'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: sheet.textPrimary)),
              AppSpacing.verticalSpace4,
              Text(t.translate('add_ons_review_note'), style: TextStyle(fontSize: 13, color: sheet.textSecondary)),
              AppSpacing.verticalSpace12,
              TextField(
                controller: notes,
                maxLength: 1000,
                decoration: InputDecoration(hintText: t.translate('add_ons_notes_hint')),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final s in offered)
                      ListTile(
                        key: Key('add_on_offer_${s.id}'),
                        contentPadding: EdgeInsetsDirectional.zero,
                        title: Text(s.name(isAr), style: TextStyle(color: sheet.textPrimary, fontWeight: FontWeight.w600)),
                        subtitle: s.description(isAr) == null
                            ? null
                            : Text(s.description(isAr)!, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: Text('${s.price.toStringAsFixed(2)} ₪',
                            style: TextStyle(color: sheet.primaryText, fontWeight: FontWeight.w700)),
                        onTap: () => Navigator.of(sheet).pop(s),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final note = notes.text;
    notes.dispose();
    if (picked != null) await cubit.request(picked.id, notes: note);
  }
}

class _ServiceRow extends StatelessWidget {
  final EventAddOnEntity service;
  final bool isAr;
  final bool busy;

  const _ServiceRow({required this.service, required this.isAr, required this.busy});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final (bg, fg) = switch (service.status) {
      AddOnStatus.requested => (AppColors.amber50, AppColors.amber700),
      AddOnStatus.awaitingPayment => (AppColors.blue50, AppColors.primaryDark),
      AddOnStatus.confirmed || AddOnStatus.completed || AddOnStatus.pending => (AppColors.green50, AppColors.green600),
      AddOnStatus.declined => (AppColors.red100, AppColors.red500),
      _ => (AppColors.gray100, AppColors.gray600),
    };
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.quantity > 1 ? '${service.name(isAr)} × ${service.quantity}' : service.name(isAr),
                  style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary),
                ),
                AppSpacing.verticalSpace4,
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(color: bg, borderRadius: AppSpacing.borderRadiusSm),
                  child: Text(t.translate(service.status.labelKey), style: TextStyle(fontSize: 12, color: fg)),
                ),
                if (service.decisionNote != null) ...[
                  AppSpacing.verticalSpace4,
                  Text(service.decisionNote!, style: TextStyle(fontSize: 12, color: context.textSecondary)),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${service.totalPrice.toStringAsFixed(2)} ₪',
                  style: TextStyle(fontWeight: FontWeight.w700, color: context.textPrimary)),
              if (service.canWithdraw)
                TextButton(
                  key: Key('add_on_withdraw_${service.serviceId}'),
                  onPressed: busy ? null : () => context.read<EventAddOnsCubit>().withdraw(service.serviceId),
                  child: Text(t.translate('add_ons_withdraw'), style: const TextStyle(color: AppColors.red500)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
