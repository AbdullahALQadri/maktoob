import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/edit_event/edit_event_cubit.dart';
import '../cubit/edit_event/edit_event_state.dart';
import '../widgets/edit_request_banner.dart';
import '../widgets/edit_request_status_card.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _nameController;
  late TextEditingController _venueController;
  late TextEditingController _venueAddressController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxCompanionsController;

  @override
  void initState() {
    super.initState();
    final state = context.read<EditEventCubit>().state;
    _nameController = TextEditingController(text: state.name);
    _venueController = TextEditingController(text: state.venue);
    _venueAddressController =
        TextEditingController(text: state.venueAddress ?? '');
    _descriptionController =
        TextEditingController(text: state.description ?? '');
    _maxCompanionsController =
        TextEditingController(text: state.maxCompanions.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _venueAddressController.dispose();
    _descriptionController.dispose();
    _maxCompanionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocConsumer<EditEventCubit, EditEventState>(
      listener: (context, state) {
        if (state.status == EditEventStatus.saved) {
          AppSnackBar.showSuccess(context,
              message: t.translate('edit_event_saved'));
          Navigator.pop(context, true);
        } else if (state.status == EditEventStatus.requestSubmitted) {
          AppSnackBar.showSuccess(context,
              message: t.translate('edit_event_request_submitted'));
          Navigator.pop(context, true);
        } else if (state.status == EditEventStatus.failure &&
            state.errorMessage != null) {
          AppSnackBar.showError(context, message: state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.overlayBg,
          appBar: AppBar(
            title: Text(
              t.translate('edit_event_title'),
              style: AppTextStyles.titleMedium,
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: state.isSaving || !state.hasChanges
                      ? null
                      : () => context.read<EditEventCubit>().saveChanges(),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          state.isDraft
                              ? t.translate('common_save')
                              : t.translate('edit_event_submit_request'),
                          style: TextStyle(
                            color: state.hasChanges
                                ? AppColors.primaryColor
                                : AppColors.gray400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!state.isDraft) const EditRequestBanner(),
                _buildTextField(
                  label: t.translate('edit_event_name'),
                  controller: _nameController,
                  onChanged: context.read<EditEventCubit>().updateName,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: t.translate('edit_event_venue'),
                  controller: _venueController,
                  onChanged: context.read<EditEventCubit>().updateVenue,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: t.translate('edit_event_venue_address'),
                  controller: _venueAddressController,
                  onChanged:
                      context.read<EditEventCubit>().updateVenueAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: t.translate('edit_event_description'),
                  controller: _descriptionController,
                  onChanged:
                      context.read<EditEventCubit>().updateDescription,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  context: context,
                  label: t.translate('edit_event_date'),
                  value: state.eventDate,
                  onChanged: context.read<EditEventCubit>().updateEventDate,
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  context: context,
                  label: t.translate('edit_event_rsvp_deadline'),
                  value: state.rsvpDeadline,
                  onChanged:
                      context.read<EditEventCubit>().updateRsvpDeadline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: t.translate('edit_event_max_companions'),
                  controller: _maxCompanionsController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      context.read<EditEventCubit>().updateMaxCompanions(parsed);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildSwitchField(
                  label: t.translate('edit_event_allow_companions'),
                  value: state.allowCompanions,
                  onChanged:
                      context.read<EditEventCubit>().updateAllowCompanions,
                ),
                if (!state.isDraft &&
                    state.previousRequests.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    t.translate('edit_event_previous_requests'),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.previousRequests
                      .map((r) => EditRequestStatusCard(request: r)),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? '${value.day}/${value.month}/${value.year}'
                        : '—',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: value != null
                          ? context.textPrimary
                          : context.textTertiary,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: context.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}
