import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/buttons/secondary_button.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/wizard_step_header.dart';

class Page3PreviewScreen extends StatefulWidget {
  const Page3PreviewScreen({super.key});

  @override
  State<Page3PreviewScreen> createState() => _Page3PreviewScreenState();
}

class _Page3PreviewScreenState extends State<Page3PreviewScreen> {
  @override
  void initState() {
    super.initState();
    // Load preview when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InvitationCubit>().loadPreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Step Header
                WizardStepHeader(
                  currentStep: 3,
                  totalSteps: 7,
                  title: l?.translate('invitation_step3_title') ?? 'Preview',
                ),

                // Content
                Expanded(
                  child: _buildContent(context, state, l),
                ),

                // Navigation Buttons
                _buildBottomBar(context, state, l),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, InvitationState state, AppLocalizations? l) {
    // Show loading state
    if (state.isLoadingPreview) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              l?.translate('invitation_loading_preview') ?? 'Loading preview...',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Show preview content
    return SingleChildScrollView(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info card
          Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11.w),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                  size: 23.w,
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child: Text(
                    l?.translate('invitation_preview_info') ?? 'This is a preview of your invitation',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Preview Image
          _buildPreviewImage(context, state, l),

          SizedBox(height: 24.h),

          // Event Details Summary
          _buildEventDetailsSummary(context, state, l),
        ],
      ),
    );
  }

  Widget _buildPreviewImage(BuildContext context, InvitationState state, AppLocalizations? l) {
    // If user uploaded custom template, show that
    if (state.uploadedTemplateFile != null) {
      return Container(
        constraints: BoxConstraints(maxHeight: 406.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.w),
          child: Image.file(
            state.uploadedTemplateFile!,
            fit: BoxFit.contain,
            cacheHeight: 800, // Limit image size for performance
            errorBuilder: (ctx, error, stackTrace) {
              debugPrint('Error loading file image: $error');
              return _buildPlaceholder(context, l);
            },
          ),
        ),
      );
    }

    // Show preview from API
    if (state.previewImageUrl != null && state.previewImageUrl!.isNotEmpty) {
      return Container(
        constraints: BoxConstraints(maxHeight: 406.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.w),
          child: Image.network(
            state.previewImageUrl!,
            fit: BoxFit.contain,
            cacheHeight: 800, // Limit image size for performance
            loadingBuilder: (ctx, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 284.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15.w),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (ctx, error, stackTrace) {
              debugPrint('Error loading network image: $error');
              return _buildPlaceholder(context, l);
            },
          ),
        ),
      );
    }

    // No preview available - show placeholder
    return _buildPlaceholder(context, l);
  }

  Widget _buildPlaceholder(BuildContext context, AppLocalizations? l) {
    return Container(
      height: 284.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15.w),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 60.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            l?.translate('invitation_no_preview') ?? 'No preview available',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l?.translate('invitation_continue_next_step') ?? 'You can continue to the next step',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsSummary(BuildContext context, InvitationState state, AppLocalizations? l) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 9.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, color: AppColors.primaryColor, size: 23.w),
              SizedBox(width: 8.w),
              Text(
                l?.translate('invitation_event_details') ?? 'Event Details',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          const Divider(),
          SizedBox(height: 8.h),

          // Event Name
          _buildDetailRow(
            context,
            l?.translate('invitation_event_name_label') ?? 'Event Name',
            state.eventName ?? '-',
            Icons.celebration,
          ),

          // Event Type
          _buildDetailRow(
            context,
            l?.translate('invitation_event_type_label') ?? 'Event Type',
            state.selectedEventType?.name ?? state.customEventTypeName ?? '-',
            Icons.category,
          ),

          // Date
          if (state.eventDate != null)
            _buildDetailRow(
              context,
              l?.translate('invitation_date_label') ?? 'Date',
              '${state.eventDate!.day}/${state.eventDate!.month}/${state.eventDate!.year}',
              Icons.calendar_today,
            ),

          // Time
          if (state.eventTime != null)
            _buildDetailRow(
              context,
              l?.translate('invitation_time_label') ?? 'Time',
              '${state.eventTime!.hour.toString().padLeft(2, '0')}:${state.eventTime!.minute.toString().padLeft(2, '0')}',
              Icons.access_time,
            ),

          // Location
          if (state.selectedVenue != null || state.customLocation != null)
            _buildDetailRow(
              context,
              l?.translate('invitation_location_label') ?? 'Location',
              state.selectedVenue?.name ?? state.customLocation?.address ?? '-',
              Icons.location_on,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19.w, color: Colors.grey.shade500),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            SizedBox(width: 11.w),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: l?.translate('common_next') ?? 'Next',
                onPressed: state.isLoadingPreview
                    ? null
                    : () => context.read<InvitationCubit>().nextStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
