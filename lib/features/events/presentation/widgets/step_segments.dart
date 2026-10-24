import 'package:flutter/material.dart';

/// The six setup steps as a row of segments: done, current, still to come.
class StepSegments extends StatelessWidget {
  const StepSegments({
    super.key,
    required this.current,
    required this.total,
    required this.done,
    required this.active,
    required this.rest,
    this.height = 5,
  });

  /// 1-based number of the step the event is on.
  final int current;
  final int total;
  final Color done;
  final Color active;
  final Color rest;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1) const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: i < current ? done : (i == current ? active : rest),
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
