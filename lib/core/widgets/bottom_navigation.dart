import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/media_query_values.dart';

/// A custom bottom navigation bar widget for the Maktoob app.
///
/// Features:
/// - 4 navigation tabs: Venue, Create (FAB style), Scanner, Settings
/// - Gradient purple-pink color for selected items
/// - Floating center button with gradient background
/// - Smooth animations for selection changes
/// - White background with rounded top corners and top shadow
class BottomNavigation extends StatefulWidget {
  /// The index of the currently selected tab (0-3)
  final int currentIndex;

  /// Callback function when a tab is tapped
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
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
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.15).animate(
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

  /// Creates the gradient used for selected items and the Create button
  LinearGradient get _gradient => LinearGradient(
        colors: [AppColors.purple600, AppColors.pink600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.dynamicWidth(0.06)),
          topRight: Radius.circular(context.dynamicWidth(0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.02),
            vertical: context.dynamicHeight(0.01),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'الأماكن',
                outlinedIcon: Icons.location_on_outlined,
                filledIcon: Icons.location_on,
              ),
              _buildCreateButton(),
              _buildNavItem(
                index: 2,
                label: 'الماسح',
                outlinedIcon: Icons.qr_code_scanner_outlined,
                filledIcon: Icons.qr_code_scanner,
              ),
              _buildNavItem(
                index: 3,
                label: 'الإعدادات',
                outlinedIcon: Icons.settings_outlined,
                filledIcon: Icons.settings,
              ),
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

    return Expanded(
      child: InkWell(
        onTap: () => widget.onTap(index),
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        splashColor: AppColors.purple600.withValues(alpha: 0.1),
        highlightColor: AppColors.purple600.withValues(alpha: 0.05),
        child: AnimatedBuilder(
          animation: _scaleAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.01)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGradientIcon(
                      icon: isSelected ? filledIcon : outlinedIcon,
                      isSelected: isSelected,
                    ),
                    SizedBox(height: context.dynamicHeight(0.005)),
                    _buildGradientText(
                      text: label,
                      isSelected: isSelected,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds an icon with gradient color when selected
  Widget _buildGradientIcon({
    required IconData icon,
    required bool isSelected,
  }) {
    if (isSelected) {
      return ShaderMask(
        shaderCallback: (bounds) => _gradient.createShader(bounds),
        child: Icon(
          icon,
          size: context.dynamicWidth(0.065),
          color: AppColors.white,
        ),
      );
    }
    return Icon(
      icon,
      size: context.dynamicWidth(0.065),
      color: AppColors.gray400,
    );
  }

  /// Builds text with gradient color when selected
  Widget _buildGradientText({
    required String text,
    required bool isSelected,
  }) {
    if (isSelected) {
      return ShaderMask(
        shaderCallback: (bounds) => _gradient.createShader(bounds),
        child: Text(
          text,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.03),
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      );
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.03),
        fontWeight: FontWeight.w500,
        color: AppColors.gray400,
      ),
    );
  }

  /// Builds the center Create button with floating FAB style
  Widget _buildCreateButton() {
    final isSelected = widget.currentIndex == 1;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimations[1],
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimations[1].value,
                  child: Container(
                    width: context.dynamicWidth(0.14),
                    height: context.dynamicWidth(0.14),
                    decoration: BoxDecoration(
                      gradient: _gradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple600.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: AppColors.pink600.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: Tween<double>(begin: 0.75, end: 1.0)
                              .animate(animation),
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isSelected
                            ? Icons.add_circle
                            : Icons.add_circle_outline,
                        key: ValueKey<bool>(isSelected),
                        size: context.dynamicWidth(0.08),
                        color: AppColors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: context.dynamicHeight(0.005)),
            _buildGradientText(
              text: 'إضافة',
              isSelected: isSelected,
            ),
          ],
        ),
      ),
    );
  }
}
