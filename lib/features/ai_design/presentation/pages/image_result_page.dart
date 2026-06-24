import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/generation_status_model.dart';
import '../cubit/ai_design_cubit.dart';
import '../cubit/ai_design_state.dart';
import '../widgets/generation_overlay.dart';

/// Page 3 — Display the generated image, let the user use it, or refine it
/// in one tap via Hermes suggestion chips (each tap regenerates a new image).
class ImageResultPage extends StatefulWidget {
  final int imageId;
  final String imageUrl;
  final String? provider;
  final String? model;
  final int? generationTimeMs;
  final String? styleTitle;
  final List<ImprovementSuggestion> improvementSuggestions;

  const ImageResultPage({
    super.key,
    required this.imageId,
    required this.imageUrl,
    this.provider,
    this.model,
    this.generationTimeMs,
    this.styleTitle,
    this.improvementSuggestions = const [],
  });

  @override
  State<ImageResultPage> createState() => _ImageResultPageState();
}

class _ImageResultPageState extends State<ImageResultPage> {
  // Current result shown — updated in place each time a refine completes so the
  // user iterates on the same screen instead of stacking pages.
  late int _imageId;
  late String _imageUrl;
  String? _provider;
  String? _model;
  int? _generationTimeMs;
  String? _styleTitle;
  late List<ImprovementSuggestion> _suggestions;

  @override
  void initState() {
    super.initState();
    _imageId          = widget.imageId;
    _imageUrl         = widget.imageUrl;
    _provider         = widget.provider;
    _model            = widget.model;
    _generationTimeMs = widget.generationTimeMs;
    _styleTitle       = widget.styleTitle;
    _suggestions      = widget.improvementSuggestions;
  }

  void _refineWith(BuildContext ctx, ImprovementSuggestion s) {
    ctx.read<AiDesignCubit>().refine(
          _imageId,
          suggestion: s.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocConsumer<AiDesignCubit, AiDesignState>(
      listener: (ctx, state) {
        if (state is AiImageCompleted) {
          // A refine finished — swap the result in place with fresh chips.
          setState(() {
            _imageId          = state.imageId;
            _imageUrl         = state.imageUrl;
            _provider         = state.provider;
            _model            = state.model;
            _generationTimeMs = state.generationTimeMs;
            _styleTitle       = state.styleTitle ?? _styleTitle;
            _suggestions      = state.improvementSuggestions;
          });
        } else if (state is AiDesignError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (ctx, state) {
        final isRefining = state is AiImageGenerating;
        return PopScope(
          canPop: !isRefining,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(
                    loc?.translate('ai_generating_wait') ?? 'جاري التوليد...'),
              ));
            }
          },
          child: Scaffold(
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
            body: Stack(
              children: [
                _buildBody(ctx, state, loc),
                if (isRefining) const GenerationOverlay(isPromptPhase: false),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext ctx, AiDesignState state, AppLocalizations? loc) {
    final isBusy = state is AiImageGenerating || state is AiImageSaved;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _ImageCard(
          imageUrl: _imageUrl,
          provider: _provider,
          model: _model,
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _MetaCard(
              icon: Icons.palette_outlined,
              label: loc?.translate('ai_style_label') ?? 'النمط',
              value: _styleTitle ?? '—',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetaCard(
              icon: Icons.speed_rounded,
              label: loc?.translate('ai_generation_time_label') ?? 'وقت التوليد',
              value: _formatTime(loc),
            ),
          ),
        ]),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isBusy
                ? null
                : () =>
                    ctx.read<AiDesignCubit>().saveImage(_imageId, _imageUrl),
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
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
              disabledBackgroundColor: AppColors.gray300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconActionButton(
              icon: Icons.share_outlined,
              tooltip: loc?.translate('ai_share_image') ?? 'مشاركة',
              onTap: () => _shareImage(),
            ),
            const SizedBox(width: 12),
            _IconActionButton(
              icon: Icons.link_rounded,
              tooltip: loc?.translate('ai_copy_image_link') ?? 'نسخ الرابط',
              onTap: () => _copyImageLink(ctx, loc),
            ),
          ],
        ),

        // ── One-tap Hermes refinement chips ──────────────────────────────
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 28),
          Row(children: [
            Icon(Icons.auto_awesome, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                loc?.translate('ai_refine_suggestions_title') ??
                    'حسّن التصميم بضغطة',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            loc?.translate('ai_refine_suggestions_hint') ??
                'اضغط على أي اقتراح لإعادة توليد نسخة محسّنة.',
            style: TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
          const SizedBox(height: 12),
          for (final s in _suggestions) ...[
            _RefineChip(
              suggestion: s,
              enabled: !isBusy,
              onTap: () => _refineWith(ctx, s),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ]),
    );
  }

  String _formatTime(AppLocalizations? loc) {
    if (_generationTimeMs == null) return '—';
    final seconds = _generationTimeMs! / 1000;
    final unit = loc?.translate('ai_generation_time_unit') ?? 'ث';
    return '${seconds.toStringAsFixed(1)} $unit';
  }

  Future<void> _shareImage() async {
    try {
      await Share.share(_imageUrl);
    } catch (e) {
      debugPrint('Share failed: $e');
    }
  }

  /// Copies the Cloudinary URL to the clipboard and confirms via SnackBar.
  Future<void> _copyImageLink(
      BuildContext context, AppLocalizations? loc) async {
    await Clipboard.setData(ClipboardData(text: _imageUrl));
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
                    'جاهزة',
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

// =============================================================================
// One-tap refinement chip
// =============================================================================

class _RefineChip extends StatelessWidget {
  final ImprovementSuggestion suggestion;
  final bool enabled;
  final VoidCallback onTap;

  const _RefineChip({
    required this.suggestion,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(children: [
            Icon(_iconForName(suggestion.icon),
                color: AppColors.primaryColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                suggestion.text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.refresh_rounded,
                color: AppColors.gray500, size: 18),
          ]),
        ),
      ),
    );
  }

  IconData _iconForName(String name) {
    switch (name) {
      case 'palette':
        return Icons.palette_outlined;
      case 'camera':
      case 'camera_alt':
        return Icons.camera_alt_outlined;
      case 'lightbulb':
        return Icons.lightbulb_outlined;
      case 'style':
        return Icons.style_outlined;
      default:
        return Icons.auto_awesome;
    }
  }
}
