import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';

/// Before the first event: the three steps from idea to guests' phones.
class HomeFirstVisit extends StatelessWidget {
  const HomeFirstVisit({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('home_intro_title'),
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.textPrimary),
          ),
          for (var step = 1; step <= 3; step++) ...[const SizedBox(height: 14), _Step(number: step)],
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: context.primaryWash, shape: BoxShape.circle),
          child: Text(
            '$number',
            style: TextStyle(fontWeight: FontWeight.w800, color: context.primaryText),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('home_intro_${number}_title'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                context.tr('home_intro_${number}_text'),
                style: TextStyle(fontSize: 14, color: context.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
