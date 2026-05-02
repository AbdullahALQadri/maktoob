import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../cubit/ai_design_cubit.dart';
import '../cubit/ai_design_state.dart';
import '../widgets/generation_overlay.dart';
import 'image_result_page.dart';

/// Page 2 — Review and edit the generated Arabic prompt, then trigger image generation.
class PromptReviewPage extends StatefulWidget {
  final int imageId;
  final String promptText;

  const PromptReviewPage({
    super.key,
    required this.imageId,
    required this.promptText,
  });

  @override
  State<PromptReviewPage> createState() => _PromptReviewPageState();
}

class _PromptReviewPageState extends State<PromptReviewPage> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.promptText);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocConsumer<AiDesignCubit, AiDesignState>(
      listener: (ctx, state) {
        if (state is AiImageCompleted) {
          // Replace this page with the result page
          Navigator.of(ctx).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: ctx.read<AiDesignCubit>(),
                child: ImageResultPage(
                  imageId:  state.imageId,
                  imageUrl: state.imageUrl,
                  provider: state.provider,
                  model:    state.model,
                ),
              ),
            ),
          );
        } else if (state is AiDesignError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (ctx, state) {
        final isGenerating = state is AiImageGenerating;
        return PopScope(
          canPop: !isGenerating,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(loc?.translate('ai_generating_wait') ?? 'جاري التوليد...'),
              ));
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(loc?.translate('ai_prompt_review_title') ?? 'مراجعة النص'),
            ),
            body: Stack(
              children: [
                _buildBody(ctx, state, loc),
                if (isGenerating) const GenerationOverlay(isPromptPhase: false),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext ctx, AiDesignState state, AppLocalizations? loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                loc?.translate('ai_prompt_review_info') ??
                    'يمكنك تعديل النص أدناه قبل توليد الصورة',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Prompt label
        Text(
          loc?.translate('ai_prompt_label') ?? 'النص المقترح',
          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Editable prompt field
        TextFormField(
          controller: _ctrl,
          maxLines: null,
          minLines: 6,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 15, height: 1.6),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 28),

        // Action buttons
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: state is! AiImageGenerating
                  ? () => Navigator.of(ctx).pop()
                  : null,
              child: Text(loc?.translate('ai_regenerate_prompt') ?? 'أعد توليد النص'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: state is! AiImageGenerating
                  ? () => ctx.read<AiDesignCubit>().confirmGenerate(
                        widget.imageId,
                        _ctrl.text.trim(),
                      )
                  : null,
              icon: const Icon(Icons.auto_awesome),
              label: Text(loc?.translate('ai_generate_image_btn') ?? 'توليد الصورة'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 24),
      ]),
    );
  }
}
