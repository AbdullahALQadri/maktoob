import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../cubit/upgrade_state.dart';
import 'upgrade_option_tile.dart';

/// "Custom package": the host types how many invitations they need and sees
/// what the difference costs.
class UpgradeCustomField extends StatefulWidget {
  const UpgradeCustomField({super.key, required this.state, required this.onCalculate});

  final UpgradeState state;
  final ValueChanged<int?> onCalculate;

  @override
  State<UpgradeCustomField> createState() => _UpgradeCustomFieldState();
}

class _UpgradeCustomFieldState extends State<UpgradeCustomField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    widget.onCalculate(int.tryParse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final quote = state.usesCustom ? state.customQuote : null;
    final error = state.customError;
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: quote != null ? context.primaryWash : context.cardBg,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: quote != null ? AppColors.primaryColor : context.borderColor,
          width: quote != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('upgrade_custom'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(context.tr('upgrade_custom_hint'), style: TextStyle(fontSize: 12.5, color: context.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('upgrade_custom_input'),
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _calculate(),
                  decoration: InputDecoration(hintText: context.tr('upgrade_custom_example'), isDense: true),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                key: const Key('upgrade_calculate'),
                onPressed: state.calculating ? null : _calculate,
                style: OutlinedButton.styleFrom(minimumSize: const Size(88, 48)),
                child: Text(context.tr('upgrade_calculate')),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              context.tr(error),
              key: const Key('upgrade_custom_error'),
              style: const TextStyle(fontSize: 13, color: AppColors.red500),
            ),
          ],
          if (quote != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr('upgrade_invitations', {'count': quote.targetLimit}),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary),
                  ),
                ),
                UpgradeDifference(total: quote.total, highlighted: true),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
