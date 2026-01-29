import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/responsive.dart';

/// A unified card widget with consistent styling.
///
/// This widget provides a standard card design with various styles
/// and configurations used throughout the app.
///
/// Example usage:
/// ```dart
/// AppCard(
///   child: Text('Card content'),
/// )
///
/// AppCard.outlined(
///   onTap: () => handleTap(),
///   child: ListTile(title: Text('Item')),
/// )
///
/// AppCard.elevated(
///   child: Column(children: [...]),
/// )
/// ```
class AppCard extends StatelessWidget {
  /// The content of the card.
  final Widget child;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when the card is long pressed.
  final VoidCallback? onLongPress;

  /// Background color.
  final Color? backgroundColor;

  /// Border color for outlined style.
  final Color? borderColor;

  /// Border width for outlined style.
  final double borderWidth;

  /// Border radius.
  final double? borderRadius;

  /// Padding inside the card.
  final EdgeInsetsGeometry? padding;

  /// Margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Card elevation/shadow.
  final double elevation;

  /// Shadow color.
  final Color? shadowColor;

  /// Card style variant.
  final CardVariant variant;

  /// Whether to clip content.
  final Clip clipBehavior;

  /// Custom decoration (overrides variant styling).
  final BoxDecoration? decoration;

  /// Card width.
  final double? width;

  /// Card height.
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.elevation = 0,
    this.shadowColor,
    this.variant = CardVariant.flat,
    this.clipBehavior = Clip.antiAlias,
    this.decoration,
    this.width,
    this.height,
  });

  /// Creates a flat card with no border or shadow.
  factory AppCard.flat({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      variant: CardVariant.flat,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Creates an outlined card with border.
  factory AppCard.outlined({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      variant: CardVariant.outlined,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Creates an elevated card with shadow.
  factory AppCard.elevated({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double elevation = 4,
    Color? shadowColor,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      elevation: elevation,
      shadowColor: shadowColor,
      variant: CardVariant.elevated,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Creates a filled card with colored background.
  factory AppCard.filled({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      backgroundColor: backgroundColor ?? AppColors.gray50,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      variant: CardVariant.filled,
      width: width,
      height: height,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? context.dynamicWidth(0.035);
    final effectivePadding = padding ?? AppSpacing.cardPadding;
    final effectiveDecoration = decoration ?? _buildDecoration(context, effectiveBorderRadius);

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: effectiveDecoration,
      clipBehavior: clipBehavior,
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          splashColor: AppColors.primaryColor.withValues(alpha: 0.1),
          highlightColor: AppColors.primaryColor.withValues(alpha: 0.05),
          child: card,
        ),
      );
    }

    return card;
  }

  BoxDecoration _buildDecoration(BuildContext context, double radius) {
    switch (variant) {
      case CardVariant.flat:
        return BoxDecoration(
          color: backgroundColor ?? context.cardBg,
          borderRadius: BorderRadius.circular(radius),
        );

      case CardVariant.outlined:
        return BoxDecoration(
          color: backgroundColor ?? context.cardBg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor ?? context.borderColor,
            width: borderWidth,
          ),
        );

      case CardVariant.elevated:
        return BoxDecoration(
          color: backgroundColor ?? context.cardBg,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: shadowColor ?? AppColors.gray900.withValues(alpha: 0.08),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation / 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: shadowColor ?? AppColors.gray900.withValues(alpha: 0.04),
              blurRadius: elevation,
              offset: Offset(0, elevation / 4),
              spreadRadius: 0,
            ),
          ],
        );

      case CardVariant.filled:
        return BoxDecoration(
          color: backgroundColor ?? context.surfaceColor,
          borderRadius: BorderRadius.circular(radius),
        );
    }
  }
}

/// Card style variants.
enum CardVariant {
  /// Simple card with white background.
  flat,

  /// Card with border.
  outlined,

  /// Card with shadow/elevation.
  elevated,

  /// Card with colored fill.
  filled,
}

/// Extension for quick card creation
extension CardExtension on Widget {
  /// Wraps the widget in an AppCard
  Widget withCard({
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? borderRadius,
    CardVariant variant = CardVariant.flat,
  }) {
    return AppCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      variant: variant,
      child: this,
    );
  }
}
