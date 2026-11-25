import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import 'contact_picker_widget.dart';
import 'guest_import_parts.dart';

/// Import options section for adding guests from contacts, excel, or manual entry.
class GuestImportOptions extends StatelessWidget {
  final InvitationState state;
  final bool showManualForm;
  final VoidCallback onToggleManualForm;

  const GuestImportOptions({
    super.key,
    required this.state,
    required this.showManualForm,
    required this.onToggleManualForm,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.024),
            offset: Offset(0, context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l?.translate('invitation_add_guests_methods') ??
                'Guest Import Methods',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.04),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          Row(
            children: [
              Expanded(
                child: GuestImportButton(
                  icon: Icons.contacts,
                  label:
                      l?.translate('invitation_from_contacts') ?? 'From Contacts',
                  count: state.guests
                      .where((g) => g.source == GuestSource.contacts)
                      .length,
                  onPressed: () => _openContactPicker(context),
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.029)),
              Expanded(
                child: GuestImportButton(
                  icon: Icons.table_chart,
                  label: l?.translate('invitation_excel_file') ?? 'Excel File',
                  count: state.guests
                      .where((g) => g.source == GuestSource.excel)
                      .length,
                  onPressed:
                      state.isLoadingExcel ? null : () => _importExcel(context, l),
                  isLoading: state.isLoadingExcel,
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.029)),
              Expanded(
                child: GuestImportButton(
                  icon: Icons.edit,
                  label:
                      l?.translate('invitation_manual_entry') ?? 'Manual Entry',
                  count: state.guests
                      .where((g) => g.source == GuestSource.manual)
                      .length,
                  onPressed: onToggleManualForm,
                  isActive: showManualForm,
                ),
              ),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          ExcelFormatNotice(l: l),
        ],
      ),
    );
  }

  void _openContactPicker(BuildContext context) {
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
    final cubit = context.read<InvitationCubit>();
    final errorLabel =
        l?.translate('invitation_error_loading_file') ?? 'Error loading file';

    try {
      // No storage permission: the system file picker (SAF on Android,
      // document picker on iOS) grants access to the chosen file. Asking for
      // READ_EXTERNAL_STORAGE / MANAGE_EXTERNAL_STORAGE blocked the import on
      // Android 13+, where those are always denied.
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (!context.mounted) return;

      final path = picked?.path;
      if (path != null) cubit.importGuestsFromExcel(File(path));
    } catch (e) {
      if (!context.mounted) return;

      AppSnackBar.showError(
        context,
        message: '$errorLabel: $e',
      );
    }
  }
}
