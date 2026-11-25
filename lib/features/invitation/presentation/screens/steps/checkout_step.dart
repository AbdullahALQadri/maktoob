import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/core.dart';
import '../../../../../core/error/institution_errors.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';
import '../../widgets/checkout/activation_note.dart';
import '../../widgets/checkout/checkout_action_bar.dart';
import '../../widgets/checkout/checkout_flow.dart';
import '../../widgets/checkout/checkout_headers.dart';
import '../../widgets/checkout/final_preview_card.dart';
import '../../widgets/checkout/invoice_card.dart';
import '../../widgets/checkout/package_overview.dart';
import '../../widgets/wizard_step_frame.dart';

/// Step 5: the package, the invoice, then payment or activation.
class CheckoutStep extends StatefulWidget {
  const CheckoutStep({super.key, this.onComplete});

  final VoidCallback? onComplete;

  @override
  State<CheckoutStep> createState() => _CheckoutStepState();
}

class _CheckoutStepState extends State<CheckoutStep> {
  final _invoiceKey = GlobalKey();
  final _scroll = ScrollController();
  final _customLimit = TextEditingController();

  /// The package the invoice was last asked for, so choosing one asks once.
  int? _invoicePackageId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<InvitationCubit>();
      final limit = cubit.state.customPackageLimit;
      if (limit != null && limit > 0) _customLimit.text = '$limit';
      cubit.loadPackages();
    });
  }

  @override
  void dispose() {
    _customLimit.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toPackages() {
    if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
  }

  void _onChange(BuildContext context, InvitationState state) {
    final limit = state.customPackageLimit;
    if (limit != null && _customLimit.text != '$limit') _customLimit.text = '$limit';

    final packageId = state.selectedPackage?.id;
    if (packageId != null && packageId != _invoicePackageId) {
      _invoicePackageId = packageId;
      context.read<InvitationCubit>().loadInvoice();
    }

    if (state.saveSuccess) _onSaved(context, state);
    if (state.saveError != null) _onSaveError(context, state);
  }

  void _onSaved(BuildContext context, InvitationState state) {
    if (state.isSaveAsDraft) {
      AppSnackBar.showSuccess(
        context,
        message: context.tr('invitation_draft_saved_success'),
        duration: const Duration(seconds: 2),
      );
      closeWizard(context, widget.onComplete);
    } else if ((state.selectedPackage?.isFree ?? false) || state.paidByCredits) {
      showWizardSaved(context, widget.onComplete);
    } else {
      openWizardPayment(context, state, widget.onComplete);
    }
  }

  void _onSaveError(BuildContext context, InvitationState state) {
    final error = state.saveError!;
    // Only the "free trial already used" refusal offers the packages again;
    // anything else is an ordinary error and the button stays to retry.
    if (state.saveErrorIsFreeTrial && !state.isSaveAsDraft) {
      showFreeTrialRefused(context, error, _toPackages);
    } else {
      AppSnackBar.showError(
        context,
        message: error == kInstitutionNotApprovedMessageKey ? context.tr(error) : error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.languageCode == 'en';
    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (before, now) =>
          before.customPackageLimit != now.customPackageLimit ||
          before.saveSuccess != now.saveSuccess ||
          before.saveError != now.saveError ||
          before.selectedPackage?.id != now.selectedPackage?.id,
      listener: _onChange,
      builder: (context, state) {
        return WizardStepFrame(
          step: InvitationStep.checkout,
          scrollController: _scroll,
          actionLabel: '',
          onAction: null,
          isBusy: state.isSaving,
          footer: CheckoutActionBar(state: state, invoiceKey: _invoiceKey, onComplete: widget.onComplete),
          children: [
            CheckoutPageHeader(
              title: context.tr('wizard_review_title'),
              subtitle: context.tr('wizard_review_subtitle'),
            ),
            const SizedBox(height: 20),
            CheckoutSectionLabel(text: context.tr('wizard_selected_package')),
            const SizedBox(height: 10),
            PackageOverview(state: state, isEnglish: isEnglish, customLimitController: _customLimit),
            const SizedBox(height: 20),
            InvoiceCard(state: state, invoiceKey: _invoiceKey, isEnglish: isEnglish),
            const SizedBox(height: 16),
            const ActivationNote(),
            const SizedBox(height: 20),
            FinalPreviewCard(state: state),
          ],
        );
      },
    );
  }
}
