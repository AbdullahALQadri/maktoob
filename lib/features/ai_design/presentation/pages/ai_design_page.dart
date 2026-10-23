import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/core.dart';
import '../cubit/ai_design_cubit.dart';
import '../cubit/ai_design_state.dart';
import '../widgets/ai_error_message.dart';
import '../widgets/ai_form_fields_widget.dart';
import '../widgets/ai_image_grid.dart';
import '../widgets/generation_overlay.dart';
import '../widgets/template_invitation_canvas.dart';
import '../../data/models/ai_image_model.dart';
import 'prompt_review_page.dart';
import 'template_preview_page.dart';

/// The invitation cover step. Exactly three choices:
///  0. Ready template — pick a text-free background; the event's texts are
///     laid over it on-device (no generation at all).
///  1. Custom design — describe what you like (+ optional template as
///     inspiration) and we design it.
///  2. Upload yours — a finished image used as-is.
class AiDesignPage extends StatefulWidget {
  final int eventId;
  final int eventTypeId;

  /// Event title carried over from the previous wizard page (pre-fills the
  /// "event title" field instead of re-asking the user).
  final String? eventTitle;

  /// Texts laid over a ready template (names, date, venue from page 1).
  final InvitationTexts templateTexts;

  const AiDesignPage({
    super.key,
    required this.eventId,
    required this.eventTypeId,
    this.eventTitle,
    this.templateTexts = const InvitationTexts(),
  });

  @override
  State<AiDesignPage> createState() => _AiDesignPageState();
}

class _AiDesignPageState extends State<AiDesignPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _freeformCtrl = TextEditingController();

  static const _moodTagKeys = ['festive', 'formal', 'family'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        context.read<AiDesignCubit>().switchTab(_tabs.index);
      }
    });
    context.read<AiDesignCubit>().load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _freeformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocConsumer<AiDesignCubit, AiDesignState>(
      listener: (ctx, state) {
        if (state is AiPromptReady) {
          Navigator.of(ctx).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: ctx.read<AiDesignCubit>(),
                child: PromptReviewPage(
                  imageId: state.imageId,
                  promptText: state.promptText,
                  promptVersion: state.promptVersion,
                  improvementSuggestions: state.improvementSuggestions,
                ),
              ),
            ),
          );
        } else if (state is AiImageSaved) {
          Navigator.of(ctx).popUntil(
            (route) => route.settings.name == Routes.aiDesign || route.isFirst,
          );
          Navigator.of(ctx).pop(state.imageUrl);
        }
      },
      builder: (ctx, state) {
        final isGenerating = state is AiDesignReady && state.isGenerating;
        final isUploading = state is AiDesignReady && state.isUploading;

        return PopScope(
          canPop: !isGenerating && !isUploading,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(loc?.translate('ai_generating_wait') ??
                    'جاري التوليد...'),
              ));
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.surfaceBg,
            appBar: MaktoobAppBar(
              title: loc?.translate('ai_studio_title') ?? 'استوديو التصميم',
              onClose: () => Navigator.of(ctx).pop(),
            ),
            body: Stack(
              children: [
                _buildBody(ctx, state, loc),
                if (isGenerating) const GenerationOverlay(isPromptPhase: true),
                // Saving an uploaded design: a plain loader, never the
                // "writing the description" overlay — nothing is generated.
                if (isUploading)
                  ColoredBox(
                    color: AppColors.black.withValues(alpha: 0.35),
                    child: const Center(child: AppLoader(pulsing: true)),
                  ),
              ],
            ),
            // The design bar belongs to "Custom design" only.
            bottomNavigationBar:
                (state is! AiDesignReady || state.activeTab != 1)
                    ? null
                    : _BottomGenerateBar(
                        state: state,
                        onGenerate: () =>
                            ctx.read<AiDesignCubit>().generatePrompt(),
                      ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext ctx, AiDesignState state, AppLocalizations? loc) {
    if (state is AiDesignLoading) {
      return const Center(child: AppLoader(pulsing: true));
    }
    if (state is! AiDesignReady) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(state is AiDesignError
              ? localizeAiDesignError(state.message, loc)
              : 'حدث خطأ'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ctx.read<AiDesignCubit>().load(),
            child: Text(loc?.translate('common_retry') ?? 'إعادة المحاولة'),
          ),
        ]),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
          child: PillTabs(
            controller: _tabs,
            tabs: [
              loc?.translate('ai_tab_template') ?? 'قالب جاهز',
              loc?.translate('ai_tab_custom') ?? 'تصميم خاص',
              loc?.translate('ai_tab_upload') ?? 'ارفع تصميمك',
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _buildTemplateTab(ctx, state, loc),
              _buildCustomTab(ctx, state, loc),
              _buildUploadTab(ctx, state, loc),
            ],
          ),
        ),
      ],
    );
  }

  /// Tab 1 — ready template: tap one to preview it with the event's texts.
  Widget _buildTemplateTab(
      BuildContext ctx, AiDesignReady s, AppLocalizations? loc) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.mdl, 0, AppSpacing.mdl, AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          loc?.translate('ai_template_hint') ??
              'اختر قالباً وسنضع بيانات مناسبتك عليه مباشرة',
          style: TextStyle(fontSize: 13, color: AppColors.gray500),
        ),
        const SizedBox(height: AppSpacing.smd),
        if (s.galleryImages.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  vertical: AppSpacing.xl),
              child: Text(
                loc?.translate('ai_gallery_empty') ?? 'لا توجد تصاميم متاحة',
                style: TextStyle(color: AppColors.gray500),
              ),
            ),
          )
        else
          AiImageGrid(
            images: s.galleryImages,
            onSelect: (img) => _openTemplate(ctx, img),
          ),
      ]),
    );
  }

  void _openTemplate(BuildContext ctx, AiImageModel template) {
    final texts = widget.templateTexts.copyWith(
      title: widget.templateTexts.title.isNotEmpty
          ? widget.templateTexts.title
          : (widget.eventTitle ?? ''),
    );
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: ctx.read<AiDesignCubit>(),
        child: TemplatePreviewPage(template: template, initialTexts: texts),
      ),
    ));
  }

  /// Tab 2 — custom design: the user's words (+ optional inspiration).
  Widget _buildCustomTab(
      BuildContext ctx, AiDesignReady s, AppLocalizations? loc) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.mdl, 0, AppSpacing.mdl, AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          loc?.translate('ai_custom_hint') ??
              'صف بكلمات قليلة ما تحب، ونصمم لك غلافاً خاصاً بذوقك',
          style: TextStyle(fontSize: 13, color: AppColors.gray500),
        ),
        const SizedBox(height: AppSpacing.smd),
        TextFormField(
          controller: _freeformCtrl,
          maxLines: 5,
          minLines: 3,
          onChanged: (v) =>
              ctx.read<AiDesignCubit>().updateFreeformPrompt(v),
          decoration: InputDecoration(
            hintText: loc?.translate('ai_freeform_hint') ??
                'مثال: دعوة زفاف فاخرة...',
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.smd),
        _MoodTagsRow(
          tagKeys: _moodTagKeys,
          selected: s.selectedMoodTags,
          loc: loc,
          onToggle: (tag) => ctx.read<AiDesignCubit>().toggleMoodTag(tag),
        ),
        if (s.galleryImages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            loc?.translate('ai_custom_inspired_label') ??
                'مستوحى من قالب (اختياري)',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: s.galleryImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) {
                final img = s.galleryImages[i];
                final selected = img.id == s.selectedImageId;
                return GestureDetector(
                  onTap: () => ctx.read<AiDesignCubit>().selectImage(img),
                  child: Container(
                    width: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryColor
                            : AppColors.gray200,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: img.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const ColoredBox(color: AppColors.gray100),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _buildSharedForm(ctx, s, loc),
        const SizedBox(height: AppSpacing.lg),
      ]),
    );
  }

  Widget _buildSharedForm(
      BuildContext ctx, AiDesignReady s, AppLocalizations? loc) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        loc?.translate('ai_extra_details') ?? 'تفاصيل إضافية',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 16),
      Text(
        loc?.translate('ai_event_title_label') ?? 'ما هو عنوان الحدث؟',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.gray500,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: widget.eventTitle,
        onChanged: (v) =>
            ctx.read<AiDesignCubit>().updateFormValue('event_title', v),
        decoration: InputDecoration(
          hintText: loc?.translate('ai_event_title_hint') ?? 'مثال: حفل تخرج 2024',
          filled: true,
          fillColor: AppColors.gray100,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      // Dynamic fields (kept for backward compatibility with backend forms)
      if (s.formFields.isNotEmpty) ...[
        const SizedBox(height: 16),
        AiFormFieldsWidget(
          fields: s.formFields,
          values: s.formValues,
          onChanged: (e) =>
              ctx.read<AiDesignCubit>().updateFormValue(e.key, e.value),
        ),
      ],
      if (s.generationError != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _localizeError(s.generationError!, loc),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ]),
        ),
      ],
    ]);
  }

  /// Tab 3 — upload your own image (a separate option from the AI designs).
  Widget _buildUploadTab(
      BuildContext ctx, AiDesignReady s, AppLocalizations? loc) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          loc?.translate('ai_tab_upload') ?? 'ارفع تصميمك',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          loc?.translate('ai_upload_desc') ??
              'عندك تصميم جاهز؟ ارفعه وسنستخدمه كما هو.',
          style: TextStyle(fontSize: 13, color: AppColors.gray500),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _pickAndUploadImage(ctx),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Column(children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 48, color: AppColors.primaryColor),
              const SizedBox(height: 12),
              Text(
                loc?.translate('ai_upload_tap') ?? 'اضغط لاختيار صورة',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'JPG · PNG · WEBP',
                style: TextStyle(fontSize: 12, color: AppColors.gray500),
              ),
            ]),
          ),
        ),
        if (s.generationError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _localizeError(s.generationError!, loc),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  /// Pick an image from the gallery and upload it as a custom (non-AI) design.
  Future<void> _pickAndUploadImage(BuildContext ctx) async {
    final loc = AppLocalizations.of(ctx);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 2200,
      );
      if (picked == null || !ctx.mounted) return;
      await ctx.read<AiDesignCubit>().uploadCustomImage(File(picked.path));
    } catch (_) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(loc?.translate('ai_upload_failed') ?? 'فشل رفع الصورة'),
        backgroundColor: Colors.red,
      ));
    }
  }

  String _localizeError(String error, AppLocalizations? loc) =>
      localizeAiDesignError(error, loc);
}

// =============================================================================
// Mood tags row
// =============================================================================

class _MoodTagsRow extends StatelessWidget {
  final List<String> tagKeys;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final AppLocalizations? loc;

  const _MoodTagsRow({
    required this.tagKeys,
    required this.selected,
    required this.onToggle,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final key in tagKeys)
          _MoodChip(
            label: loc?.translate('ai_mood_tag_$key') ?? key,
            isSelected: selected.contains(key),
            onTap: () => onToggle(key),
          ),
        _MoodChip(
          label: loc?.translate('ai_mood_tag_add') ?? '+ إضافة طابع',
          isSelected: false,
          onTap: () {},
        ),
      ],
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.10)
              : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.40)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primaryColor : AppColors.gray500,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Sticky bottom generate button
// =============================================================================

class _BottomGenerateBar extends StatelessWidget {
  final AiDesignState state;
  final VoidCallback onGenerate;

  const _BottomGenerateBar({required this.state, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final ready = state is AiDesignReady ? state as AiDesignReady : null;
    final canGenerate = ready != null &&
        !ready.isGenerating &&
        ready.activeTab == 1 &&
        (ready.freeformPromptText.trim().isNotEmpty ||
            ready.selectedImageId != null ||
            ready.selectedMoodTags.isNotEmpty);

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: canGenerate ? onGenerate : null,
            icon: const Icon(Icons.brush_outlined, color: Colors.white),
            label: Text(
              loc?.translate('ai_generate_design_btn') ?? 'صمّم لي',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              disabledBackgroundColor: AppColors.gray300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}
