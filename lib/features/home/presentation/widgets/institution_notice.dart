import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../institution/domain/entities/institution_entity.dart';

/// An institution not approved yet: how complete its file is and the way to
/// finish it. Events can be prepared meanwhile; they go live after approval.
class InstitutionNotice extends StatelessWidget {
  const InstitutionNotice({super.key, required this.status, required this.verification, required this.onComplete});

  final InstitutionStatus status;
  final InstitutionVerification verification;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final rejected = status == InstitutionStatus.rejected;
    final v = verification;
    final checks = [
      v.name,
      v.sector,
      v.legalDetails,
      v.registrationDocument,
      v.representativeIdentity,
      v.authorization,
      v.declaration,
      v.logo,
    ];
    final done = checks.where((c) => c).length;
    final tone = rejected ? AppColors.red500 : AppColors.amber700;

    return Container(
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: tone.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
                child: Icon(
                  rejected ? Icons.report_gmailerrorred_outlined : Icons.apartment_outlined,
                  size: 20,
                  color: tone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(rejected ? 'home_inst_rejected_title' : 'home_inst_pending_title'),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.tr(rejected ? 'home_inst_rejected_text' : 'home_inst_pending_text'),
                      style: TextStyle(fontSize: 14, color: context.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('home_inst_progress'),
                  style: TextStyle(fontSize: 13, color: context.textTertiary),
                ),
              ),
              Text(
                context.tr('home_card_of', {'done': done, 'total': checks.length}),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: done / checks.length,
              minHeight: 6,
              backgroundColor: context.chipBg,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onComplete,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
            child: Text(context.tr('home_inst_complete')),
          ),
        ],
      ),
    );
  }
}
