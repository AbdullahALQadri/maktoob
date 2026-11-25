import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../config/routes/app_routes.dart';
import '../../../../../core/core.dart';
import '../../../../ai_design/presentation/widgets/template_invitation_canvas.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';
import '../../widgets/details/design_cover_hero.dart';
import '../../widgets/wizard_step_frame.dart';

/// Step 3: the invitation's design — a ready one, the host's own image or a
/// new one, then the same editor as the web for the wording and colours.
class DesignStep extends StatefulWidget {
  const DesignStep({super.key});

  @override
  State<DesignStep> createState() => _DesignStepState();
}

class _DesignStepState extends State<DesignStep> with WidgetsBindingObserver {
  bool _editorOpen = false;
  bool _openingEditor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back from the editor: show what it saved.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_editorOpen) return;
    _editorOpen = false;
    context.read<InvitationCubit>().refreshDesign();
  }

  Future<void> _chooseDesign(InvitationState state) async {
    final eventId = state.draftEventId;
    final typeId = state.selectedEventType?.id;
    if (eventId == null || typeId == null || typeId <= 0) return;
    final texts = invitationTextsFromEvent(
      isArabic: context.languageCode == 'ar',
      typeFieldValues: state.eventTypeFormData,
      date: state.eventDate,
      hour: state.eventTime?.hour,
      minute: state.eventTime?.minute,
      venue: state.customLocation?.placeName ?? state.selectedVenue?.nameAr ?? '',
    );
    final result = await Navigator.of(context).pushNamed(
      Routes.aiDesign,
      arguments: {
        'eventId': eventId,
        'eventTypeId': typeId,
        'eventTitle': state.eventName ?? '',
        'names': texts.names,
        'dateTime': texts.dateTime,
        'venue': texts.venue,
      },
    );
    if (result is String && result.isNotEmpty && mounted) {
      context.read<InvitationCubit>().setAiGeneratedImage(result);
    }
  }

  Future<void> _openEditor() async {
    setState(() => _openingEditor = true);
    final url = await context.read<InvitationCubit>().editorUrl();
    if (!mounted) return;
    setState(() => _openingEditor = false);
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null) return;
    _editorOpen = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InvitationCubit>();
    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (before, now) => before.errorMessage != now.errorMessage && now.errorMessage != null,
      listener: showWizardError,
      builder: (context, state) {
        final hasDesign = (state.generatedImageUrl ?? '').isNotEmpty;
        // A custom occasion has no ready designs: the editor is its way in.
        final hasStudio = (state.selectedEventType?.id ?? 0) > 0;
        return WizardStepFrame(
          step: InvitationStep.design,
          actionLabel: context.tr('wizard_next_settings'),
          onAction: hasDesign ? cubit.nextStep : null,
          children: [
            Text(
              context.tr('wizard_design_title'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('wizard_design_subtitle'),
              style: TextStyle(fontSize: 14, height: 1.5, color: context.textSecondary),
            ),
            const SizedBox(height: 16),
            DesignCoverHero(
              imageUrl: state.generatedImageUrl,
              onTap: hasStudio ? () => _chooseDesign(state) : _openEditor,
            ),
            const SizedBox(height: 12),
            if (hasStudio)
              OutlinedButton.icon(
                onPressed: () => _chooseDesign(state),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: Text(context.tr(hasDesign ? 'ai_change_design' : 'wizard_design_choose')),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            if (hasDesign || !hasStudio) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _openingEditor ? null : _openEditor,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(context.tr('wizard_design_edit')),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('wizard_design_edit_hint'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: context.textSecondary),
              ),
            ],
          ],
        );
      },
    );
  }
}
