import 'package:flutter/material.dart';

import '../../domain/entities/stat_entity.dart';
import 'stat_card_widget.dart';

/// 2-column stats grid. Fixed-height tiles (128pt) — the tile owns its
/// own height, so the grid uses a wide-enough aspect ratio to let
/// SliverGrid build them at the configured size without overflow.
class HomeStatsGrid extends StatelessWidget {
  final List<StatEntity> stats;

  const HomeStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tileWidth = (screenWidth - 20 * 2 - 16) / 2;
    final aspect = tileWidth / 128;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspect,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) =>
            StatCardWidget(stat: stats[index], index: index),
      ),
    );
  }
}
