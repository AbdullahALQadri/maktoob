import 'package:flutter/material.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/design/window_size.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../invitation/presentation/screens/invitation_wizard_screen.dart';
import '../../../domain/entities/event_card.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/event_follow_up.dart';
import '../pending_payment_banner.dart';
import 'event_page_parts.dart';
import 'event_summary_card.dart';

/// A draft or an event awaiting payment: what is done, what is left, and one
/// button for the next step (the portal's six steps).
class EventSetupView extends StatelessWidget {
  const EventSetupView({
    super.key,
    required this.event,
    required this.progress,
    required this.paymentUnderReview,
    required this.onPaid,
  });

  final EventEntity event;
  final EventProgress? progress;
  final bool paymentUnderReview;
  final VoidCallback onPaid;

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    final steps = progress?.steps ?? const <SetupStep>[];
    final next = progress?.nextAction;
    final wizard = event.status == EventStatus.draft && event.role.canManage && next != NextAction.trackPayment;
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(gutter, 8, gutter, 32),
      children: [
        EventSummaryCard(event: event),
        if (event.role != EventRole.owner) ...[const SizedBox(height: 12), EventRoleBanner(role: event.role)],
        if (event.isPendingPayment && event.role.canOwn) ...[
          const SizedBox(height: 12),
          PendingPaymentBanner(event: event, underReview: paymentUnderReview, onPaid: onPaid),
        ],
        const SizedBox(height: 16),
        EventPageCard(
          title: context.tr('event_setup_left'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < steps.length; i++) _StepRow(number: i + 1, step: steps[i], divider: i > 0),
              if (wizard) ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    final id = int.tryParse(event.id);
                    if (id != null) context.openInvitationWizardWithDraft(id);
                  },
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: Text(next == null ? context.tr('event_setup_continue') : context.tr(next.labelKey)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.step, required this.divider});

  final int number;
  final SetupStep step;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final mark = step.done
        ? Icon(Icons.check_rounded, size: 18, color: context.primaryText)
        : Text(
            '$number',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: step.current ? AppColors.white : context.textSecondary,
            ),
          );
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        border: divider ? Border(top: BorderSide(color: context.dividerColor)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step.done ? context.primaryWash : (step.current ? AppColors.primaryColor : AppColors.transparent),
              border: step.done || step.current ? null : Border.all(color: context.borderColor, width: 1.5),
            ),
            child: mark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr('home_step_${step.key}'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: step.current ? FontWeight.w800 : FontWeight.w500,
                color: step.done ? context.textSecondary : context.textPrimary,
              ),
            ),
          ),
          if (step.done)
            Text(context.tr('event_setup_done'), style: TextStyle(fontSize: 12, color: context.textSecondary)),
        ],
      ),
    );
  }
}
