import 'package:flutter/material.dart';
import '../../../../config/locale/app_localizations.dart';

/// Full-screen non-dismissible overlay shown during AI generation.
/// [isPromptPhase] = true → "generating text" message
/// [isPromptPhase] = false → "generating image" message
class GenerationOverlay extends StatelessWidget {
  final bool isPromptPhase;
  const GenerationOverlay({super.key, this.isPromptPhase = true});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final title = isPromptPhase
        ? (loc?.translate('ai_generating_prompt') ?? 'جاري إنشاء النص...')
        : (loc?.translate('ai_generating_image') ?? 'جاري إنشاء صورة الدعوة...');
    final sub = loc?.translate('ai_generating_wait') ?? 'قد يستغرق حتى 3 دقائق';

    return Material(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            const SizedBox(height: 28),
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(sub,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center),
            if (!isPromptPhase) ...[
              const SizedBox(height: 20),
              const SizedBox(
                width: 200,
                child: LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.white24),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
