import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/generation_status_model.dart';
import '../cubit/ai_design_cubit.dart';
import '../cubit/ai_design_state.dart';
import '../widgets/generation_overlay.dart';
import 'image_result_page.dart';

const int kMaxPromptChars = 500;

/// Page 2 — Review and edit the generated Arabic prompt, then trigger image generation.
class PromptReviewPage extends StatefulWidget {
  final int imageId;
  final String promptText;
  final String? promptVersion;
  final List<ImprovementSuggestion> improvementSuggestions;

  const PromptReviewPage({
    super.key,
    required this.imageId,
    required this.promptText,
    this.promptVersion,
    this.improvementSuggestions = const [],
  });

  @override
  State<PromptReviewPage> createState() => _PromptReviewPageState();
}

class _PromptReviewPageState extends State<PromptReviewPage> {
  late final TextEditingController _ctrl;
  int _charCount = 0;
  // Indexes of suggestions the user has already applied. Each chip can be
  // tapped at most once so the prompt doesn't accumulate duplicates.
  final Set<int> _appliedSuggestions = {};

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.promptText);
    _charCount = _ctrl.text.length;
    _ctrl.addListener(() {
      if (mounted) setState(() => _charCount = _ctrl.text.length);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _applySuggestion(int index, ImprovementSuggestion s) {
    if (_appliedSuggestions.contains(index)) return;
    final next = '${_ctrl.text.trim()} ${s.text}'.trim();
    _ctrl.text = next;
    _ctrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _ctrl.text.length),
    );
    setState(() => _appliedSuggestions.add(index));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocConsumer<AiDesignCubit, AiDesignState>(
      listener: (ctx, state) {
        if (state is AiImageCompleted) {
          Navigator.of(ctx).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: ctx.read<AiDesignCubit>(),
                child: ImageResultPage(
                  imageId: state.imageId,
                  imageUrl: state.imageUrl,
                  provider: state.provider,
                  model: state.model,
                  generationTimeMs: state.generationTimeMs,
                  styleTitle: state.styleTitle,
                  improvementSuggestions: state.improvementSuggestions,
                ),
              ),
            ),
          );
        } else if (state is AiDesignError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                content: Text(
                    loc?.translate('ai_generating_wait') ?? 'جاري التوليد...'),
              ));
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.surfaceBg,
            appBar: MaktoobAppBar(
              title: loc?.translate('ai_review_description_title') ??
                  'مراجعة الوصف',
              onClose: () => Navigator.of(ctx).pop(),
              onForward: () => Navigator.of(ctx).pop(),
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
    final isGenerating = state is AiImageGenerating;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // AI enhancement info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.18),
            ),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline,
                color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc?.translate('ai_enhancement_banner_title') ??
                        'تحسين الذكاء الاصطناعي',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc?.translate('ai_enhancement_banner_body') ??
                        'لقد قمنا بتحويل أفكارك إلى وصف تفصيلي. يمكنك التعديل عليه للحصول على أدق النتائج الممكنة.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.tertiaryColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Prompt card
        _PromptCard(
          controller: _ctrl,
          charCount: _charCount,
          version: widget.promptVersion,
          loc: loc,
        ),
        const SizedBox(height: 20),

        // When Hermes returned refinement suggestions the user iterates through
        // them (below) and we keep a single clean action. When it returned NONE
        // (a Hermes/connection failure, or the user simply isn't happy) we also
        // surface a "regenerate prompt" button so they are never stuck.
        if (widget.improvementSuggestions.isEmpty)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: !isGenerating ? () => Navigator.of(ctx).pop() : null,
                    icon: Icon(Icons.refresh_rounded,
                        color: AppColors.primaryColor, size: 18),
                    label: Text(
                      loc?.translate('ai_regenerate_prompt') ?? 'أعد توليد النص',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: !isGenerating
                        ? () => ctx.read<AiDesignCubit>().confirmGenerate(
                              widget.imageId,
                              _ctrl.text.trim(),
                            )
                        : null,
                    icon: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 18),
                    label: Text(
                      loc?.translate('ai_generate_image_btn') ?? 'توليد الصورة',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor: AppColors.gray300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: !isGenerating
                  ? () => ctx.read<AiDesignCubit>().confirmGenerate(
                        widget.imageId,
                        _ctrl.text.trim(),
                      )
                  : null,
              icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              label: Text(
                loc?.translate('ai_generate_image_btn') ?? 'توليد الصورة',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                disabledBackgroundColor: AppColors.gray300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

        if (widget.improvementSuggestions.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            loc?.translate('ai_improvement_suggestions') ?? 'مقترحات للتحسين',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < widget.improvementSuggestions.length; i++) ...[
            _SuggestionChip(
              suggestion: widget.improvementSuggestions[i],
              isApplied: _appliedSuggestions.contains(i),
              onTap: () =>
                  _applySuggestion(i, widget.improvementSuggestions[i]),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ]),
    );
  }
}

// =============================================================================
// Prompt card with header chip + body + footer counter
// =============================================================================

class _PromptCard extends StatelessWidget {
  final TextEditingController controller;
  final int charCount;
  final String? version;
  final AppLocalizations? loc;

  const _PromptCard({
    required this.controller,
    required this.charCount,
    required this.version,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (charCount / kMaxPromptChars).clamp(0.0, 1.0);
    final draftLabel = loc?.translate('ai_draft_label') ?? 'DRAFT';
    final ver = version ?? '1.0';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(
          children: [
            Icon(Icons.edit_outlined,
                color: AppColors.primaryColor, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                loc?.translate('ai_generated_description') ??
                    'وصف الصورة المولد',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$draftLabel V$ver',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.gray600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(height: 1, color: AppColors.gray200),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: null,
          minLines: 6,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 14, height: 1.7),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '$charCount / $kMaxPromptChars',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              loc?.translate('ai_char_counter_label') ?? 'حرف',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.gray200,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

// =============================================================================
// Improvement suggestion chip
// =============================================================================

class _SuggestionChip extends StatelessWidget {
  final ImprovementSuggestion suggestion;
  final bool isApplied;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.suggestion,
    required this.isApplied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isApplied ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isApplied
              ? AppColors.primaryColor.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isApplied
                ? AppColors.primaryColor.withValues(alpha: 0.30)
                : AppColors.gray200,
          ),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              suggestion.text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isApplied ? AppColors.gray500 : null,
              ),
            ),
          ),
          Icon(
            isApplied ? Icons.check_circle : _iconForName(suggestion.icon),
            color: isApplied ? AppColors.primaryColor : AppColors.gray500,
            size: 18,
          ),
        ]),
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
