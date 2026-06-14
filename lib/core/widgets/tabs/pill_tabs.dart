import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Segmented pill-style tab strip. White selected pill on a grey track.
///
/// Drives an external [TabController] so the host page can pair it with a
/// regular [TabBarView]. Listens to controller changes and rebuilds itself
/// when the active index moves.
class PillTabs extends StatefulWidget {
  final TabController controller;
  final List<String> tabs;
  final EdgeInsetsGeometry padding;

  const PillTabs({
    super.key,
    required this.controller,
    required this.tabs,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  State<PillTabs> createState() => _PillTabsState();
}

class _PillTabsState extends State<PillTabs> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTab);
  }

  void _onTab() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: widget.padding,
      child: Row(
        children: List.generate(widget.tabs.length, (index) {
          final isActive = widget.controller.index == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.controller.animateTo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  widget.tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isActive ? AppColors.primaryColor : AppColors.gray500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
