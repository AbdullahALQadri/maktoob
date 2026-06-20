// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
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

  const InvitationWizardScreen({
    super.key,
    this.draftEventId,
    this.onLogin,
    this.onComplete,
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
        if (mounted) {
          _cubit!.initializeWizard(draftEventId: widget.draftEventId);
        }
      });
    } catch (_) {
      // No cubit in context, create one
      _cubit = sl<InvitationCubit>();
      _ownsOwnCubit = true;
      _cubit!.initializeWizard(draftEventId: widget.draftEventId);
    }
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
      // Modern 3-page wizard
      case InvitationStep.eventSetup:
        return const Page1EventSetupScreen(key: ValueKey('page1'));
      case InvitationStep.guestsAndServices:
        return const Page2GuestsServicesScreen(key: ValueKey('page2'));
      case InvitationStep.reviewAndSubmit:
        return Page3ReviewSubmitScreen(
            key: const ValueKey('page3'), onComplete: onComplete);

      // Legacy steps → redirect to modern equivalents
      case InvitationStep.eventTypeSelection:
      case InvitationStep.eventDetails:
      case InvitationStep.invitationPreview:
      case InvitationStep.landing:
      case InvitationStep.eventType:
      case InvitationStep.creation:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context
              .read<InvitationCubit>()
              .goToStep(InvitationStep.eventSetup);
        });
        return const Page1EventSetupScreen(key: ValueKey('page1'));

      case InvitationStep.guestManagement:
      case InvitationStep.extraServices:
      case InvitationStep.guests:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context
              .read<InvitationCubit>()
              .goToStep(InvitationStep.guestsAndServices);
        });
        return const Page2GuestsServicesScreen(key: ValueKey('page2'));

      case InvitationStep.packageSelection:
      case InvitationStep.invoiceSummary:
      case InvitationStep.share:
      case InvitationStep.package:
      case InvitationStep.payment:
      case InvitationStep.confirmation:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context
              .read<InvitationCubit>()
              .goToStep(InvitationStep.reviewAndSubmit);
        });
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
    );
  }

  /// Opens the invitation wizard to continue editing a draft event
  void openInvitationWizardWithDraft(int draftEventId) {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (_) => InvitationWizardScreen(draftEventId: draftEventId),
      ),
    );
  }
}
