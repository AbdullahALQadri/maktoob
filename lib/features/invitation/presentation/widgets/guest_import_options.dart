import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import 'contact_picker_widget.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                child: _ImportButton(
                  icon: Icons.contacts,
                  label:
                      l?.translate('invitation_from_contacts') ?? 'From Contacts',
                  count: state.allGuests
                      .where((g) => g.source == GuestSource.contacts)
                      .length,
                  onPressed: () => _openContactPicker(context),
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.029)),
              Expanded(
                child: _ImportButton(
                  icon: Icons.table_chart,
                  label: l?.translate('invitation_excel_file') ?? 'Excel File',
                  count: state.allGuests
                      .where((g) => g.source == GuestSource.excel)
                      .length,
                  onPressed:
                      state.isLoadingExcel ? null : () => _importExcel(context, l),
                  isLoading: state.isLoadingExcel,
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.029)),
              Expanded(
                child: _ImportButton(
                  icon: Icons.edit,
                  label:
                      l?.translate('invitation_manual_entry') ?? 'Manual Entry',
                  count: state.allGuests
                      .where((g) => g.source == GuestSource.manual)
                      .length,
                  onPressed: onToggleManualForm,
                  isActive: showManualForm,
                ),
              ),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          _ExcelFormatNotice(l: l),
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
      // Request storage permission for Android
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), use photos and media permissions
        // For older Android, use storage permission
        PermissionStatus status;

        // Try to get storage permission first
        status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        // If storage denied, try manage external storage for Android 11+
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.status;
          if (!status.isGranted) {
            status = await Permission.manageExternalStorage.request();
          }
        }

        // Handle permanently denied
        if (status.isPermanentlyDenied) {
          if (!context.mounted) return;
          _showPermissionDeniedDialog(context, l);
          return;
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (!context.mounted) return;

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        cubit.importGuestsFromExcel(file);
      }
    } catch (e) {
      if (!context.mounted) return;

      AppSnackBar.showError(
        context,
        message: '$errorLabel: $e',
      );
    }
  }

  void _showPermissionDeniedDialog(BuildContext context, AppLocalizations? l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l?.translate('invitation_permission_required') ?? 'Permission Required',
        ),
        content: Text(
          l?.translate('invitation_storage_permission_denied') ??
              'Storage permission is required to import Excel files. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l?.translate('common_cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: Text(l?.translate('common_settings') ?? 'Settings'),
          ),
        ],
      ),
    );
  }
}

class _ImportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isActive;

  const _ImportButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.onPressed,
    this.isLoading = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.dynamicHeight(0.02),
          horizontal: context.dynamicWidth(0.021),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : context.overlayBg,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          border: Border.all(
            color: isActive ? AppColors.primary : context.borderColor,
          ),
        ),
        child: Column(
          children: [
            if (isLoading)
              SizedBox(
                width: context.dynamicWidth(0.069),
                height: context.dynamicWidth(0.069),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              Icon(
                icon,
                size: context.dynamicWidth(0.069),
                color: isActive ? AppColors.primary : context.textSecondary,
              ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary : context.textTertiary,
              ),
            ),
            if (count > 0) ...[
              SizedBox(height: context.dynamicHeight(0.005)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.021),
                  vertical: context.dynamicHeight(0.002),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.029),
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
}

class _ExcelFormatNotice extends StatelessWidget {
  final AppLocalizations? l;

  const _ExcelFormatNotice({this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.029)),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: context.dynamicWidth(0.045),
            color: Colors.amber.shade800,
          ),
          SizedBox(width: context.dynamicWidth(0.021)),
          Expanded(
            child: Text(
              l?.translate('invitation_excel_format_notice') ??
                  'Excel format: Guest name, Phone number (+972 or +970)',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
