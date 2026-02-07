import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';

/// Page 1: Event Type and Template Selection
class Page1EventTypeScreen extends StatelessWidget {
  const Page1EventTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<InvitationCubit>().clearError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              WizardStepHeader(
                currentStep: 1,
                totalSteps: 7,
                title: l?.translate('invitation_step1_title') ?? 'Choose Event Type',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.051)),
                  child: _Page1Content(state: state),
                ),
              ),
              _BottomBar(state: state),
            ],
          ),
        );
      },
    );
  }
}

class _Page1Content extends StatelessWidget {
  final InvitationState state;

  const _Page1Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.dynamicHeight(0.025)),
        _SectionTitle(
            text: l?.translate('invitation_event_type') ?? 'Event Type'),
        SizedBox(height: context.dynamicHeight(0.015)),
        EventTypeDropdown(state: state),
        if (state.selectedEventType?.isCustom == true) ...[
          SizedBox(height: context.dynamicHeight(0.02)),
          _CustomEventNameField(state: state),
        ],
        if (state.selectedEventType != null) ...[
          SizedBox(height: context.dynamicHeight(0.03)),
          _SectionTitle(
              text: l?.translate('invitation_choose_template') ??
                  'Choose Template'),
          SizedBox(height: context.dynamicHeight(0.015)),
          _TemplatesSection(state: state),
        ],
        SizedBox(height: context.dynamicHeight(0.119)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.045),
        fontWeight: FontWeight.w600,
        color: context.textPrimary,
      ),
    );
  }
}

class _CustomEventNameField extends StatelessWidget {
  final InvitationState state;

  const _CustomEventNameField({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppTextField(
      hintText: l?.translate('invitation_enter_event_type_name') ??
          'Enter event type name',
      prefixIcon: Icons.edit,
      initialValue: state.customEventTypeName,
      onChanged: (value) {
        context.read<InvitationCubit>().setCustomEventTypeName(value);
      },
    );
  }
}

class _TemplatesSection extends StatelessWidget {
  final InvitationState state;

  const _TemplatesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isCustomEventType) {
      return CustomTemplateUploadCard(
        uploadedFile: state.uploadedTemplateFile,
        description: state.uploadedTemplateDescription,
      );
    }
    return _TemplatesGrid(state: state);
  }
}

class _TemplatesGrid extends StatelessWidget {
  final InvitationState state;

  const _TemplatesGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final templates = [
      TemplateModel.customPlaceholder(),
      ...state.availableTemplates,
    ];
    final isEnglish = l?.isEnLocale ?? false;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: context.dynamicWidth(0.029),
        mainAxisSpacing: context.dynamicWidth(0.029),
        childAspectRatio: 0.8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isCustomSelected = state.uploadedTemplateFile != null ||
            (state.uploadedTemplateDescription?.isNotEmpty ?? false);
        final isSelected = template.isCustom
            ? isCustomSelected
            : state.selectedTemplate?.id == template.id;

        return TemplateCard(
          template: template,
          isSelected: isSelected,
          uploadedFile: template.isCustom ? state.uploadedTemplateFile : null,
          isEnglish: isEnglish,
          onTap: () => _onTemplateTap(context, template),
        );
      },
    );
  }

  void _onTemplateTap(BuildContext context, TemplateModel template) {
    if (template.isCustom) {
      _showCustomTemplateBottomSheet(context);
    } else {
      context.read<InvitationCubit>().clearCustomTemplate();
      context.read<InvitationCubit>().selectTemplate(template);
    }
  }

  Future<void> _showCustomTemplateBottomSheet(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final result = await AppBottomSheet.show<String>(
      context,
      title: l?.translate('invitation_custom_template') ?? 'Custom Template',
      subtitle: l?.translate('invitation_upload_or_describe') ??
          'Upload an image or describe your design',
      icon: Icons.design_services_rounded,
      iconColor: AppColors.primaryColor,
      iconBackgroundColor: AppColors.purple50,
      child: BlocProvider.value(
        value: context.read<InvitationCubit>(),
        child: const CustomTemplateBottomSheetContent(),
      ),
    );

    if (result == 'pick_image' && context.mounted) {
      await _pickImageFromGallery(context);
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      // Request storage permission for Android < 13
      // On Android 13+, image_picker uses the system photo picker (no permission needed)
      final storageStatus = await ph.Permission.storage.request();
      debugPrint('Storage permission status: $storageStatus');

      // Also try photos permission for Android 13+
      if (!storageStatus.isGranted) {
        final photosStatus = await ph.Permission.photos.request();
        debugPrint('Photos permission status: $photosStatus');
      }

      // Always try the picker regardless of permission result
      // The system photo picker and ACTION_PICK intent can work without explicit permission
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (image != null && context.mounted) {
        final cubit = context.read<InvitationCubit>();
        cubit.clearSelectedTemplate();
        cubit.uploadCustomTemplate(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l?.translate('error_picking_image') ??
                  'Failed to open gallery. Please check app permissions.',
            ),
            action: SnackBarAction(
              label: l?.translate('open_settings') ?? 'Settings',
              onPressed: () => ph.openAppSettings(),
            ),
          ),
        );
      }
    }
  }
}

class _BottomBar extends StatelessWidget {
  final InvitationState state;

  const _BottomBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canProceed = state.canProceedFromEventType;
    final isLoading = state.isLoading;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.024),
            offset: Offset(0, -context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: SafeArea(
        child: PrimaryButton(
          text: l?.translate('common_next') ?? 'Next',
          isLoading: isLoading,
          onPressed: canProceed && !isLoading
              ? () => context.read<InvitationCubit>().createDraftAndProceed()
              : null,
        ),
      ),
    );
  }
}
