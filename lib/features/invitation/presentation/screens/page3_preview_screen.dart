import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
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
    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Step Header
                const WizardStepHeader(
                  currentStep: 3,
                  totalSteps: 7,
                  title: 'Preview',
                  titleAr: 'معاينة الدعوة',
                ),

                // Content
                Expanded(
                  child: _buildContent(context, state),
                ),

                // Navigation Buttons
                _buildBottomBar(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, InvitationState state) {
    // Show loading state
    if (state.isLoadingPreview) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading preview...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Show preview content
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'This is a preview of your invitation',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Preview Image
          _buildPreviewImage(state),

          const SizedBox(height: 24),

          // Event Details Summary
          _buildEventDetailsSummary(state),
        ],
      ),
    );
  }

  Widget _buildPreviewImage(InvitationState state) {
    // If user uploaded custom template, show that
    if (state.uploadedTemplateFile != null) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            state.uploadedTemplateFile!,
            fit: BoxFit.contain,
            cacheHeight: 800, // Limit image size for performance
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading file image: $error');
              return _buildPlaceholder();
            },
          ),
        ),
      );
    }

    // Show preview from API
    if (state.previewImageUrl != null && state.previewImageUrl!.isNotEmpty) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            state.previewImageUrl!,
            fit: BoxFit.contain,
            cacheHeight: 800, // Limit image size for performance
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading network image: $error');
              return _buildPlaceholder();
            },
          ),
        ),
      );
    }

    // No preview available - show placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No preview available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can continue to the next step',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsSummary(InvitationState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Icon(Icons.event_note, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Event Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Event Name
          _buildDetailRow(
            'Event Name',
            state.eventName ?? '-',
            Icons.celebration,
          ),

          // Event Type
          _buildDetailRow(
            'Event Type',
            state.selectedEventType?.name ?? state.customEventTypeName ?? '-',
            Icons.category,
          ),

          // Date
          if (state.eventDate != null)
            _buildDetailRow(
              'Date',
              '${state.eventDate!.day}/${state.eventDate!.month}/${state.eventDate!.year}',
              Icons.calendar_today,
            ),

          // Time
          if (state.eventTime != null)
            _buildDetailRow(
              'Time',
              '${state.eventTime!.hour.toString().padLeft(2, '0')}:${state.eventTime!.minute.toString().padLeft(2, '0')}',
              Icons.access_time,
            ),

          // Location
          if (state.selectedVenue != null || state.customLocation != null)
            _buildDetailRow(
              'Location',
              state.selectedVenue?.name ?? state.customLocation?.address ?? '-',
              Icons.location_on,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, InvitationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                text: 'Back',
                onPressed: () => context.read<InvitationCubit>().previousStep(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: 'Next',
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
