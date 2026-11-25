import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../config/routes/app_routes.dart';
import '../../../../../core/core.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';

/// The invoice total as the review shows it. The backend's invoice wins; the
/// on-device sum is only a fallback before it loads. Prices are final (no tax).
double wizardInvoiceTotal(InvitationState state) {
  final summary = state.invoiceSummary;
  if (summary != null && summary.totalPrice > 0) return summary.totalPrice;
  final package = summary?.basePrice ?? state.selectedPackage?.effectivePrice ?? 0.0;
  final extras = summary?.servicesTotal ?? state.selectedServices.fold<double>(0, (sum, s) => sum + s.price);
  return package + extras;
}

/// Leaves the wizard: the caller's own way out, or one page back.
void closeWizard(BuildContext context, VoidCallback? onComplete) {
  if (onComplete != null) return onComplete();
  final navigator = Navigator.of(context);
  if (navigator.canPop()) navigator.pop();
}

/// A paid event was saved (awaiting payment): on to the payment screen.
void openWizardPayment(BuildContext context, InvitationState state, VoidCallback? onComplete) {
  final navigator = Navigator.of(context);
  navigator.pushNamed(
    Routes.payment,
    arguments: {
      'eventId': state.savedEventId ?? state.draftEventId?.toString(),
      'amount': state.savedInvoiceTotal ?? wizardInvoiceTotal(state),
      'eventTitle': state.eventName,
      'onComplete': () {
        navigator.pop(); // the payment screen
        if (onComplete != null) {
          onComplete();
        } else if (navigator.canPop()) {
          navigator.pop(); // the wizard
        }
      },
    },
  );
}

/// The free trial was refused (one per phone number): say so in the
/// server's words and send the host back to the packages.
void showFreeTrialRefused(BuildContext context, String message, VoidCallback onChoosePackage) {
  showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      key: const Key('free_trial_refused'),
      content: Text(message, style: const TextStyle(fontSize: 15, height: 1.6)),
      actions: [
        PrimaryButton(
          text: context.tr('wizard_choose_package'),
          onPressed: () {
            Navigator.of(dialog).pop();
            onChoosePackage();
          },
        ),
      ],
    ),
  );
}

/// A free event (or one paid from the institution's balance) is active now.
void showWizardSaved(BuildContext context, VoidCallback? onComplete) {
  final state = context.read<InvitationCubit>().state;
  final free = state.selectedPackage?.isFree ?? false;
  // Only claim the invoice went out when there was a number to send it to.
  final noNumber = !free && state.whatsappNumber == null;
  final noteKey = noNumber ? 'invitation_whatsapp_unavailable' : 'invitation_sent_via_whatsapp';

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialog) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.green100,
            child: Icon(Icons.check_circle, size: 44, color: AppColors.green600),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('invitation_saved_successfully'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(noteKey),
            key: Key(noteKey),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.textSecondary),
          ),
        ],
      ),
      actions: [
        PrimaryButton(
          text: context.tr('invitation_back_to_home'),
          onPressed: () {
            Navigator.of(dialog).pop();
            closeWizard(context, onComplete);
          },
        ),
      ],
    ),
  );
}
