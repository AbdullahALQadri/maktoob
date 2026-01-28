import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entities/stat_entity.dart';
import 'stat_card_widget.dart';

/// Grid widget displaying home statistics.
class HomeStatsGrid extends StatelessWidget {
  final List<StatEntity> stats;

  const HomeStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: context.dynamicWidth(0.029),
          mainAxisSpacing: context.dynamicWidth(0.029),
          childAspectRatio: 1.1,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          return StatCardWidget(stat: stats[index], index: index);
        },
      ),
    );
  }
}
