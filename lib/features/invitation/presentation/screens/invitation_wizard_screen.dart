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
import 'page1_event_setup_screen.dart';
import 'page2_guests_services_screen.dart';
import 'page3_review_submit_screen.dart';

/// Main container screen for the 3-page event creation wizard.
/// Manages navigation between pages based on the current step in the cubit state.
class InvitationWizardScreen extends StatefulWidget {
  /// Optional draft event ID to resume editing
  final int? draftEventId;

  /// Callback when user wants to login (optional)
  final VoidCallback? onLogin;

  /// Callback when user completes the wizard (optional)
  final VoidCallback? onComplete;

  /// Occasion type / starter design to preselect (e.g. what the visitor
  /// tapped in Explore before signing up). Ignored when resuming a draft.
  final int? initialEventTypeId;
  final int? initialTemplateId;

  const InvitationWizardScreen({
    super.key,
    this.draftEventId,
    this.onLogin,
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
        child: _InvitationWizardView(
          onLogin: widget.onLogin,
          onComplete: widget.onComplete,
        ),
      );
    }

    return _InvitationWizardView(
      onLogin: widget.onLogin,
      onComplete: widget.onComplete,
    );
  }
}

class _InvitationWizardView extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onComplete;

  const _InvitationWizardView({
    this.onLogin,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
      listener: (context, state) {
        // Handle navigation animations or other side effects when step changes
      },
      builder: (context, state) {
        return PopScope(
          canPop: state.currentStep == InvitationStep.eventSetup,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              // Go to previous step instead of closing
              context.read<InvitationCubit>().previousStep();
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildCurrentPage(context, state.currentStep),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPage(BuildContext context, InvitationStep step) {
    switch (step) {
      case InvitationStep.eventSetup:
        return const Page1EventSetupScreen(key: ValueKey('page1'));
      case InvitationStep.guestsAndServices:
        return const Page2GuestsServicesScreen(key: ValueKey('page2'));
      case InvitationStep.reviewAndSubmit:
        return Page3ReviewSubmitScreen(
            key: const ValueKey('page3'), onComplete: onComplete);
    }
  }
}

/// Extension to easily push the wizard from anywhere in the app
extension InvitationWizardNavigation on BuildContext {
  /// Opens the invitation wizard to create a new event
  void openInvitationWizard() {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (_) => const InvitationWizardScreen(),
      ),
    ).then((_) {
      if (mounted) refreshEventLists(this);
    });
  }

  /// Opens the invitation wizard to continue editing a draft event
  void openInvitationWizardWithDraft(int draftEventId) {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (_) => InvitationWizardScreen(draftEventId: draftEventId),
      ),
    ).then((_) {
      if (mounted) refreshEventLists(this);
    });
  }
}
