import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/core.dart';
import '../cubit/ai_design_cubit.dart';
import '../cubit/ai_design_state.dart';
import '../widgets/ai_form_fields_widget.dart';
import '../widgets/ai_image_grid.dart';
import '../widgets/generation_overlay.dart';
import 'prompt_review_page.dart';

/// Page 1 — Select design style + fill form + generate prompt.
class AiDesignPage extends StatefulWidget {
  final int eventId;
  final int eventTypeId;

  const AiDesignPage({
    super.key,
    required this.eventId,
    required this.eventTypeId,
  });

  @override
  State<AiDesignPage> createState() => _AiDesignPageState();
}

class _AiDesignPageState extends State<AiDesignPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _freeformCtrl    = TextEditingController();
  final _customPromptCtrl = TextEditingController();

  static const _moodTagKeys = ['festive', 'formal', 'family'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        context.read<AiDesignCubit>().switchTab(_tabs.index);
        if (_tabs.index == 0) _freeformCtrl.clear();
      }
    });
    context.read<AiDesignCubit>().load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _freeformCtrl.dispose();
    _customPromptCtrl.dispose();
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

        return PopScope(
          canPop: !isGenerating,
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
              ],
            ),
            bottomNavigationBar: _BottomGenerateBar(
              state: state,
              onGenerate: () => ctx.read<AiDesignCubit>().generatePrompt(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext ctx, AiDesignState state, AppLocalizations? loc) {
    if (state is AiDesignLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is! AiDesignReady) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(state is AiDesignError ? state.message : 'حدث خطأ'),
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: PillTabs(
            controller: _tabs,
            tabs: [
              loc?.translate('ai_tab_gallery') ?? 'المعرض',
              loc?.translate('ai_tab_freeform') ?? 'وصف حر',
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _buildGalleryTab(ctx, state, loc),
              _buildFreeformTab(ctx, state, loc),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryTab(
      BuildContext ctx, AiDesignReady s, AppLocalizations? loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Expanded(
              child: Text(
                loc?.translate('ai_select_style') ?? 'اختر النمط',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              loc?.translate('ai_view_all') ?? 'مشاهدة الكل',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (s.galleryImages.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                loc?.translate('ai_gallery_empty') ?? 'لا توجد تصاميم متاحة',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          AiImageGrid(
            images: s.galleryImages,
            selectedId: s.selectedImageId,
            onSelect: (img) => ctx.read<AiDesignCubit>().selectImage(img),
          ),
        const SizedBox(height: 24),
        _buildSharedForm(ctx, s, loc),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildFreeformTab(
      BuildContext ctx, AiDesignReady s, AppLocalizations? loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          loc?.translate('ai_freeform_label') ?? 'صف التصميم الذي تريده',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _freeformCtrl,
          maxLines: 5,
          minLines: 3,
          textDirection: TextDirection.rtl,
          onChanged: (v) =>
              ctx.read<AiDesignCubit>().updateFreeformPrompt(v),
          decoration: InputDecoration(
            hintText: loc?.translate('ai_freeform_hint') ??
                'مثال: دعوة زفاف فاخرة...',
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSharedForm(ctx, s, loc),
        const SizedBox(height: 24),
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
      const SizedBox(height: 16),
      Text(
        loc?.translate('ai_mood_label') ?? 'وصف الأجواء (اختياري)',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.gray500,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _customPromptCtrl,
        maxLines: 4,
        minLines: 3,
        onChanged: (v) => ctx.read<AiDesignCubit>().updateCustomPrompt(v),
        decoration: InputDecoration(
          hintText: loc?.translate('ai_mood_hint') ??
              'اكتب بعض الكلمات التي تصف الحدث...',
          filled: true,
          fillColor: AppColors.gray100,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      const SizedBox(height: 14),
      _MoodTagsRow(
        tagKeys: _moodTagKeys,
        selected: s.selectedMoodTags,
        loc: loc,
        onToggle: (tag) => ctx.read<AiDesignCubit>().toggleMoodTag(tag),
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

  String _localizeError(String error, AppLocalizations? loc) {
    if (error == 'timeout') {
      return loc?.translate('ai_timeout_error') ??
          'انتهت المهلة. يرجى المحاولة مجدداً.';
    }
    return error;
  }
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
        ((ready.activeTab == 0 &&
                (ready.selectedImageId != null ||
                    ready.formValues.values.any((v) => v.isNotEmpty))) ||
            (ready.activeTab == 1 && ready.freeformPromptText.trim().isNotEmpty));

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
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
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            label: Text(
              loc?.translate('ai_generate_design_btn') ?? 'توليد التصميم',
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
