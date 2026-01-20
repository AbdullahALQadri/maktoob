import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
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
    return BlocConsumer<InvitationCubit, InvitationState>(
      listener: (context, state) {
        // Show duplicate notification if duplicates were found and removed
        if (state.duplicatePhoneNumbers.isNotEmpty) {
          _showDuplicateDialog(context, state.duplicatePhoneNumbers);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Step Header
                const WizardStepHeader(
                  currentStep: 4,
                  totalSteps: 7,
                  title: 'إدارة المدعوين',
                ),

                // Guest Count Header
                _buildGuestCountHeader(state),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Import Options
                        _buildImportOptions(context, state),

                        const SizedBox(height: 20),

                        // Manual Form (Expandable)
                        if (_showManualForm) ...[
                          ManualGuestForm(
                            onGuestAdded: (guest) {
                              context
                                  .read<InvitationCubit>()
                                  .addManualGuest(guest);
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Guest List
                        _buildGuestList(context, state),
                      ],
                    ),
                  ),
                ),

                // Navigation Buttons
                _buildNavigationButtons(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestCountHeader(InvitationState state) {
    final totalGuests = state.allGuests.length;
    final contactsCount =
        state.contactsGuests.length;
    final excelCount = state.excelGuests.length;
    final manualCount = state.manualGuests.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.primary,
      child: Row(
        children: [
          const Icon(
            Icons.people,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي المدعوين: $totalGuests',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (totalGuests > 0)
                  Text(
                    'جهات الاتصال: $contactsCount | إكسل: $excelCount | يدوي: $manualCount',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportOptions(BuildContext context, InvitationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'طرق إضافة المدعوين',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Import option buttons
          Row(
            children: [
              // Contacts Button
              Expanded(
                child: _buildImportButton(
                  icon: Icons.contacts,
                  label: 'جهات الاتصال',
                  count: state.contactsGuests.length,
                  onPressed: () => _openContactPicker(context, state),
                ),
              ),
              const SizedBox(width: 12),

              // Excel Button
              Expanded(
                child: _buildImportButton(
                  icon: Icons.table_chart,
                  label: 'ملف إكسل',
                  count: state.excelGuests.length,
                  onPressed: state.isLoadingExcel
                      ? null
                      : () => _importExcel(context),
                  isLoading: state.isLoadingExcel,
                ),
              ),
              const SizedBox(width: 12),

              // Manual Button
              Expanded(
                child: _buildImportButton(
                  icon: Icons.edit,
                  label: 'إضافة يدوية',
                  count: state.manualGuests.length,
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'صيغة ملف الإكسل: اسم المدعو، رقم الهاتف (+972 أو +970)',
                    style: TextStyle(
                      fontSize: 12,
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
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            if (isLoading)
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              Icon(
                icon,
                size: 28,
                color: isActive ? AppColors.primary : Colors.grey.shade600,
              ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary : Colors.grey.shade700,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 11,
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

  Widget _buildGuestList(BuildContext context, InvitationState state) {
    final allGuests = state.allGuests;

    if (allGuests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.person_add_disabled,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لم تتم إضافة أي مدعوين بعد',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'استخدم الخيارات أعلاه لإضافة المدعوين',
              style: TextStyle(
                fontSize: 13,
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'قائمة المدعوين (${allGuests.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (allGuests.length > 1)
                  TextButton.icon(
                    onPressed: () => _showClearAllDialog(context),
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: const Text('مسح الكل'),
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
              return _buildGuestListItem(context, guest, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestListItem(
      BuildContext context, GuestInfoModel guest, int index) {
    IconData sourceIcon;
    Color sourceColor;
    String sourceLabel;

    switch (guest.source) {
      case GuestSource.contacts:
        sourceIcon = Icons.contacts;
        sourceColor = Colors.blue;
        sourceLabel = 'جهات الاتصال';
        break;
      case GuestSource.excel:
        sourceIcon = Icons.table_chart;
        sourceColor = Colors.green;
        sourceLabel = 'إكسل';
        break;
      case GuestSource.manual:
        sourceIcon = Icons.edit;
        sourceColor = Colors.orange;
        sourceLabel = 'يدوي';
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: sourceColor.withOpacity(0.1),
        child: Icon(
          sourceIcon,
          color: sourceColor,
          size: 20,
        ),
      ),
      title: Text(
        guest.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Row(
        children: [
          Text(
            guest.phone,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: sourceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              sourceLabel,
              style: TextStyle(
                fontSize: 10,
                color: sourceColor,
              ),
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        color: Colors.red.shade400,
        onPressed: () {
          context.read<InvitationCubit>().removeGuest(guest);
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

  Future<void> _importExcel(BuildContext context) async {
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
                Text('حدث خطأ أثناء تحميل الملف: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDuplicateDialog(BuildContext context, Set<String> duplicates) {
    if (duplicates.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 8),
            const Text('تم العثور على تكرارات'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تم حذف الأرقام المكررة التالية تلقائياً:',
              style: TextStyle(fontWeight: FontWeight.w500),
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
              'الأولوية: يدوي > إكسل > جهات الاتصال',
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
              Navigator.of(context).pop();
              // Clear duplicates after showing
              context.read<InvitationCubit>().clearDuplicateNotification();
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع المدعوين'),
        content: const Text('هل أنت متأكد من حذف جميع المدعوين من القائمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<InvitationCubit>().clearAllGuests();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, InvitationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Expanded(
            child: AppButton(
              text: 'السابق',
              onPressed: () {
                context.read<InvitationCubit>().previousStep();
              },
              backgroundColor: Colors.grey.shade200,
              textColor: Colors.black87,
            ),
          ),

          const SizedBox(width: 12),

          // Next Button
          Expanded(
            flex: 2,
            child: AppButton(
              text: 'التالي',
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
