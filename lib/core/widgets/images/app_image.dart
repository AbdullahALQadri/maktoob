import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/app_colors.dart';
import '../../utils/responsive.dart';

/// A unified image widget that handles various image sources.
///
/// This widget automatically detects the image type and renders accordingly.
/// Supports network images, assets, SVGs, and file images with consistent
/// loading states and error handling.
///
/// Example usage:
/// ```dart
/// // Network image
/// AppImage.network(
///   'https://example.com/image.jpg',
///   width: 200,
///   height: 200,
/// )
///
/// // Asset image
/// AppImage.asset(
///   'assets/images/logo.png',
///   width: 100,
/// )
///
/// // SVG asset
/// AppImage.svg(
///   'assets/icons/home.svg',
///   width: 24,
///   color: AppColors.primary,
/// )
///
/// // File image
/// AppImage.file(
///   File('/path/to/image.jpg'),
///   width: 150,
/// )
/// ```
class AppImage extends StatelessWidget {
  /// The image source (URL, asset path, or file).
  final dynamic source;

  /// Image width.
  final double? width;

  /// Image height.
  final double? height;

  /// How to fit the image.
  final BoxFit fit;

  /// Border radius.
  final double? borderRadius;

  /// Color to apply (for SVGs).
  final Color? color;

  /// Placeholder widget while loading.
  final Widget? placeholder;

  /// Error widget when image fails to load.
  final Widget? errorWidget;

  /// Image type.
  final ImageType type;

  /// Whether to show a shimmer loading effect.
  final bool showShimmer;

  /// Clip behavior.
  final Clip clipBehavior;

  /// Image alignment.
  final Alignment alignment;

  const AppImage({
    super.key,
    required this.source,
    required this.type,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.showShimmer = true,
    this.clipBehavior = Clip.antiAlias,
    this.alignment = Alignment.center,
  });

  /// Creates a network image widget.
  factory AppImage.network(
    String url, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    bool showShimmer = true,
    Clip clipBehavior = Clip.antiAlias,
    Alignment alignment = Alignment.center,
  }) {
    return AppImage(
      key: key,
      source: url,
      type: ImageType.network,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      showShimmer: showShimmer,
      clipBehavior: clipBehavior,
      alignment: alignment,
    );
  }

  /// Creates an asset image widget.
  factory AppImage.asset(
    String assetPath, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double? borderRadius,
    Color? color,
    Clip clipBehavior = Clip.antiAlias,
    Alignment alignment = Alignment.center,
  }) {
    return AppImage(
      key: key,
      source: assetPath,
      type: ImageType.asset,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      color: color,
      clipBehavior: clipBehavior,
      alignment: alignment,
    );
  }

  /// Creates an SVG image widget.
  factory AppImage.svg(
    String assetPath, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    Clip clipBehavior = Clip.antiAlias,
    Alignment alignment = Alignment.center,
  }) {
    return AppImage(
      key: key,
      source: assetPath,
      type: ImageType.svg,
      width: width,
      height: height,
      fit: fit,
      color: color,
      clipBehavior: clipBehavior,
      alignment: alignment,
    );
  }

  /// Creates a file image widget.
  factory AppImage.file(
    File file, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double? borderRadius,
    Clip clipBehavior = Clip.antiAlias,
    Alignment alignment = Alignment.center,
  }) {
    return AppImage(
      key: key,
      source: file,
      type: ImageType.file,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      alignment: alignment,
    );
  }

  /// Creates a memory image widget from bytes.
  factory AppImage.memory(
    List<int> bytes, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double? borderRadius,
    Clip clipBehavior = Clip.antiAlias,
    Alignment alignment = Alignment.center,
  }) {
    return AppImage(
      key: key,
      source: bytes,
      type: ImageType.memory,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      alignment: alignment,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? 0;

    Widget imageWidget;

    switch (type) {
      case ImageType.network:
        imageWidget = _buildNetworkImage(context);
        break;
      case ImageType.asset:
        imageWidget = _buildAssetImage();
        break;
      case ImageType.svg:
        imageWidget = _buildSvgImage();
        break;
      case ImageType.file:
        imageWidget = _buildFileImage();
        break;
      case ImageType.memory:
        imageWidget = _buildMemoryImage();
        break;
    }

    if (effectiveBorderRadius > 0) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        clipBehavior: clipBehavior,
        child: imageWidget,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: imageWidget,
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    return Image.network(
      source as String,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildLoadingPlaceholder(context);
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildErrorPlaceholder(context);
      },
    );
  }

  Widget _buildAssetImage() {
    return Image.asset(
      source as String,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
    );
  }

  Widget _buildSvgImage() {
    return SvgPicture.asset(
      source as String,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }

  Widget _buildFileImage() {
    return Image.file(
      source as File,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
  }

  Widget _buildMemoryImage() {
    return Image.memory(
      source is List<int> ? Uint8List.fromList(source as List<int>) : source,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    if (showShimmer) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
        ),
        child: Center(
          child: SizedBox(
            width: context.dynamicWidth(0.06),
            height: context.dynamicWidth(0.06),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray400),
            ),
          ),
        ),
      );
    }
    return Container(
      width: width,
      height: height,
      color: AppColors.gray100,
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.gray400,
        size: context.dynamicWidth(0.08),
      ),
    );
  }
}

/// Image type enum.
enum ImageType {
  network,
  asset,
  svg,
  file,
  memory,
}

/// Circular avatar image widget.
class AppAvatar extends StatelessWidget {
  /// The image source.
  final String? imageUrl;

  /// Fallback initials when no image.
  final String? initials;

  /// Avatar size.
  final double size;

  /// Background color for initials.
  final Color? backgroundColor;

  /// Text color for initials.
  final Color? textColor;

  /// Border color.
  final Color? borderColor;

  /// Border width.
  final double borderWidth;

  /// Placeholder widget.
  final Widget? placeholder;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 48,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 0,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primaryColor.withValues(alpha: 0.1);
    final effectiveTextColor = textColor ?? AppColors.primaryColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveBackgroundColor,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.white,
                width: borderWidth,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildInitials(effectiveTextColor),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return placeholder ?? _buildInitials(effectiveTextColor);
              },
            )
          : _buildInitials(effectiveTextColor),
    );
  }

  Widget _buildInitials(Color textColor) {
    if (initials == null || initials!.isEmpty) {
      return Icon(
        Icons.person_outline_rounded,
        size: size * 0.5,
        color: textColor,
      );
    }

    return Center(
      child: Text(
        initials!.length > 2 ? initials!.substring(0, 2).toUpperCase() : initials!.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
