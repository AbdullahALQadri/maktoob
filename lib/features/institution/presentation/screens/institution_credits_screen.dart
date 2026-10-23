import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/institution_cubit.dart';
import '../cubit/institution_state.dart';
import '../widgets/institution_widgets.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

String _date(DateTime d) =>
    '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

/// Owner only: prepaid invitation credits balance + ledger.
class InstitutionCreditsScreen extends StatelessWidget {
  const InstitutionCreditsScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<InstitutionCreditsCubit>()..load(),
          child: const InstitutionCreditsScreen(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: MaktoobAppBar(title: t.translate('institution_credits')),
      body: SafeArea(
        child: BlocBuilder<InstitutionCreditsCubit, InstitutionCreditsState>(
          builder: (context, state) {
            if (state is InstitutionCreditsError) return Center(child: Text(state.message));
            if (state is! InstitutionCreditsLoaded) {
              return const Center(child: MkSpinner());
            }
            final credits = state.credits;
            return RefreshIndicator(
              onRefresh: () => context.read<InstitutionCreditsCubit>().load(),
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                children: [
                  OutlinedCard(
                    child: Column(
                      children: [
                        Text(t.translate('institution_credits_balance'),
                            style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${credits.balance}',
                          key: const Key('credits_balance'),
                          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primaryColor),
                        ),
                        Text(t.translate('institution_credits_unit'),
                            style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary)),
                        if (credits.discountPercent > 0) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${t.translate('institution_discount')}: ${credits.discountPercent.toStringAsFixed(0)}%',
                            style: AppTextStyles.labelMedium.copyWith(color: context.textPrimary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SectionTitle(t.translate('institution_credits_ledger')),
                  if (credits.transactions.isEmpty)
                    Text(t.translate('institution_credits_empty'),
                        style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary)),
                  for (final tx in credits.transactions)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                      child: OutlinedCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.translate('institution_credit_type_${tx.type}'),
                                      style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
                                  if ((tx.note ?? '').isNotEmpty)
                                    Text(tx.note!,
                                        style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary)),
                                  if (tx.createdAt != null)
                                    Text(_date(tx.createdAt!.toLocal()),
                                        style: AppTextStyles.caption.copyWith(color: context.textSecondary)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    tx.amount > 0 ? '+${tx.amount}' : '${tx.amount}',
                                    style: AppTextStyles.titleSmall.copyWith(
                                      color: tx.amount >= 0 ? AppColors.green600 : AppColors.red500,
                                    ),
                                  ),
                                ),
                                Text('${t.translate('institution_credits_after')} ${tx.balanceAfter}',
                                    style: AppTextStyles.caption.copyWith(color: context.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
