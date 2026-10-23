import 'package:flutter/material.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading/mk_pass.dart';

/// Full-screen non-dismissible overlay shown while a design is prepared.
/// [isPromptPhase] = true → "generating text" message
/// [isPromptPhase] = false → "generating image" message
///
/// Uses the shared Maktoob wait scene ([MkPass]); the lines are calm progress
/// steps and never name the technology behind the work.
class GenerationOverlay extends StatelessWidget {
  final bool isPromptPhase;
  const GenerationOverlay({super.key, this.isPromptPhase = true});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    String t(String key, String fallback) => loc?.translate(key) ?? fallback;

    final title = isPromptPhase
        ? t('ai_generating_prompt', 'جاري إنشاء النص...')
        : t('ai_generating_image', 'جاري إنشاء صورة الدعوة...');
    final sub = t('ai_generating_wait', 'قد يستغرق حتى 3 دقائق');
    final lines = [
      title,
      if (!isPromptPhase) ...[
        t('gen_stage_colors', 'نرتّب الألوان والإطار…'),
        t('gen_stage_details', 'نضع تفاصيل مناسبتك…'),
        t('gen_stage_touches', 'نضيف اللمسات الأخيرة…'),
      ],
    ];

    return Material(
      color: AppColors.tertiaryColor.withValues(alpha: 0.94),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MkPass(lines: lines, every: const Duration(seconds: 12)),
            const SizedBox(height: 12),
            Text(
              sub,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
