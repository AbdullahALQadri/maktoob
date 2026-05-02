import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
import '../cubit/ai_design_cubit.dart';
import '../cubit/ai_design_state.dart';

/// Page 3 — Display the generated image and let user use it or regenerate.
class ImageResultPage extends StatelessWidget {
  final int imageId;
  final String imageUrl;
  final String? provider;
  final String? model;

  const ImageResultPage({
    super.key,
    required this.imageId,
    required this.imageUrl,
    this.provider,
    this.model,
  });

  static bool _isSaving(AiDesignState state) => state is AiImageSaved;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocConsumer<AiDesignCubit, AiDesignState>(
      listener: (ctx, state) {
        // AiImageSaved navigation is handled by AiDesignPage's listener
        // (it's still active in the widget tree even when covered by sub-pages)
        if (state is AiDesignError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(loc?.translate('ai_result_title') ?? 'صورة الدعوة'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Generated image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(height: 400, color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey),
                  ),
                ),
              ),

              // Provider badge
              if (provider != null) ...[
                const SizedBox(height: 10),
                Center(
                  child: Chip(
                    label: Text(
                      '${provider ?? ''} ${model != null ? '· $model' : ''}'.trim(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Regenerate — pop PromptReviewPage + ImageResultPage to get back to AiDesignPage
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).popUntil(
                  (route) => route.settings.name == Routes.aiDesign || route.isFirst,
                ),
                child: Text(loc?.translate('ai_regenerate_image') ?? 'أعد التوليد'),
              ),
              const SizedBox(height: 12),

              // Use this image button — disabled while save call is in flight
              ElevatedButton.icon(
                onPressed: _isSaving(state)
                    ? null
                    : () => ctx.read<AiDesignCubit>().saveImage(imageId, imageUrl),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(loc?.translate('ai_use_image_btn') ?? 'استخدم هذه الصورة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        );
      },
    );
  }
}
