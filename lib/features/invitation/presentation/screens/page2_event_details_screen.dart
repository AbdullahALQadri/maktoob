import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/buttons/secondary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/google_maps_picker_widget.dart';
import '../widgets/wizard_step_header.dart';

/// Page 2: Event Details (name, date, time, location, form fields)
class Page2EventDetailsScreen extends StatefulWidget {
  const Page2EventDetailsScreen({super.key});

  @override
  State<Page2EventDetailsScreen> createState() =>
      _Page2EventDetailsScreenState();
}

class _Page2EventDetailsScreenState extends State<Page2EventDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _partnerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing state
    final state = context.read<InvitationCubit>().state;
    _nameController.text = state.eventName ?? '';
    _descriptionController.text = state.eventDescription ?? '';
    if (state.partnerWithGuests != null) {
      _partnerController.text = state.partnerWithGuests.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _partnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l = AppLocalizations.of(context);

    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Column(
          children: [
            // Step Header
            WizardStepHeader(
              currentStep: 2,
              totalSteps: 7,
              title: l?.translate('invitation_step2_title') ?? 'Event Details',
            ),

            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Event Name (Required)
                      _buildSectionTitle(l?.translate('invitation_event_name_required') ?? 'Event Name *'),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _nameController,
                        hintText: l?.translate('invitation_enter_event_name') ?? 'Enter event name',
                        prefixIcon: Icons.event,
                        onChanged: (value) {
                          context.read<InvitationCubit>().updateEventName(value);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Description (Optional)
                      _buildSectionTitle(l?.translate('invitation_description_optional_label') ?? 'Description (Optional)'),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _descriptionController,
                        hintText: l?.translate('invitation_add_event_description') ?? 'Add a description for your event...',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 3,
                        onChanged: (value) {
                          context
                              .read<InvitationCubit>()
                              .updateEventDescription(value.isEmpty ? null : value);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Date (Required)
                      _buildSectionTitle(l?.translate('invitation_date_required') ?? 'Date *'),
                      const SizedBox(height: 8),
                      _buildDatePicker(context, state, l),

                      const SizedBox(height: 20),

                      // Time (Required)
                      _buildSectionTitle(l?.translate('invitation_time_required') ?? 'Time *'),
                      const SizedBox(height: 8),
                      _buildTimePicker(context, state, l),

                      const SizedBox(height: 20),

                      // Location (Required)
                      _buildSectionTitle(l?.translate('invitation_location_required') ?? 'Location *'),
                      const SizedBox(height: 8),
                      _buildLocationSection(context, state, l),

                      const SizedBox(height: 20),

                      // Partner with Guests (Optional) - Switch + Number
                      _buildCompanionsSection(context, state, l),

                      // Event Type Form Fields (hidden for custom type/uploaded template)
                      if (!state.isCustomEventType && !state.isCustomTemplate) ...[
                        const SizedBox(height: 20),
                        _buildEventTypeFormFields(context, state, l),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            _buildBottomBar(context, state, l),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.gray700,
      ),
    );
  }

  Widget _buildCompanionsSection(BuildContext context, InvitationState state, AppLocalizations? l) {
    final isEnabled = state.partnerWithGuests != null && state.partnerWithGuests! > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Switch row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l?.translate('invitation_allow_companions') ?? 'Allow Companions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) {
                  if (value) {
                    // Enable with default value of 1
                    context.read<InvitationCubit>().updatePartnerWithGuests(1);
                    _partnerController.text = '1';
                  } else {
                    // Disable companions
                    context.read<InvitationCubit>().updatePartnerWithGuests(null);
                    _partnerController.clear();
                  }
                },
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),

          // Number picker (only show when enabled)
          if (isEnabled) ...[
            const SizedBox(height: 16),
            Text(
              l?.translate('invitation_companions_count') ?? 'Number of companions per guest (1-10)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Decrease button
                _buildCompanionButton(
                  icon: Icons.remove,
                  onPressed: (state.partnerWithGuests ?? 1) > 1
                      ? () {
                          final newValue = (state.partnerWithGuests ?? 1) - 1;
                          context.read<InvitationCubit>().updatePartnerWithGuests(newValue);
                          _partnerController.text = newValue.toString();
                        }
                      : null,
                ),

                // Number display
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${state.partnerWithGuests ?? 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                // Increase button
                _buildCompanionButton(
                  icon: Icons.add,
                  onPressed: (state.partnerWithGuests ?? 1) < 10
                      ? () {
                          final newValue = (state.partnerWithGuests ?? 1) + 1;
                          context.read<InvitationCubit>().updatePartnerWithGuests(newValue);
                          _partnerController.text = newValue.toString();
                        }
                      : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanionButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: onPressed != null ? AppColors.primary : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, InvitationState state, AppLocalizations? l) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.gray500, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.eventDate != null
                    ? _formatDate(state.eventDate!)
                    : l?.translate('invitation_select_date') ?? 'Select date',
                style: TextStyle(
                  color: state.eventDate != null
                      ? AppColors.gray800
                      : AppColors.gray400,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray800,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      context.read<InvitationCubit>().updateDate(picked);
    }
  }

  Widget _buildTimePicker(BuildContext context, InvitationState state, AppLocalizations? l) {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.gray500, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.eventTime != null
                    ? _formatTime(state.eventTime!)
                    : l?.translate('invitation_select_time') ?? 'Select time',
                style: TextStyle(
                  color: state.eventTime != null
                      ? AppColors.gray800
                      : AppColors.gray400,
                  fontSize: 15,
                ),
              ),
            ),
            if (state.eventTime != null)
              GestureDetector(
                onTap: () {
                  // Clear time - need to add method to cubit
                },
                child: Icon(Icons.close, color: AppColors.gray400, size: 18),
              )
            else
              Icon(Icons.arrow_drop_down, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray800,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      context.read<InvitationCubit>().updateTime(picked);
    }
  }

  Widget _buildLocationSection(BuildContext context, InvitationState state, AppLocalizations? l) {
    return Column(
      children: [
        // Selected location display
        if (state.selectedVenue != null || state.customLocation != null)
          _buildSelectedLocation(context, state, l),

        if (state.selectedVenue == null && state.customLocation == null) ...[
          // Venue list option
          _buildLocationOption(
            icon: Icons.location_city,
            title: l?.translate('invitation_select_from_venues') ?? 'Select from Venues',
            subtitle: l?.translate('invitation_choose_available_venues') ?? 'Choose from available venues',
            onTap: () => _showVenueSelector(context, state, l),
          ),

          const SizedBox(height: 12),

          // Google Maps option
          _buildLocationOption(
            icon: Icons.map_outlined,
            title: l?.translate('invitation_choose_on_map') ?? 'Choose on Map',
            subtitle: l?.translate('invitation_gaza_area_only') ?? 'Gaza area only',
            onTap: () => _showGoogleMapsPicker(context),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedLocation(BuildContext context, InvitationState state, AppLocalizations? l) {
    final isVenue = state.selectedVenue != null;
    final title = isVenue
        ? state.selectedVenue!.name
        : (state.customLocation?.placeName ?? l?.translate('invitation_custom_location') ?? 'Custom Location');
    final subtitle = isVenue
        ? state.selectedVenue!.address
        : state.customLocation?.address;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isVenue ? Icons.location_city : Icons.location_on,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Clear location
              if (isVenue) {
                context.read<InvitationCubit>().clearVenue();
              } else {
                context.read<InvitationCubit>().clearLocation();
              }
            },
            icon: Icon(Icons.close, color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.gray400, size: 16),
          ],
        ),
      ),
    );
  }

  void _showVenueSelector(BuildContext context, InvitationState state, AppLocalizations? l) {
    AppBottomSheet.show(
      context,
      title: l?.translate('invitation_select_venue') ?? 'Select Venue',
      child: _VenueSelectorContent(venues: state.availableVenues),
    );
  }

  void _showGoogleMapsPicker(BuildContext context) {
    final cubit = context.read<InvitationCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: cubit,
          child: GoogleMapsPickerWidget(
            initialLocation: cubit.state.customLocation,
            onLocationSelected: (location) {
              cubit.setCustomLocation(location);
              Navigator.pop(routeContext);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeFormFields(
      BuildContext context, InvitationState state, AppLocalizations? l) {
    if (state.eventTypeFormFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l?.translate('invitation_event_details') ?? 'Event Details'),
        const SizedBox(height: 8),
        ...state.eventTypeFormFields.map((field) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppTextField(
              hintText: field.hint ?? field.label,
              prefixIcon: Icons.edit_outlined,
              onChanged: (value) {
                context
                    .read<InvitationCubit>()
                    .updateEventTypeFormField(field.key, value);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, InvitationState state, AppLocalizations? l) {
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
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: l?.translate('common_back') ?? 'Back',
                onPressed: () => context.read<InvitationCubit>().previousStep(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: l?.translate('common_next') ?? 'Next',
                onPressed: state.canProceedFromEventDetails
                    ? () => context.read<InvitationCubit>().nextStep()
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}

/// Venue Selector Bottom Sheet Content
class _VenueSelectorContent extends StatelessWidget {
  final List<VenueModel> venues;

  const _VenueSelectorContent({required this.venues});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (venues.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, size: 48, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              l?.translate('invitation_no_venues_available') ?? 'No venues available',
              style: TextStyle(color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: venues.length,
      itemBuilder: (context, index) {
        final venue = venues[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.location_city, color: AppColors.primaryColor),
          ),
          title: Text(venue.name),
          subtitle: venue.address != null ? Text(venue.address!) : null,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            context.read<InvitationCubit>().selectVenue(venue);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
