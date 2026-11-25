import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/utils/app_colors.dart';
import '../cubit/invitation_state.dart';

/// The portal's six steps as numbered circles. A phone names only the step
/// it is on; wider windows name every step. Finished steps can be tapped.
class WizardStepBar extends StatelessWidget {
  const WizardStepBar({super.key, required this.current, this.onStepTap});

  final InvitationStep current;
  final ValueChanged<InvitationStep>? onStepTap;

  /// The five screens, then sending (the event page).
  static const stepKeys = ['details', 'guests', 'design', 'settings', 'checkout', 'send'];

  @override
  Widget build(BuildContext context) {
    final wide = context.windowSize.atLeastMedium;
    final position = context.tr('home_step_of', {'current': current.index + 1, 'total': stepKeys.length});
    final name = context.tr('home_step_${current.key}');

    return Semantics(
      container: true,
      label: '$position: $name',
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          border: Border(bottom: BorderSide(color: context.borderColor)),
        ),
        padding: EdgeInsetsDirectional.fromSTEB(context.pageGutter, 12, context.pageGutter, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < stepKeys.length; i++)
                  Expanded(
                    child: _Step(
                      index: i,
                      current: current.index,
                      label: wide ? context.tr('home_step_${stepKeys[i]}') : null,
                      onTap: i < current.index && onStepTap != null
                          ? () => onStepTap!(InvitationStep.values[i])
                          : null,
                    ),
                  ),
              ],
            ),
            if (!wide) ...[
              const SizedBox(height: 10),
              ExcludeSemantics(
                child: Text.rich(
                  TextSpan(
                    text: '$position: ',
                    style: TextStyle(fontSize: 13, color: context.textSecondary),
                    children: [
                      TextSpan(
                        text: name,
                        style: TextStyle(fontWeight: FontWeight.w800, color: context.textPrimary),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.current, required this.label, required this.onTap});

  final int index;
  final int current;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;
    final last = index == WizardStepBar.stepKeys.length - 1;
    Color line(bool reached) => reached ? AppColors.primaryColor : context.borderColor;

    final circle = Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? context.primaryWash : (active ? AppColors.primaryColor : AppColors.transparent),
        border: done || active ? null : Border.all(color: context.borderColor, width: 1.5),
      ),
      child: done
          ? Icon(Icons.check_rounded, size: 16, color: context.primaryText)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: active ? AppColors.white : context.textSecondary,
              ),
            ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Container(height: 2, color: index == 0 ? AppColors.transparent : line(done || active))),
              circle,
              Expanded(child: Container(height: 2, color: last ? AppColors.transparent : line(done))),
            ],
          ),
          if (label != null) ...[
            const SizedBox(height: 6),
            Text(
              label!,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                color: active ? context.textPrimary : context.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
