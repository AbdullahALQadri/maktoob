import 'package:flutter/material.dart';

import '../../../../core/design/window_size.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';

/// The home screen's shape while it loads: banner, numbers, two cards.
class HomeLoading extends StatelessWidget {
  const HomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.fromSTEB(gutter, 8, gutter, 24),
      children: [
        const SkeletonBox(height: 300, borderRadius: 20),
        const SizedBox(height: 22),
        const SkeletonBox(height: 140, borderRadius: 12),
        const SizedBox(height: 26),
        const SkeletonBox(width: 120, height: 20),
        const SizedBox(height: 14),
        Row(
          children: const [
            Expanded(child: SkeletonBox(height: 260, borderRadius: 14)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 260, borderRadius: 14)),
          ],
        ),
      ],
    );
  }
}
