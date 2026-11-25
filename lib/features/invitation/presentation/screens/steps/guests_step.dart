import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/core.dart';
import '../../../../guest_groups/presentation/widgets/group_picker_sheet.dart';
import '../../../data/models/invitation_draft_model.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';
import '../../widgets/guests/duplicate_guests_dialog.dart';
import '../../widgets/widgets.dart';

/// Step 2: who is invited — typed one by one, from contacts or from Excel.
class GuestsStep extends StatefulWidget {
  const GuestsStep({super.key});

  @override
  State<GuestsStep> createState() => _GuestsStepState();
}

class _GuestsStepState extends State<GuestsStep> {
  bool _showManualForm = false;

  /// The chosen package's allowance; null when none is picked or it is unlimited.
  static int? _limit(InvitationState state) {
    final package = state.selectedPackage;
    if (package == null) return null;
    if (package.isCustom) return state.customPackageLimit;
    return package.hasUnlimitedInvitations ? null : package.invitationLimit;
  }

  /// A saved group: its people join the list (repeated numbers are dropped).
  Future<void> _fromGroups() async {
    final cubit = context.read<InvitationCubit>();
    final group = await showGroupPickerSheet(context);
    if (group == null || !mounted) return;
    final added = cubit.addSavedGuests([
      for (final guest in group.guests) GuestInfoModel(name: guest.name, phone: guest.phone ?? ''),
    ]);
    AppSnackBar.showSuccess(context, message: context.tr('groups_added', {'count': added}));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InvitationCubit>();
    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (before, now) =>
          (before.duplicatePhoneNumbers.isEmpty && now.duplicatePhoneNumbers.isNotEmpty) ||
          (before.errorMessage != now.errorMessage && now.errorMessage != null),
      listener: (context, state) {
        showDuplicateGuestsDialog(context, state.duplicatePhoneNumbers);
        showWizardError(context, state);
      },
      builder: (context, state) {
        final limit = _limit(state);
        return WizardStepFrame(
          step: InvitationStep.guests,
          actionLabel: context.tr('wizard_next_design'),
          isBusy: state.isLoading,
          onAction: state.guests.isEmpty ? null : cubit.saveGuestsAndProceed,
          children: [
            GuestImportOptions(
              state: state,
              showManualForm: _showManualForm,
              onToggleManualForm: () => setState(() => _showManualForm = !_showManualForm),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              key: const Key('guests_from_groups'),
              onPressed: _fromGroups,
              icon: const Icon(Icons.groups_outlined, size: 18),
              label: Text(context.tr('groups_from_groups')),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_showManualForm) ...[
              ManualGuestForm(onGuestAdded: cubit.addManualGuest),
              const SizedBox(height: AppSpacing.md),
            ],
            // Once a package is picked, show what is left of its allowance.
            InvitationQuotaNote(limit: limit, remaining: (limit ?? 0) - state.totalGuestCount),
            GuestListSection(state: state),
          ],
        );
      },
    );
  }
}
