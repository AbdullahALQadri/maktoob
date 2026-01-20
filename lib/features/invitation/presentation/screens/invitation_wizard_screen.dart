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

  const InvitationWizardScreen({
    super.key,
    this.draftEventId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = sl<InvitationCubit>();
        // Initialize wizard (loads event types and optionally draft data)
        cubit.initializeWizard(draftEventId: draftEventId);
        return cubit;
      },
      child: const _InvitationWizardView(),
    );
  }
}

class _InvitationWizardView extends StatelessWidget {
  const _InvitationWizardView();

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
          child: _buildCurrentPage(state.currentStep),
        );
      },
    );
  }

  Widget _buildCurrentPage(InvitationStep step) {
    switch (step) {
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
        return const Page7InvoiceScreen();
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
