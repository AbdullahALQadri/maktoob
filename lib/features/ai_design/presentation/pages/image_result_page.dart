import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/core.dart';
import '../cubit/ai_design_cubit.dart';
import '../cubit/ai_design_state.dart';

/// Page 3 — Display the generated image and let user use it or regenerate.
class ImageResultPage extends StatelessWidget {
  final int imageId;
  final String imageUrl;
  final String? provider;
  final String? model;
  final int? generationTimeMs;
  final String? styleTitle;

  const ImageResultPage({
    super.key,
    required this.imageId,
    required this.imageUrl,
    this.provider,
    this.model,
    this.generationTimeMs,
    this.styleTitle,
  });

  static bool _isSaving(AiDesignState state) => state is AiImageSaved;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocConsumer<AiDesignCubit, AiDesignState>(
      listener: (ctx, state) {
        if (state is AiDesignError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          appBar: MaktoobAppBar(
            title: loc?.translate('ai_final_result_title') ?? 'النتيجة النهائية',
            titleColor: Colors.black87,
            titleLeading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  loc?.translate('app_name') ?? 'Maktoob',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            showCloseButton: false,
            onClose: () => Navigator.of(ctx).pop(),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _ImageCard(
                imageUrl: imageUrl,
                provider: provider,
                model: model,
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: _MetaCard(
                    icon: Icons.palette_outlined,
                    label: loc?.translate('ai_style_label') ?? 'النمط',
                    value: styleTitle ?? '—',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetaCard(
                    icon: Icons.speed_rounded,
                    label: loc?.translate('ai_generation_time_label') ??
                        'وقت التوليد',
                    value: _formatTime(loc),
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSaving(state)
                      ? null
                      : () => ctx.read<AiDesignCubit>().saveImage(imageId, imageUrl),
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: Text(
                    loc?.translate('ai_use_image_btn') ?? 'استخدم هذه الصورة',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                _IconActionButton(
                  icon: Icons.share_outlined,
                  tooltip: loc?.translate('ai_share_image') ?? 'مشاركة',
                  onTap: () => _shareImage(context),
                ),
                const SizedBox(width: 10),
                _IconActionButton(
                  icon: Icons.link_rounded,
                  tooltip: loc?.translate('ai_copy_image_link') ?? 'نسخ الرابط',
                  onTap: () => _copyImageLink(context, loc),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(ctx).popUntil(
                        (route) =>
                            route.settings.name == Routes.aiDesign ||
                            route.isFirst,
                      ),
                      icon: Icon(Icons.refresh_rounded,
                          color: AppColors.primaryColor, size: 18),
                      label: Text(
                        loc?.translate('ai_regenerate_image') ?? 'أعد التوليد',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        );
      },
    );
  }

  String _formatTime(AppLocalizations? loc) {
    if (generationTimeMs == null) return '—';
    final seconds = generationTimeMs! / 1000;
    final unit = loc?.translate('ai_generation_time_unit') ?? 'ث';
    return '${seconds.toStringAsFixed(1)} $unit';
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      await Share.share(imageUrl);
    } catch (e) {
      debugPrint('Share failed: $e');
    }
  }

  /// Copies the Cloudinary URL to the clipboard and confirms via SnackBar.
  ///
  /// True "save to gallery" requires an extra plugin (image_gallery_saver
  /// or gal) that the project doesn't depend on. Surfacing a copyable URL
  /// lets the user paste it anywhere — Photos, Files, a browser — without
  /// adding a dependency or lying about what the button does.
  Future<void> _copyImageLink(
      BuildContext context, AppLocalizations? loc) async {
    await Clipboard.setData(ClipboardData(text: imageUrl));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(loc?.translate('ai_image_link_copied') ?? 'تم نسخ الرابط'),
      duration: const Duration(seconds: 2),
    ));
  }
}

class _ImageCard extends StatelessWidget {
  final String imageUrl;
  final String? provider;
  final String? model;

  const _ImageCard({
    required this.imageUrl,
    required this.provider,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final modelLabel = [provider, model].where((e) => (e ?? '').isNotEmpty).join(' ');
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(fit: StackFit.expand, children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(color: Colors.white),
            ),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.gray200,
              child: const Icon(Icons.broken_image_outlined,
                  size: 60, color: Colors.grey),
            ),
          ),
          // Bottom gradient overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 4K badge bottom-left
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '4K  HD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          // Provider/model pill bottom-right
          if (modelLabel.isNotEmpty)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome,
                        color: AppColors.primaryColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      modelLabel,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Top-right "Ready" pill
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.circle, color: Colors.white, size: 8),
                  SizedBox(width: 6),
                  Text(
                    'جار التحسين',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: AppColors.gray500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Icon(icon, color: AppColors.gray700),
        ),
      ),
    );
  }
}
