import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/contact_picker_widget.dart';
import '../widgets/manual_guest_form.dart';
import '../widgets/wizard_step_header.dart';

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
        // Only show dialog when duplicates are newly detected
        // (previous was empty and current is not, or current has more duplicates)
        return previous.duplicatePhoneNumbers.isEmpty &&
            current.duplicatePhoneNumbers.isNotEmpty;
      },
      listener: (context, state) {
        // Show duplicate notification if duplicates were found and removed
        if (state.duplicatePhoneNumbers.isNotEmpty) {
          _showDuplicateDialog(context, state.duplicatePhoneNumbers, l);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Step Header
                WizardStepHeader(
                  currentStep: 4,
                  totalSteps: 7,
                  title: l?.translate('invitation_step4_title') ?? 'Guest Management',
                ),

                // Guest Count Header
                _buildGuestCountHeader(context, state, l),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Import Options
                        _buildImportOptions(context, state, l),

                        SizedBox(height: context.dynamicHeight(0.025)),

                        // Manual Form (Expandable)
                        if (_showManualForm) ...[
                          ManualGuestForm(
                            onGuestAdded: (guest) {
                              context
                                  .read<InvitationCubit>()
                                  .addManualGuest(guest);
                            },
                          ),
                          SizedBox(height: context.dynamicHeight(0.025)),
                        ],

                        // Guest List
                        _buildGuestList(context, state, l),
                      ],
                    ),
                  ),
                ),

                // Navigation Buttons
                _buildNavigationButtons(context, state, l),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestCountHeader(BuildContext context, InvitationState state, AppLocalizations? l) {
    final totalGuests = state.allGuests.length;
    // Count from the actual deduplicated guests list, not the source lists
    final contactsCount =
        state.allGuests.where((g) => g.source == GuestSource.contacts).length;
    final excelCount =
        state.allGuests.where((g) => g.source == GuestSource.excel).length;
    final manualCount =
        state.allGuests.where((g) => g.source == GuestSource.manual).length;

    final contactsLabel = l?.translate('invitation_contacts') ?? 'Contacts';
    final excelLabel = l?.translate('invitation_excel') ?? 'Excel';
    final manualLabel = l?.translate('invitation_manual') ?? 'Manual';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.015),
      ),
      color: AppColors.primary,
      child: Row(
        children: [
          Icon(
            Icons.people,
            color: Colors.white,
            size: context.dynamicWidth(0.07),
          ),
          SizedBox(width: context.dynamicWidth(0.03)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l?.translate('invitation_total_guests') ?? 'Total Guests'}: $totalGuests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.dynamicWidth(0.045),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (totalGuests > 0)
                  Text(
                    '$contactsLabel: $contactsCount | $excelLabel: $excelCount | $manualLabel: $manualCount',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: context.dynamicWidth(0.03),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportOptions(BuildContext context, InvitationState state, AppLocalizations? l) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.025),
            offset: Offset(0, context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l?.translate('invitation_add_guests_methods') ?? 'Guest Import Methods',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.04),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),

          // Import option buttons
          Row(
            children: [
              // Contacts Button - count from deduplicated list
              Expanded(
                child: _buildImportButton(
                  context: context,
                  icon: Icons.contacts,
                  label: l?.translate('invitation_from_contacts') ?? 'From Contacts',
                  count: state.allGuests
                      .where((g) => g.source == GuestSource.contacts)
                      .length,
                  onPressed: () => _openContactPicker(context, state),
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.03)),

              // Excel Button - count from deduplicated list
              Expanded(
                child: _buildImportButton(
                  context: context,
                  icon: Icons.table_chart,
                  label: l?.translate('invitation_excel_file') ?? 'Excel File',
                  count: state.allGuests
                      .where((g) => g.source == GuestSource.excel)
                      .length,
                  onPressed: state.isLoadingExcel
                      ? null
                      : () => _importExcel(context, l),
                  isLoading: state.isLoadingExcel,
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.03)),

              // Manual Button - count from deduplicated list
              Expanded(
                child: _buildImportButton(
                  context: context,
                  icon: Icons.edit,
                  label: l?.translate('invitation_manual_entry') ?? 'Manual Entry',
                  count: state.allGuests
                      .where((g) => g.source == GuestSource.manual)
                      .length,
                  onPressed: () {
                    setState(() {
                      _showManualForm = !_showManualForm;
                    });
                  },
                  isActive: _showManualForm,
                ),
              ),
            ],
          ),

          // Excel format notice
          SizedBox(height: context.dynamicHeight(0.015)),
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.03)),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.02)),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: context.dynamicWidth(0.045),
                  color: Colors.amber.shade800,
                ),
                SizedBox(width: context.dynamicWidth(0.02)),
                Expanded(
                  child: Text(
                    l?.translate('invitation_excel_format_notice') ?? 'Excel format: Guest name, Phone number (+972 or +970)',
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.03),
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.dynamicHeight(0.02),
          horizontal: context.dynamicWidth(0.02),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            if (isLoading)
              SizedBox(
                width: context.dynamicWidth(0.07),
                height: context.dynamicWidth(0.07),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              Icon(
                icon,
                size: context.dynamicWidth(0.07),
                color: isActive ? AppColors.primary : Colors.grey.shade600,
              ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.03),
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary : Colors.grey.shade700,
              ),
            ),
            if (count > 0) ...[
              SizedBox(height: context.dynamicHeight(0.005)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.02),
                  vertical: context.dynamicHeight(0.003),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.025)),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.028),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuestList(BuildContext context, InvitationState state, AppLocalizations? l) {
    final allGuests = state.allGuests;

    if (allGuests.isEmpty) {
      return Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.1)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.person_add_disabled,
              size: context.dynamicWidth(0.16),
              color: Colors.grey.shade400,
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              l?.translate('invitation_no_guests_yet') ?? 'No guests added yet',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.04),
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              l?.translate('invitation_use_options_above') ?? 'Use the options above to add guests',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.033),
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.025),
            offset: Offset(0, context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(context.dynamicWidth(0.04)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l?.translate('invitation_guest_list') ?? 'Guest List'} (${allGuests.length})',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (allGuests.length > 1)
                  TextButton.icon(
                    onPressed: () {
                      final cubit = context.read<InvitationCubit>();
                      _showClearAllDialog(context, cubit, l);
                    },
                    icon: Icon(Icons.delete_sweep, size: context.dynamicWidth(0.045)),
                    label: Text(l?.translate('invitation_clear_all') ?? 'Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Guest list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allGuests.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final guest = allGuests[index];
              return _buildGuestListItem(context, guest, index, l);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestListItem(
      BuildContext context, GuestInfoModel guest, int index, AppLocalizations? l) {
    IconData sourceIcon;
    Color sourceColor;
    String sourceLabel;

    switch (guest.source) {
      case GuestSource.contacts:
        sourceIcon = Icons.contacts;
        sourceColor = Colors.blue;
        sourceLabel = l?.translate('invitation_contacts') ?? 'Contacts';
        break;
      case GuestSource.excel:
        sourceIcon = Icons.table_chart;
        sourceColor = Colors.green;
        sourceLabel = l?.translate('invitation_excel') ?? 'Excel';
        break;
      case GuestSource.manual:
        sourceIcon = Icons.edit;
        sourceColor = Colors.orange;
        sourceLabel = l?.translate('invitation_manual') ?? 'Manual';
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        radius: context.dynamicWidth(0.05),
        backgroundColor: sourceColor.withValues(alpha: 0.1),
        child: Icon(
          sourceIcon,
          color: sourceColor,
          size: context.dynamicWidth(0.05),
        ),
      ),
      title: Text(
        guest.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: context.dynamicWidth(0.038),
        ),
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              guest.phone,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.033),
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.02)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.015),
              vertical: context.dynamicHeight(0.003),
            ),
            decoration: BoxDecoration(
              color: sourceColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.01)),
            ),
            child: Text(
              sourceLabel,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.025),
                color: sourceColor,
              ),
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.remove_circle_outline,
          size: context.dynamicWidth(0.06),
        ),
        color: Colors.red.shade400,
        onPressed: () {
          context.read<InvitationCubit>().removeGuestByModel(guest);
        },
      ),
    );
  }

  void _openContactPicker(BuildContext context, InvitationState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<InvitationCubit>(),
          child: ContactPickerWidget(
            previouslySelected: state.contactsGuests,
            onContactsSelected: (contacts) {
              context.read<InvitationCubit>().addContactGuests(contacts);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _importExcel(BuildContext context, AppLocalizations? l) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (mounted) {
          context.read<InvitationCubit>().importGuestsFromExcel(file);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('${l?.translate('invitation_error_loading_file') ?? 'Error loading file'}: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDuplicateDialog(BuildContext context, Set<String> duplicates, AppLocalizations? l) {
    if (duplicates.isEmpty) return;

    // Capture the cubit before showing dialog since dialog context won't have access to it
    final cubit = context.read<InvitationCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 8),
            Text(l?.translate('invitation_duplicates_found') ?? 'Duplicates Found'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l?.translate('invitation_duplicates_removed') ?? 'The following duplicate numbers were automatically removed:',
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
              l?.translate('invitation_priority_note') ?? 'Priority: Manual > Excel > Contacts',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Clear duplicates after showing
              cubit.clearDuplicateNotification();
            },
            child: Text(l?.translate('common_ok') ?? 'OK'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, InvitationCubit cubit, AppLocalizations? l) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l?.translate('invitation_clear_all_guests') ?? 'Clear All Guests'),
        content: Text(l?.translate('invitation_confirm_clear_all') ?? 'Are you sure you want to remove all guests from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l?.translate('common_cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              cubit.clearAllGuests();
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l?.translate('invitation_clear_all') ?? 'Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, InvitationState state, AppLocalizations? l) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.025),
            offset: Offset(0, -context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Expanded(
            child: AppButton(
              text: l?.translate('common_back') ?? 'Back',
              onPressed: () {
                context.read<InvitationCubit>().previousStep();
              },
              backgroundColor: Colors.grey.shade200,
              textColor: Colors.black87,
            ),
          ),

          SizedBox(width: context.dynamicWidth(0.03)),

          // Next Button
          Expanded(
            flex: 2,
            child: AppButton(
              text: l?.translate('common_next') ?? 'Next',
              onPressed: state.canProceedFromGuestManagement
                  ? () {
                      context.read<InvitationCubit>().nextStep();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
