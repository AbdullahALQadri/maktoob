import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import 'add_guests_screen.dart';
import 'confirmation_screen.dart';
import 'create_invitation_screen.dart';
import 'event_type_screen.dart';
import 'landing_screen.dart';
import 'package_selection_screen.dart';
import 'share_screen.dart';
import 'whatsapp_payment_screen.dart';

/// Main shell that orchestrates the Golden Scenario invitation flow
class InvitationFlowShell extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onGoToDashboard;

  const InvitationFlowShell({
    super.key,
    this.onLogin,
    this.onGoToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildCurrentScreen(state),
        );
      },
    );
  }

  Widget _buildCurrentScreen(InvitationState state) {
    switch (state.currentStep) {
      case InvitationStep.landing:
        return LandingScreen(
          key: const ValueKey('landing'),
          onLogin: onLogin,
        );

      case InvitationStep.eventType:
        return const EventTypeScreen(
          key: ValueKey('eventType'),
        );

      case InvitationStep.creation:
        return const CreateInvitationScreen(
          key: ValueKey('creation'),
        );

      case InvitationStep.guests:
        return const AddGuestsScreen(
          key: ValueKey('guests'),
        );

      case InvitationStep.share:
        return const ShareScreen(
          key: ValueKey('share'),
        );

      case InvitationStep.package:
        return const PackageSelectionScreen(
          key: ValueKey('package'),
        );

      case InvitationStep.payment:
        return const WhatsAppPaymentScreen(
          key: ValueKey('payment'),
        );

      case InvitationStep.confirmation:
        return ConfirmationScreen(
          key: const ValueKey('confirmation'),
          onGoToDashboard: onGoToDashboard,
          onCreateAnother: () {
            // Reset happens in the screen itself
          },
        );
    }
  }
}
