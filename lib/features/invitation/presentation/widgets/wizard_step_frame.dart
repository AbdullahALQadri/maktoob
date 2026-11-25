import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/design/window_size.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import 'wizard_step_bar.dart';

/// The frame every wizard step shares: the app bar, the six-step bar, the
/// step's content in a readable column, and one main button at the bottom.
class WizardStepFrame extends StatelessWidget {
  const WizardStepFrame({
    super.key,
    required this.step,
    required this.children,
    required this.actionLabel,
    required this.onAction,
    this.isBusy = false,
    this.footer,
    this.scrollController,
  });

  final InvitationStep step;
  final List<Widget> children;
  final String actionLabel;

  /// Null keeps the button disabled (something is still missing).
  final VoidCallback? onAction;
  final bool isBusy;

  /// Replaces the single button (the last step has its own actions).
  final Widget? footer;
  final ScrollController? scrollController;

  static const double _column = 720;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InvitationCubit>();
    final width = MediaQuery.sizeOf(context).width;
    final side = width > _column + 32 ? (width - _column) / 2 : context.windowSize.gutter;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: MaktoobAppBar(
        title: context.tr('wizard_event_setup_app_bar'),
        onClose: () => Navigator.of(context).maybePop(),
        onForward: step == InvitationStep.details ? null : cubit.previousStep,
      ),
      body: Column(
        children: [
          WizardStepBar(current: step, onStepTap: isBusy ? null : cubit.goToStep),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsetsDirectional.fromSTEB(side, 20, side, 24),
              children: children,
            ),
          ),
          footer ??
              Container(
                padding: EdgeInsetsDirectional.fromSTEB(side, 12, side, 12),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  border: Border(top: BorderSide(color: context.borderColor)),
                ),
                child: SafeArea(
                  top: false,
                  child: PrimaryButton(
                    text: actionLabel,
                    icon: Icons.arrow_forward_rounded,
                    isLoading: isBusy,
                    onPressed: isBusy ? null : onAction,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Shows a wizard error once, in the user's language when it is a key.
void showWizardError(BuildContext context, InvitationState state) {
  final message = state.errorMessage;
  if (message == null) return;
  AppSnackBar.showError(context, message: context.tr(message));
  context.read<InvitationCubit>().clearError();
}
