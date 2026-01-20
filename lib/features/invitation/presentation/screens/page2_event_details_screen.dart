import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Column(
          children: [
            // Step Header
            const WizardStepHeader(
              currentStep: 2,
              totalSteps: 7,
              title: 'Event Details',
              titleAr: 'تفاصيل المناسبة',
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
                      _buildSectionTitle('Event Name *', 'اسم المناسبة *'),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _nameController,
                        hintText: 'Enter event name',
                        prefixIcon: Icons.event,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Event name is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<InvitationCubit>().updateEventName(value);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Description (Optional)
                      _buildSectionTitle(
                          'Description (Optional)', 'الوصف (اختياري)'),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _descriptionController,
                        hintText: 'Add a description for your event...',
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
                      _buildSectionTitle('Date *', 'التاريخ *'),
                      const SizedBox(height: 8),
                      _buildDatePicker(context, state),

                      const SizedBox(height: 20),

                      // Time (Optional)
                      _buildSectionTitle('Time (Optional)', 'الوقت (اختياري)'),
                      const SizedBox(height: 8),
                      _buildTimePicker(context, state),

                      const SizedBox(height: 20),

                      // Location (Required)
                      _buildSectionTitle('Location *', 'الموقع *'),
                      const SizedBox(height: 8),
                      _buildLocationSection(context, state),

                      const SizedBox(height: 20),

                      // Partner with Guests (Optional)
                      _buildSectionTitle(
                        'Companions per Guest (Optional)',
                        'عدد المرافقين لكل ضيف (اختياري)',
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _partnerController,
                        hintText: 'Number of companions allowed',
                        prefixIcon: Icons.people_outline,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          context
                              .read<InvitationCubit>()
                              .updatePartnerWithGuests(int.tryParse(value));
                        },
                      ),

                      // Event Type Form Fields (hidden for custom type/uploaded template)
                      if (!state.isCustomEventType && !state.isCustomTemplate) ...[
                        const SizedBox(height: 20),
                        _buildEventTypeFormFields(context, state),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            _buildBottomBar(context, state),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, String titleAr) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.gray700,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, InvitationState state) {
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
                    : 'Select date',
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

  Widget _buildTimePicker(BuildContext context, InvitationState state) {
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
                    : 'Select time (optional)',
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

  Widget _buildLocationSection(BuildContext context, InvitationState state) {
    return Column(
      children: [
        // Selected location display
        if (state.selectedVenue != null || state.customLocation != null)
          _buildSelectedLocation(context, state),

        if (state.selectedVenue == null && state.customLocation == null) ...[
          // Venue list option
          _buildLocationOption(
            icon: Icons.location_city,
            title: 'Select from Venues',
            subtitle: 'Choose from available venues',
            onTap: () => _showVenueSelector(context, state),
          ),

          const SizedBox(height: 12),

          // Google Maps option
          _buildLocationOption(
            icon: Icons.map_outlined,
            title: 'Choose on Map',
            subtitle: 'Gaza area only',
            onTap: () => _showGoogleMapsPicker(context),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedLocation(BuildContext context, InvitationState state) {
    final isVenue = state.selectedVenue != null;
    final title = isVenue
        ? state.selectedVenue!.name
        : (state.customLocation?.placeName ?? 'Custom Location');
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
                context.read<InvitationCubit>().selectVenue(
                    const VenueModel(id: -1, name: '', nameAr: ''));
              }
              // Need method to clear location
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

  void _showVenueSelector(BuildContext context, InvitationState state) {
    AppBottomSheet.show(
      context,
      title: 'Select Venue',
      child: _VenueSelectorContent(venues: state.availableVenues),
    );
  }

  void _showGoogleMapsPicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<InvitationCubit>(),
          child: GoogleMapsPickerWidget(
            initialLocation: context.read<InvitationCubit>().state.customLocation,
            onLocationSelected: (location) {
              context.read<InvitationCubit>().setCustomLocation(location);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeFormFields(
      BuildContext context, InvitationState state) {
    if (state.eventTypeFormFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Event Details', 'تفاصيل المناسبة'),
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

  Widget _buildBottomBar(BuildContext context, InvitationState state) {
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
                text: 'Back',
                onPressed: () => context.read<InvitationCubit>().previousStep(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: 'Next',
                onPressed: state.canProceedFromEventDetails
                    ? () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<InvitationCubit>().nextStep();
                        }
                      }
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
    if (venues.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, size: 48, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              'No venues available',
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
