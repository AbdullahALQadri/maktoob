import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import 'page1_event_type_screen.dart';
import 'page2_event_details_screen.dart';
import 'page3_preview_screen.dart';
import 'page4_guest_management_screen.dart';
import 'page5_extra_services_screen.dart';
import 'page6_package_selection_screen.dart';
import 'page7_invoice_screen.dart';

/// Main container screen for the 7-page event creation wizard.
/// Manages navigation between pages based on the current step in the cubit state.
class InvitationWizardScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Try to find existing cubit from parent context
    InvitationCubit? existingCubit;
    try {
      existingCubit = context.read<InvitationCubit>();
    } catch (_) {
      // No cubit in context, will create one
    }

    if (existingCubit != null) {
      // Use existing cubit, just initialize wizard
      WidgetsBinding.instance.addPostFrameCallback((_) {
        existingCubit!.initializeWizard(draftEventId: draftEventId);
      });
      return _InvitationWizardView(
        onLogin: onLogin,
        onComplete: onComplete,
      );
    }

    // Create new cubit if none exists
    return BlocProvider(
      create: (context) {
        final cubit = sl<InvitationCubit>();
        cubit.initializeWizard(draftEventId: draftEventId);
        return cubit;
      },
      child: _InvitationWizardView(
        onLogin: onLogin,
        onComplete: onComplete,
      ),
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
          canPop: state.currentStep == InvitationStep.eventTypeSelection,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              // Go to previous step instead of closing
              context.read<InvitationCubit>().previousStep();
            }
          },
          child: _buildCurrentPage(context, state.currentStep),
        );
      },
    );
  }

  Widget _buildCurrentPage(BuildContext context, InvitationStep step) {
    switch (step) {
      // New wizard steps (7-page flow)
      case InvitationStep.eventTypeSelection:
        return const Page1EventTypeScreen();
      case InvitationStep.eventDetails:
        return const Page2EventDetailsScreen();
      case InvitationStep.invitationPreview:
        return const Page3PreviewScreen();
      case InvitationStep.guestManagement:
        return const Page4GuestManagementScreen();
      case InvitationStep.extraServices:
        return const Page5ExtraServicesScreen();
      case InvitationStep.packageSelection:
        return const Page6PackageSelectionScreen();
      case InvitationStep.invoiceSummary:
        return Page7InvoiceScreen(onComplete: onComplete);

      // Legacy steps - redirect to first page (these should not be used with new wizard)
      // ignore: deprecated_member_use_from_same_package
      case InvitationStep.landing:
      // ignore: deprecated_member_use_from_same_package
      case InvitationStep.eventType:
      // ignore: deprecated_member_use_from_same_package
      case InvitationStep.creation:
      // ignore: deprecated_member_use_from_same_package
      case InvitationStep.guests:
      // ignore: deprecated_member_use_from_same_package
      case InvitationStep.share:
      // ignore: deprecated_member_use_from_same_package
      case InvitationStep.package:
      // ignore: deprecated_member_use_from_same_package
      case InvitationStep.payment:
      // ignore: deprecated_member_use_from_same_package
      case InvitationStep.confirmation:
        // Reset to first wizard step
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context
              .read<InvitationCubit>()
              .goToStep(InvitationStep.eventTypeSelection);
        });
        return const Page1EventTypeScreen();
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
