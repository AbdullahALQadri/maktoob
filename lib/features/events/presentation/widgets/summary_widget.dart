import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/event_models.dart' hide CustomVenue, EventDetails, GuestInfo;
import '../screens/create_event_screen.dart';

class SummaryWidget extends StatelessWidget {
  final PackageModel selectedPackage;
  final VenueModel? selectedVenue;
  final MutableCustomVenue? customVenue;
  final EventTypeModel? selectedEventType;
  final String? customEventType;
  final TemplateModel? selectedTemplate;
  final bool requestCustomTemplate;
  final MutableEventDetails eventDetails;
  final GuestMethod? guestMethod;
  final List<MutableGuestInfo> manualGuests;
  final File? excelFile;

  const SummaryWidget({
    super.key,
    required this.selectedPackage,
    required this.selectedVenue,
    required this.customVenue,
    required this.selectedEventType,
    required this.customEventType,
    required this.selectedTemplate,
    required this.requestCustomTemplate,
    required this.eventDetails,
    required this.guestMethod,
    required this.manualGuests,
    required this.excelFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: 16.h),
        _buildSummaryCard(
          context: context,
          title: 'Package',
          content: '${selectedPackage.name} - \$${selectedPackage.price}',
        ),
        SizedBox(height: 12.h),
        _buildSummaryCard(
          context: context,
          title: 'Venue',
          content: selectedVenue?.name ?? customVenue?.name ?? 'Not selected',
        ),
        SizedBox(height: 12.h),
        _buildSummaryCard(
          context: context,
          title: 'Event Type',
          content: selectedEventType?.name ?? customEventType ?? 'Not selected',
        ),
        SizedBox(height: 12.h),
        _buildSummaryCard(
          context: context,
          title: 'Template',
          content: requestCustomTemplate
              ? 'Custom Template (Requested)'
              : selectedTemplate?.name ?? 'Not selected',
        ),
        SizedBox(height: 12.h),
        _buildEventDetailsCard(context),
        SizedBox(height: 12.h),
        _buildGuestsCard(context),
      ],
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(19.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsCard(BuildContext context) {
    String formatDate(DateTime? date) {
      if (date == null) return 'Not set';
      return '${date.day}/${date.month}/${date.year}';
    }

    String formatTime(TimeOfDay? time) {
      if (time == null) return '';
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(19.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(context, 'Name', eventDetails.name.isEmpty ? 'Not set' : eventDetails.name),
          SizedBox(height: 8.h),
          _buildDetailRow(
            context,
            'Date',
            '${formatDate(eventDetails.date)}${eventDetails.time != null ? ' at ${formatTime(eventDetails.time)}' : ''}',
          ),
          SizedBox(height: 8.h),
          _buildDetailRow(context, 'RSVP Deadline', formatDate(eventDetails.responseDeadline)),
          SizedBox(height: 8.h),
          _buildDetailRow(
            context,
            'Companions',
            eventDetails.allowCompanions
                ? 'Allowed (max ${eventDetails.maxCompanions})'
                : 'Not allowed',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.gray600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(19.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guests',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          SizedBox(height: 12.h),
          if (guestMethod == GuestMethod.invite)
            Text(
              'Guests will be reached via WhatsApp, Email & SMS',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.gray600,
              ),
            ),
          if (guestMethod == GuestMethod.excel && excelFile != null)
            Text(
              'Excel file uploaded: ${excelFile!.path.split('/').last}',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.gray600,
              ),
            ),
          if (guestMethod == GuestMethod.manual && manualGuests.isNotEmpty) ...[
            Text(
              '${manualGuests.length} guests added',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),
            SizedBox(height: 12.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 162.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: manualGuests.length,
                itemBuilder: (context, index) {
                  final guest = manualGuests[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guest.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                        ),
                        Text(
                          guest.email,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          if (guestMethod == null)
            Text(
              'No guest method selected',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.gray600,
              ),
            ),
        ],
      ),
    );
  }
}
