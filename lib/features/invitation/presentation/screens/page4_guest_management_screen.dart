import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';

/// Page 4: Guest Management Screen
class Page4GuestManagementScreen extends StatefulWidget {
  const Page4GuestManagementScreen({super.key});

  @override
  State<Page4GuestManagementScreen> createState() =>
      _Page4GuestManagementScreenState();
}

class _Page4GuestManagementScreenState
    extends State<Page4GuestManagementScreen> {
  bool _showManualForm = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (previous, current) {
        return previous.duplicatePhoneNumbers.isEmpty &&
            current.duplicatePhoneNumbers.isNotEmpty;
      },
      listener: (context, state) {
        if (state.duplicatePhoneNumbers.isNotEmpty) {
          _showDuplicateDialog(context, state.duplicatePhoneNumbers, l);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                WizardStepHeader(
                  currentStep: 4,
                  totalSteps: 7,
                  title: l?.translate('invitation_step4_title') ??
                      'Guest Management',
                ),
                GuestCountHeader(state: state),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GuestImportOptions(
                          state: state,
                          showManualForm: _showManualForm,
                          onToggleManualForm: () => setState(() {
                            _showManualForm = !_showManualForm;
                          }),
                        ),
                        SizedBox(height: context.dynamicHeight(0.025)),
                        if (_showManualForm) ...[
                          ManualGuestForm(
                            onGuestAdded: (guest) {
                              context.read<InvitationCubit>().addManualGuest(guest);
                            },
                          ),
                          SizedBox(height: context.dynamicHeight(0.025)),
                        ],
                        GuestListSection(state: state),
                      ],
                    ),
                  ),
                ),
                WizardBottomBar(
                  canProceed: state.canProceedFromGuestManagement,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDuplicateDialog(
    BuildContext context,
    Set<String> duplicates,
    AppLocalizations? l,
  ) {
    if (duplicates.isEmpty) return;

    final cubit = context.read<InvitationCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Text(l?.translate('invitation_duplicates_found') ??
                'Duplicates Found'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l?.translate('invitation_duplicates_removed') ??
                  'The following duplicate numbers were automatically removed:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: duplicates
                      .map((phone) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.phone, size: 16),
                                const SizedBox(width: 8),
                                Text(phone),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l?.translate('invitation_priority_note') ??
                  'Priority: Manual > Excel > Contacts',
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.clearDuplicateNotification();
            },
            child: Text(l?.translate('common_ok') ?? 'OK'),
          ),
        ],
      ),
    );
  }
}
