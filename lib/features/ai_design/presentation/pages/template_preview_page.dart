import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/ai_image_model.dart';
import '../cubit/ai_design_cubit.dart';
import '../cubit/ai_design_state.dart';
import '../widgets/template_invitation_canvas.dart';

/// "Ready template": the chosen text-free background with the event's texts
/// laid over it. Nothing is generated — on confirm the composed invitation is
/// exported to a 1080×1920 PNG on-device and saved as the event design.
class TemplatePreviewPage extends StatefulWidget {
  final AiImageModel template;
  final InvitationTexts initialTexts;

  const TemplatePreviewPage({
    super.key,
    required this.template,
    required this.initialTexts,
  });

  @override
  State<TemplatePreviewPage> createState() => _TemplatePreviewPageState();
}

class _TemplatePreviewPageState extends State<TemplatePreviewPage> {
  final _boundaryKey = GlobalKey();
  late InvitationTexts _texts = widget.initialTexts;
  late final ImageProvider _bg = CachedNetworkImageProvider(
    widget.template.imageUrl,
  );
  bool _bgReady = false;
  bool _bgFailed = false;
  bool _exporting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bgReady && !_bgFailed) {
      precacheImage(
        _bg,
        context,
        onError: (_, _) {
          if (mounted) setState(() => _bgFailed = true);
        },
      ).then((_) {
        if (mounted && !_bgFailed) setState(() => _bgReady = true);
      });
    }
  }

  Future<void> _useDesign() async {
    final loc = AppLocalizations.of(context);
    setState(() => _exporting = true);
    try {
      final boundary =
          _boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/invitation_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      if (!mounted) return;
      await context.read<AiDesignCubit>().uploadCustomImage(file);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: loc?.translate('ai_upload_failed') ?? 'فشل رفع الصورة',
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocConsumer<AiDesignCubit, AiDesignState>(
      listener: (ctx, state) {
        if (state is AiDesignReady && state.generationError != null) {
          AppSnackBar.showError(
            ctx,
            message: loc?.translate('ai_upload_failed') ?? 'فشل رفع الصورة',
          );
        }
      },
      builder: (ctx, state) {
        final busy =
            _exporting ||
            (state is AiDesignReady && state.isUploading) ||
            state is AiImageSaved;
        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          appBar: MaktoobAppBar(
            title:
                loc?.translate('ai_template_preview_title') ?? 'معاينة الدعوة',
            onClose: busy ? null : () => Navigator.of(ctx).pop(),
          ),
          body: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.mdl,
              AppSpacing.sm,
              AppSpacing.mdl,
              AppSpacing.lg,
            ),
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: SizedBox(
                    width: TemplateInvitationCanvas.canvasWidth * 0.8,
                    height: TemplateInvitationCanvas.canvasHeight * 0.8,
                    child: _bgFailed
                        ? Center(
                            child: Text(
                              loc?.translate('ai_upload_failed') ??
                                  'فشل تحميل القالب',
                              style: TextStyle(color: AppColors.gray500),
                            ),
                          )
                        : !_bgReady
                        ? const Center(child: AppLoader())
                        : FittedBox(
                            child: RepaintBoundary(
                              key: _boundaryKey,
                              child: TemplateInvitationCanvas(
                                background: _bg,
                                texts: _texts,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                loc?.translate('ai_template_edit_texts') ??
                    'تعديل النصوص (اختياري)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.smd),
              _field(
                loc,
                'ai_template_field_title',
                'العنوان',
                _texts.title,
                (v) => setState(() => _texts = _texts.copyWith(title: v)),
              ),
              _field(
                loc,
                'ai_template_field_names',
                'الأسماء',
                _texts.names,
                (v) => setState(() => _texts = _texts.copyWith(names: v)),
              ),
              _field(
                loc,
                'ai_template_field_date',
                'التاريخ والوقت',
                _texts.dateTime,
                (v) => setState(() => _texts = _texts.copyWith(dateTime: v)),
              ),
              _field(
                loc,
                'ai_template_field_venue',
                'المكان',
                _texts.venue,
                (v) => setState(() => _texts = _texts.copyWith(venue: v)),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.mdl,
                AppSpacing.smd,
                AppSpacing.mdl,
                AppSpacing.smd,
              ),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (!_bgReady || busy) ? null : _useDesign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.gray300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: busy
                      ? Text(
                          loc?.translate('ai_uploading') ?? 'جاري الحفظ...',
                          style: const TextStyle(color: AppColors.white),
                        )
                      : Text(
                          loc?.translate('ai_template_use') ??
                              'اعتماد هذا التصميم',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field(
    AppLocalizations? loc,
    String key,
    String fallback,
    String initial,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.smd),
      child: TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: loc?.translate(key) ?? fallback,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.gray200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.gray200),
          ),
        ),
      ),
    );
  }
}
