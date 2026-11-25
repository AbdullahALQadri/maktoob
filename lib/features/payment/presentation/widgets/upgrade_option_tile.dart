import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../domain/entities/upgrade_options.dart';

/// A bigger package: its name, how many invitations it holds, and what is
/// left to pay to move to it.
class UpgradeOptionTile extends StatelessWidget {
  const UpgradeOptionTile({super.key, required this.package, required this.selected, required this.onTap});

  final UpgradePackage package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final perInvitation = package.pricePerInvitation;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: selected ? context.primaryWash : context.cardBg,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: selected ? AppColors.primaryColor : context.borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 22,
                color: selected ? AppColors.primaryColor : context.borderColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name(arabic: context.languageCode == 'ar'),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        context.tr('upgrade_invitations', {'count': package.invitations}),
                        if (perInvitation != null)
                          context.tr('upgrade_per_invitation', {'price': perInvitation.toStringAsFixed(2)}),
                      ].join(' · '),
                      style: TextStyle(fontSize: 12.5, height: 1.45, color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              UpgradeDifference(total: package.quote.total, highlighted: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Difference" over the amount still to pay.
class UpgradeDifference extends StatelessWidget {
  const UpgradeDifference({super.key, required this.total, this.highlighted = false});

  final double total;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr('upgrade_difference'), style: TextStyle(fontSize: 12, color: context.textSecondary)),
        Text(
          '${total.toStringAsFixed(2)} ${context.tr('currency_ils')}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: highlighted ? context.primaryText : context.textPrimary,
          ),
        ),
      ],
    );
  }
}
