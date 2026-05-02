import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
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

class _AiDesignPageState extends State<AiDesignPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _freeformCtrl    = TextEditingController();
  final _customPromptCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        context.read<AiDesignCubit>().switchTab(_tabs.index);
        // Sync controllers when cubit clears them on tab switch
        if (_tabs.index == 0) _freeformCtrl.clear();
        if (_tabs.index == 1) {/* gallery selection cleared by cubit */}
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
                  imageId:    state.imageId,
                  promptText: state.promptText,
                ),
              ),
            ),
          );
        } else if (state is AiImageSaved) {
          // Pop all sub-pages (PromptReview + ImageResult) back to AiDesignPage,
          // then pop AiDesignPage itself and return the image URL to Page 2.
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
                content: Text(loc?.translate('ai_generating_wait') ?? 'جاري التوليد...'),
              ));
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(loc?.translate('ai_design_title') ?? 'تصميم بالذكاء الاصطناعي'),
            ),
            body: Stack(
              children: [
                _buildBody(ctx, state, loc),
                if (isGenerating) const GenerationOverlay(isPromptPhase: true),
              ],
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

    final s = state;
    return Column(
      children: [
        // Tab bar
        TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: loc?.translate('ai_tab_gallery') ?? 'من التصاميم'),
            Tab(text: loc?.translate('ai_tab_freeform') ?? 'كتابة حرة'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _buildGalleryTab(ctx, s, loc),
              _buildFreeformTab(ctx, s, loc),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab 1: Gallery ────────────────────────────────────────────

  Widget _buildGalleryTab(BuildContext ctx, AiDesignReady s, AppLocalizations? loc) {
    final canGenerate = s.selectedImageId != null || s.formValues.values.any((v) => v.isNotEmpty);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Gallery label
        Text(
          loc?.translate('ai_gallery_label') ?? 'اختر تصميم شبيه بالذي تريده',
          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Image grid
        if (s.galleryImages.isEmpty)
          Center(
            child: Text(loc?.translate('ai_gallery_empty') ?? 'لا توجد تصاميم متاحة',
                style: const TextStyle(color: Colors.grey)),
          )
        else
          AiImageGrid(
            images:     s.galleryImages,
            selectedId: s.selectedImageId,
            onSelect:   (img) => ctx.read<AiDesignCubit>().selectImage(img),
          ),

        const SizedBox(height: 20),
        _buildSharedForm(ctx, s, loc),
        const SizedBox(height: 80),
      ]),
    );
  }

  // ── Tab 2: Freeform ───────────────────────────────────────────

  Widget _buildFreeformTab(BuildContext ctx, AiDesignReady s, AppLocalizations? loc) {
    final canGenerate = s.freeformPromptText.trim().isNotEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          loc?.translate('ai_freeform_label') ?? 'صف التصميم الذي تريده',
          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _freeformCtrl,
          maxLines: 5, minLines: 3,
          textDirection: TextDirection.rtl,
          onChanged: (v) => ctx.read<AiDesignCubit>().updateFreeformPrompt(v),
          decoration: InputDecoration(
            hintText: loc?.translate('ai_freeform_hint') ?? 'مثال: دعوة زفاف فاخرة...',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        _buildSharedForm(ctx, s, loc),
        const SizedBox(height: 80),
      ]),
    );
  }

  // ── Shared form (form fields + custom prompt + button) ────────

  Widget _buildSharedForm(BuildContext ctx, AiDesignReady s, AppLocalizations? loc) {
    final isGallery  = s.activeTab == 0;
    final canGenerate = isGallery
        ? (s.selectedImageId != null || s.formValues.values.any((v) => v.isNotEmpty))
        : s.freeformPromptText.trim().isNotEmpty;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (s.formFields.isNotEmpty) ...[
        Text(
          loc?.translate('ai_form_fields_label') ?? 'أضف تفاصيل مناسبتك',
          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AiFormFieldsWidget(
          fields:    s.formFields,
          values:    s.formValues,
          onChanged: (e) => ctx.read<AiDesignCubit>().updateFormValue(e.key, e.value),
        ),
      ],

      // Error
      if (s.generationError != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(
                _localizeError(s.generationError!, loc),
                style: const TextStyle(color: Colors.red),
              )),
            ]),
          ),
        ),

      // Custom prompt
      Text(
        loc?.translate('ai_custom_prompt_label') ?? 'تعليمات إضافية (اختياري)',
        style: Theme.of(ctx).textTheme.bodyMedium,
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _customPromptCtrl,
        maxLines: 3, minLines: 1,
        onChanged: (v) => ctx.read<AiDesignCubit>().updateCustomPrompt(v),
        decoration: InputDecoration(
          hintText: loc?.translate('ai_custom_prompt_hint') ?? 'مثال: استخدم ألوان ذهبية',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
      const SizedBox(height: 20),

      // Generate button
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: canGenerate && !s.isGenerating
              ? () => ctx.read<AiDesignCubit>().generatePrompt()
              : null,
          icon: const Icon(Icons.auto_awesome),
          label: Text(loc?.translate('ai_generate_btn') ?? 'توليد بالذكاء الاصطناعي'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ]);
  }

  String _localizeError(String error, AppLocalizations? loc) {
    if (error == 'timeout') return loc?.translate('ai_timeout_error') ?? 'انتهت المهلة. يرجى المحاولة مجدداً.';
    return error;
  }
}
