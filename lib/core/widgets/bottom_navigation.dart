import 'dart:ui';

import 'package:flutter/material.dart';

import '../../config/locale/app_localizations.dart';
import '../utils/app_colors.dart';
import '../utils/media_query_values.dart';

/// A custom bottom navigation bar widget for the Maktoob app.
///
/// Features:
/// - Floating pill-shaped dark container with 3 tabs: Home, Scanner, Settings
/// - Separate circular "+" button on the right for adding events
/// - Smooth animations for selection changes
class BottomNavigation extends StatefulWidget {
  /// The index of the currently selected tab (0-2 for main tabs)
  final int currentIndex;

  /// Callback function when a tab is tapped
  final Function(int) onTap;

  /// Callback function when the add button is tapped
  final VoidCallback? onAddTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onAddTap,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      4, // 3 main tabs + 1 add button
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      );
    }).toList();

    // Start animation for initially selected tab
    if (widget.currentIndex >= 0 && widget.currentIndex < 4) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(BottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reverse animation for previously selected tab
      if (oldWidget.currentIndex >= 0 && oldWidget.currentIndex < 4) {
        _controllers[oldWidget.currentIndex].reverse();
      }
      // Forward animation for newly selected tab
      if (widget.currentIndex >= 0 && widget.currentIndex < 4) {
        _controllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isArabic = !(l?.isEnLocale ?? true);

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.04),
            vertical: context.dynamicHeight(0.015),
          ),
          child: Row(
            children: [
              // Main pill-shaped navigation container
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.08)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: context.dynamicHeight(0.08),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryColor.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(context.dynamicWidth(0.08)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(
                            index: 0,
                            label: isArabic ? 'الرئيسية' : 'Home',
                            outlinedIcon: Icons.grid_view_outlined,
                            filledIcon: Icons.grid_view_rounded,
                          ),
                          _buildNavItem(
                            index: 1,
                            label: isArabic ? 'الماسح' : 'Scanner',
                            outlinedIcon: Icons.crop_free_outlined,
                            filledIcon: Icons.crop_free_rounded,
                          ),
                          _buildNavItem(
                            index: 2,
                            label: isArabic ? 'الإعدادات' : 'Settings',
                            outlinedIcon: Icons.bookmark_border_outlined,
                            filledIcon: Icons.bookmark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.03)),
              // Separate circular add button
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a regular navigation item with icon and label
  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData outlinedIcon,
    required IconData filledIcon,
  }) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimations[index].value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.04),
                vertical: context.dynamicHeight(0.01),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.05)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? filledIcon : outlinedIcon,
                    size: context.dynamicWidth(0.055),
                    color: AppColors.white,
                  ),
                  SizedBox(height: context.dynamicHeight(0.005)),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.025),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the separate circular add button
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: widget.onAddTap ?? () => widget.onTap(3),
      child: AnimatedBuilder(
        animation: _scaleAnimations[3],
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimations[3].value,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: context.dynamicHeight(0.08),
                  height: context.dynamicHeight(0.08),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: context.dynamicWidth(0.07),
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
