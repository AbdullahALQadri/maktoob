import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
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
    final l = AppLocalizations.of(context);

    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Column(
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
                  padding: EdgeInsets.symmetric(horizontal: 19.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      // Event Name (Required)
                      _buildSectionTitle(context, l?.translate('invitation_event_name_required') ?? 'Event Name *'),
                      SizedBox(height: 8.h),
                      AppTextField(
                        controller: _nameController,
                        hintText: l?.translate('invitation_enter_event_name') ?? 'Enter event name',
                        prefixIcon: Icons.event,
                        onChanged: (value) {
                          context.read<InvitationCubit>().updateEventName(value);
                        },
                      ),

                      // Event Type Form Fields (bride/groom for marriage/engagement)
                      if (!state.isCustomEventType && !state.isCustomTemplate && state.eventTypeFormFields.isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        _buildEventTypeFormFields(context, state, l),
                      ],

                      SizedBox(height: 20.h),

                      // Description (Optional)
                      _buildSectionTitle(context, l?.translate('invitation_description_optional_label') ?? 'Description (Optional)'),
                      SizedBox(height: 8.h),
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

                      SizedBox(height: 20.h),

                      // Date (Required)
                      _buildSectionTitle(context, l?.translate('invitation_date_required') ?? 'Date *'),
                      SizedBox(height: 8.h),
                      _buildDatePicker(context, state, l),

                      SizedBox(height: 20.h),

                      // Time (Required)
                      _buildSectionTitle(context, l?.translate('invitation_time_required') ?? 'Time *'),
                      SizedBox(height: 8.h),
                      _buildTimePicker(context, state, l),

                      SizedBox(height: 20.h),

                      // Location (Required)
                      _buildSectionTitle(context, l?.translate('invitation_location_required') ?? 'Location *'),
                      SizedBox(height: 8.h),
                      _buildLocationSection(context, state, l),

                      SizedBox(height: 20.h),

                      // Partner with Guests (Optional) - Switch + Number
                      _buildCompanionsSection(context, state, l),

                      SizedBox(height: 97.h),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            _buildBottomBar(context, state, l),
          ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.gray700,
      ),
    );
  }

  Widget _buildCompanionsSection(BuildContext context, InvitationState state, AppLocalizations? l) {
    final isEnabled = state.partnerWithGuests != null && state.partnerWithGuests! > 0;

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11.w),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Switch row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: AppColors.primary,
                      size: 21.w,
                    ),
                    SizedBox(width: 11.w),
                    Flexible(
                      child: Text(
                        l?.translate('invitation_allow_companions') ?? 'Allow Companions',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (isEnabled) {
                    // Disable companions
                    context.read<InvitationCubit>().updatePartnerWithGuests(null);
                    _partnerController.clear();
                  } else {
                    // Enable with default value of 1
                    context.read<InvitationCubit>().updatePartnerWithGuests(1);
                    _partnerController.text = '1';
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 53.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(15.w),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: isEnabled
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 23.w,
                      height: 23.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Number picker (only show when enabled)
          if (isEnabled) ...[
            SizedBox(height: 16.h),
            Text(
              l?.translate('invitation_companions_count') ?? 'Number of companions per guest (1-10)',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                // Decrease button
                _buildCompanionButton(
                  context: context,
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
                    margin: EdgeInsets.symmetric(horizontal: 15.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Text(
                      '${state.partnerWithGuests ?? 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                // Increase button
                _buildCompanionButton(
                  context: context,
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
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: onPressed != null ? AppColors.primary : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(8.w),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.w),
        child: Container(
          width: 45.w,
          height: 45.w,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
            size: 23.w,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, InvitationState state, AppLocalizations? l) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 15.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(11.w),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.gray500, size: 19.w),
            SizedBox(width: 11.w),
            Expanded(
              child: Text(
                state.eventDate != null
                    ? _formatDate(state.eventDate!)
                    : l?.translate('invitation_select_date') ?? 'Select date',
                style: TextStyle(
                  color: state.eventDate != null
                      ? AppColors.gray800
                      : AppColors.gray400,
                  fontSize: 14.sp,
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
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.primaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.w),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
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
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 15.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(11.w),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.gray500, size: 19.w),
            SizedBox(width: 11.w),
            Expanded(
              child: Text(
                state.eventTime != null
                    ? _formatTime(state.eventTime!)
                    : l?.translate('invitation_select_time') ?? 'Select time',
                style: TextStyle(
                  color: state.eventTime != null
                      ? AppColors.gray800
                      : AppColors.gray400,
                  fontSize: 14.sp,
                ),
              ),
            ),
            if (state.eventTime != null)
              GestureDetector(
                onTap: () {
                  // Clear time - need to add method to cubit
                },
                child: Icon(Icons.close, color: AppColors.gray400, size: 17.w),
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
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11.w),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11.w),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.w),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
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
            context: context,
            icon: Icons.location_city,
            title: l?.translate('invitation_select_from_venues') ?? 'Select from Venues',
            subtitle: l?.translate('invitation_choose_available_venues') ?? 'Choose from available venues',
            onTap: () => _showVenueSelector(context, state, l),
          ),

          SizedBox(height: 12.h),

          // Google Maps option
          _buildLocationOption(
            context: context,
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
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(11.w),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9.w),
            ),
            child: Icon(
              isVenue ? Icons.location_city : Icons.location_on,
              color: AppColors.primaryColor,
              size: 23.w,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
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
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(11.w),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9.w),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 23.w),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.gray400, size: 15.w),
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

    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          t.translate('invitation_couple_info'),
        ),
        SizedBox(height: 8.h),
        ...state.eventTypeFormFields.map((field) {
          // Choose appropriate icon based on field key
          IconData fieldIcon = Icons.person_outline;
          if (field.key == 'groom_name') {
            fieldIcon = Icons.person;
          } else if (field.key == 'bride_name') {
            fieldIcon = Icons.person_outline;
          }

          // Use localized label
          final label = isArabic ? field.labelAr : field.label;
          final hint = isArabic
              ? (field.hintAr ?? field.labelAr)
              : (field.hint ?? field.label);

          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: AppTextField(
              labelText: label,
              hintText: hint,
              prefixIcon: fieldIcon,
              initialValue: state.eventTypeFormData[field.key]?.toString(),
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
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 9.w,
            offset: Offset(0, -4.h),
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
            SizedBox(width: 11.w),
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
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, size: 45.w, color: AppColors.gray300),
            SizedBox(height: 16.h),
            Text(
              l?.translate('invitation_no_venues_available') ?? 'No venues available',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 15.sp,
              ),
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 4.h,
          ),
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Icon(
              Icons.location_city,
              color: AppColors.primaryColor,
              size: 23.w,
            ),
          ),
          title: Text(
            venue.name,
            style: TextStyle(fontSize: 15.sp),
          ),
          subtitle: venue.address != null
              ? Text(
                  venue.address!,
                  style: TextStyle(fontSize: 12.sp),
                )
              : null,
          trailing: Icon(Icons.arrow_forward_ios, size: 15.w),
          onTap: () {
            context.read<InvitationCubit>().selectVenue(venue);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
