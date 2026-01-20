import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
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
      context.read<InvitationCubit>().loadPreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvitationCubit, InvitationState>(
      listener: (context, state) {
        // Handle navigation - skip preview if custom type or uploaded template
        if (state.shouldSkipPreview && state.currentStep == InvitationStep.invitationPreview) {
          context.read<InvitationCubit>().nextStep();
        }
      },
      builder: (context, state) {
        // If should skip preview, show loading while auto-navigating
        if (state.shouldSkipPreview) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Step Header
                const WizardStepHeader(
                  currentStep: 3,
                  totalSteps: 7,
                  title: 'معاينة الدعوة',
                ),

                // Content
                Expanded(
                  child: _buildContent(context, state),
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
              'جاري تحميل المعاينة...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Show error state
    if (state.previewError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ أثناء تحميل المعاينة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.previewError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'إعادة المحاولة',
                onPressed: () {
                  context.read<InvitationCubit>().loadPreview();
                },
                width: 200,
              ),
            ],
          ),
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'هذه معاينة للدعوة كما ستظهر للمدعوين',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(state.uploadedTemplateFile!.path),
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // Show preview from API
    if (state.previewImageUrl != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'تعذر تحميل الصورة',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    // No preview available - show placeholder
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد معاينة متاحة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك المتابعة للخطوة التالية',
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
            color: Colors.black.withOpacity(0.05),
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
              Icon(
                Icons.event_note,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'تفاصيل الحدث',
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
            'اسم الحدث',
            state.eventName ?? '-',
            Icons.celebration,
          ),

          // Event Type
          _buildDetailRow(
            'نوع الحدث',
            state.selectedEventType?.nameAr ?? state.customEventTypeName ?? '-',
            Icons.category,
          ),

          // Template
          _buildDetailRow(
            'القالب',
            state.uploadedTemplateFile != null
                ? 'قالب مخصص'
                : state.selectedTemplate?.nameAr ?? '-',
            Icons.photo_library,
          ),

          // Date
          if (state.eventDate != null)
            _buildDetailRow(
              'التاريخ',
              '${state.eventDate!.day}/${state.eventDate!.month}/${state.eventDate!.year}',
              Icons.calendar_today,
            ),

          // Time
          if (state.eventTime != null)
            _buildDetailRow(
              'الوقت',
              '${state.eventTime!.hour.toString().padLeft(2, '0')}:${state.eventTime!.minute.toString().padLeft(2, '0')}',
              Icons.access_time,
            ),

          // Location
          if (state.selectedVenue != null || state.customLocation != null)
            _buildDetailRow(
              'الموقع',
              state.selectedVenue?.nameAr ??
                  state.customLocation?.address ??
                  '-',
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
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade500,
          ),
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
              onPressed: state.isLoadingPreview
                  ? null
                  : () {
                      context.read<InvitationCubit>().nextStep();
                    },
            ),
          ),
        ],
      ),
    );
  }
}
