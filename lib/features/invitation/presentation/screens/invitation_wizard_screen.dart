import '../../../home/presentation/utils/refresh_event_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../authentication/presentation/cubit/auth_state.dart';
import '../../../institution/presentation/widgets/event_owner_sheet.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';
import 'steps/checkout_step.dart';
import 'steps/design_step.dart';
import 'steps/details_step.dart';
import 'steps/guests_step.dart';
import 'steps/settings_step.dart';

/// The event wizard: shows the screen of the step the host is on.
class InvitationWizardScreen extends StatefulWidget {
  /// Optional draft event ID to resume editing
  final int? draftEventId;

  /// Callback when user completes the wizard (optional)
  final VoidCallback? onComplete;

  /// Occasion type / starter design to preselect (e.g. what the visitor
  /// tapped in Explore before signing up). Ignored when resuming a draft.
  final int? initialEventTypeId;
  final int? initialTemplateId;

  const InvitationWizardScreen({
    super.key,
    this.draftEventId,
    this.onComplete,
    this.initialEventTypeId,
    this.initialTemplateId,
  });

  @override
  State<InvitationWizardScreen> createState() => _InvitationWizardScreenState();
}

class _InvitationWizardScreenState extends State<InvitationWizardScreen> {
  InvitationCubit? _cubit;
  bool _ownsOwnCubit = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization to didChangeDependencies where context is available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initializeCubit();
    }
  }

  void _initializeCubit() {
    // Try to find existing cubit from parent context
    try {
      _cubit = context.read<InvitationCubit>();
      _ownsOwnCubit = false;
      // Initialize wizard after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _start();
      });
    } catch (_) {
      // No cubit in context, create one
      _cubit = sl<InvitationCubit>();
      _ownsOwnCubit = true;
      _start();
    }
  }

  Future<void> _start() async {
    final cubit = _cubit!;
    if (widget.draftEventId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askEventOwner());
    }
    await cubit.initializeWizard(draftEventId: widget.draftEventId);
    if (widget.draftEventId == null &&
        (widget.initialEventTypeId != null || widget.initialTemplateId != null) &&
        !cubit.isClosed) {
      await cubit.applyPreselection(
        eventTypeId: widget.initialEventTypeId,
        templateId: widget.initialTemplateId,
      );
    }
  }

  /// Owner / manager of an approved institution: ask once whom the new
  /// event is for. The draft is created later with that `institution_id`.
  Future<void> _askEventOwner() async {
    if (!mounted) return;
    AuthState? auth;
    try {
      auth = context.read<AuthCubit>().state;
    } catch (_) {
      return; // no AuthCubit above (tests / standalone)
    }
    if (auth is! AuthAuthenticated) return;
    final choices = auth.user.eventOwnerChoices;
    if (choices.isEmpty) return;
    final picked = await showEventOwnerSheet(context, choices);
    final cubit = _cubit;
    if (cubit == null || cubit.isClosed) return;
    cubit.setEventOwner(
      institutionId: picked?.institutionId,
      institutionName: picked?.name,
      credits: picked?.credits,
    );
  }

  @override
  void dispose() {
    if (_ownsOwnCubit) {
      _cubit?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cubit == null) {
      return const WizardFormSkeleton();
    }

    if (_ownsOwnCubit) {
      return BlocProvider.value(
        value: _cubit!,
        child: _InvitationWizardView(onComplete: widget.onComplete),
      );
    }

    return _InvitationWizardView(onComplete: widget.onComplete);
  }
}

class _InvitationWizardView extends StatelessWidget {
  const _InvitationWizardView({this.onComplete});

  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<InvitationCubit, InvitationState, InvitationStep>(
      selector: (state) => state.currentStep,
      builder: (context, step) {
        return PopScope(
          // Back goes one step back; from the first step it leaves.
          canPop: step == InvitationStep.details,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.read<InvitationCubit>().previousStep();
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey(step),
              child: switch (step) {
                InvitationStep.details => const DetailsStep(),
                InvitationStep.guests => const GuestsStep(),
                InvitationStep.design => const DesignStep(),
                InvitationStep.settings => const SettingsStep(),
                InvitationStep.checkout => CheckoutStep(onComplete: onComplete),
              },
            ),
          ),
        );
      },
    );
  }
}

/// Opens the wizard from anywhere: a new event, or a draft to carry on.
extension InvitationWizardNavigation on BuildContext {
  void openInvitationWizard() => _openWizard(null);

  void openInvitationWizardWithDraft(int draftEventId) => _openWizard(draftEventId);

  void _openWizard(int? draftEventId) {
    Navigator.of(this)
        .push(MaterialPageRoute<void>(builder: (_) => InvitationWizardScreen(draftEventId: draftEventId)))
        // The new or changed event shows without a manual refresh.
        .then((_) => mounted ? refreshEventLists(this) : null);
  }
}
