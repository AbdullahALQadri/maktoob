import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/media_query_values.dart';

/// Model class for navigation items used in AdaptiveBottomNavigationBar.
class AdaptiveNavItem {
  /// The label displayed below the icon
  final String label;

  /// The icon shown when the item is not selected
  final IconData icon;

  /// The icon shown when the item is selected
  final IconData activeIcon;

  const AdaptiveNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// A platform-adaptive bottom navigation bar widget.
///
/// Uses:
/// - Material [BottomNavigationBar] on Android
/// - [CupertinoTabBar] on iOS
///
/// Provides consistent API across platforms while respecting platform conventions.
class AdaptiveBottomNavigationBar extends StatelessWidget {
  /// The index of the currently selected tab
  final int currentIndex;

  /// Callback when a tab is tapped
  final ValueChanged<int> onTap;

  /// List of navigation items to display
  final List<AdaptiveNavItem> items;

  /// Optional callback when add button is tapped (shown as FAB on Android, in nav bar on iOS)
  final VoidCallback? onAddTap;

  /// Whether to show the add button
  final bool showAddButton;

  /// Background color override (defaults to platform-specific colors)
  final Color? backgroundColor;

  /// Selected item color override
  final Color? selectedItemColor;

  /// Unselected item color override
  final Color? unselectedItemColor;

  const AdaptiveBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.onAddTap,
    this.showAddButton = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  /// Check if the current platform is iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if the current platform is Android
  static bool get isAndroid => Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return _buildCupertinoNavBar(context);
    } else {
      return _buildMaterialNavBar(context);
    }
  }

  /// Builds the Material BottomNavigationBar for Android
  Widget _buildMaterialNavBar(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.tertiaryColor;
    final selectedColor = selectedItemColor ?? Colors.white;
    final unselectedColor = unselectedItemColor ?? Colors.white70;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.015),
        ),
        child: Row(
          children: [
            // Main navigation bar with blur effect
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.08)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: context.dynamicHeight(0.08),
                    decoration: BoxDecoration(
                      color: bgColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.08)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = currentIndex == index;

                        return _buildNavItem(
                          context: context,
                          index: index,
                          item: item,
                          isSelected: isSelected,
                          selectedColor: selectedColor,
                          unselectedColor: unselectedColor,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            if (showAddButton && onAddTap != null) ...[
              SizedBox(width: context.dynamicWidth(0.03)),
              _buildMaterialAddButton(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a single navigation item
  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required AdaptiveNavItem item,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final navBarHeight = context.dynamicHeight(0.08);
    final iconSize = navBarHeight * 0.35;
    final fontSize = navBarHeight * 0.18;
    final spacing = navBarHeight * 0.05;
    final horizontalPadding = context.dynamicWidth(0.035);
    final verticalPadding = navBarHeight * 0.1;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
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
              isSelected ? item.activeIcon : item.icon,
              size: iconSize,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            SizedBox(height: spacing),
            Text(
              item.label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Material Add button with blur effect
  Widget _buildMaterialAddButton(BuildContext context) {
    final buttonSize = context.dynamicHeight(0.08);
    final iconSize = buttonSize * 0.45;

    return GestureDetector(
      onTap: onAddTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              size: iconSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the CupertinoTabBar for iOS with blur effect
  Widget _buildCupertinoNavBar(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.tertiaryColor;
    final selectedColor = selectedItemColor ?? CupertinoColors.white;
    final unselectedColor = unselectedItemColor ?? CupertinoColors.white.withValues(alpha: 0.7);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.015),
        ),
        child: Row(
          children: [
            // Main navigation bar with blur effect
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.08)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: context.dynamicHeight(0.08),
                    decoration: BoxDecoration(
                      color: bgColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.08)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = currentIndex == index;

                        return _buildCupertinoNavItem(
                          context: context,
                          index: index,
                          item: item,
                          isSelected: isSelected,
                          selectedColor: selectedColor,
                          unselectedColor: unselectedColor,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            if (showAddButton && onAddTap != null) ...[
              SizedBox(width: context.dynamicWidth(0.03)),
              _buildCupertinoAddButton(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a single Cupertino navigation item
  Widget _buildCupertinoNavItem({
    required BuildContext context,
    required int index,
    required AdaptiveNavItem item,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final navBarHeight = context.dynamicHeight(0.08);
    final iconSize = navBarHeight * 0.35;
    final fontSize = navBarHeight * 0.18;
    final spacing = navBarHeight * 0.05;
    final horizontalPadding = context.dynamicWidth(0.035);
    final verticalPadding = navBarHeight * 0.1;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
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
              isSelected ? item.activeIcon : item.icon,
              size: iconSize,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            SizedBox(height: spacing),
            Text(
              item.label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Cupertino Add button with blur effect
  Widget _buildCupertinoAddButton(BuildContext context) {
    final buttonSize = context.dynamicHeight(0.08);
    final iconSize = buttonSize * 0.45;

    return GestureDetector(
      onTap: onAddTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.add,
              size: iconSize,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// A wrapper widget that provides a Scaffold with adaptive bottom navigation.
///
/// Use this when you need a complete scaffold with platform-adaptive navigation.
class AdaptiveNavigationScaffold extends StatelessWidget {
  /// The current body widget to display
  final Widget body;

  /// The index of the currently selected tab
  final int currentIndex;

  /// Callback when a tab is tapped
  final ValueChanged<int> onTap;

  /// List of navigation items
  final List<AdaptiveNavItem> items;

  /// Optional callback when add button is tapped
  final VoidCallback? onAddTap;

  /// Whether to show the add button
  final bool showAddButton;

  /// Background color for the scaffold
  final Color? backgroundColor;

  /// Whether to extend the body behind the bottom navigation bar
  final bool extendBody;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.onAddTap,
    this.showAddButton = true,
    this.backgroundColor,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    if (AdaptiveBottomNavigationBar.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: backgroundColor ?? CupertinoColors.systemGroupedBackground,
        child: Column(
          children: [
            Expanded(child: body),
            AdaptiveBottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              items: items,
              onAddTap: onAddTap,
              showAddButton: showAddButton,
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: backgroundColor ?? AppColors.gray100,
        extendBody: extendBody,
        body: body,
        bottomNavigationBar: AdaptiveBottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
          onAddTap: onAddTap,
          showAddButton: showAddButton,
        ),
      );
    }
  }
}
