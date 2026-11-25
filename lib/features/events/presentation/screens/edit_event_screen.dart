import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/edit_event/edit_event_cubit.dart';
import '../cubit/edit_event/edit_event_state.dart';
import '../widgets/edit_request_banner.dart';
import '../widgets/edit_event_fields.dart';
import '../widgets/edit_request_status_card.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _venueController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxCompanionsController;

  late FocusNode _nameFocus;
  late FocusNode _venueFocus;
  late FocusNode _descriptionFocus;
  late FocusNode _maxCompanionsFocus;

  @override
  void initState() {
    super.initState();
    final state = context.read<EditEventCubit>().state;
    _nameController = TextEditingController(text: state.name);
    _venueController = TextEditingController(text: state.venue);
    _descriptionController =
        TextEditingController(text: state.description ?? '');
    _maxCompanionsController =
        TextEditingController(text: state.maxCompanions.toString());

    _nameFocus = FocusNode();
    _venueFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _maxCompanionsFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    _maxCompanionsController.dispose();

    _nameFocus.dispose();
    _venueFocus.dispose();
    _descriptionFocus.dispose();
    _maxCompanionsFocus.dispose();

    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<EditEventCubit>().saveChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocConsumer<EditEventCubit, EditEventState>(
      listener: (context, state) {
        if (state.status == EditEventStatus.saved) {
          state.redoDesign
              ? AppSnackBar.showWarning(context, message: t.translate('edit_event_redo_design'))
              : AppSnackBar.showSuccess(context, message: t.translate('edit_event_saved'));
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
          body: Column(
            children: [
              _buildHeader(context, state, t),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!state.editsDirectly)
                          EditRequestBanner(waiting: state.hasPendingRequest),
                        EditEventTextField(
                          label: t.translate('edit_event_name'),
                          controller: _nameController,
                          focusNode: _nameFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => _venueFocus.requestFocus(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return t.translate('edit_event_name_required');
                            }
                            return null;
                          },
                          onChanged: context.read<EditEventCubit>().updateName,
                        ),
                        SizedBox(height: context.dynamicHeight(0.02)),
                        if (state.editsDirectly)
                          OccasionAnswersFields(
                            answers: state.savedAnswers,
                            onChanged: context.read<EditEventCubit>().updateAnswer,
                          ),
                        EditEventTextField(
                          label: t.translate('edit_event_venue'),
                          controller: _venueController,
                          focusNode: _venueFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              _descriptionFocus.requestFocus(),
                          onChanged:
                              context.read<EditEventCubit>().updateVenue,
                        ),
                        SizedBox(height: context.dynamicHeight(0.02)),
                        EditEventTextField(
                          label: t.translate('edit_event_description'),
                          controller: _descriptionController,
                          focusNode: _descriptionFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              _maxCompanionsFocus.requestFocus(),
                          onChanged: context
                              .read<EditEventCubit>()
                              .updateDescription,
                          maxLines: 3,
                        ),
                        SizedBox(height: context.dynamicHeight(0.02)),
                        EditEventDateField(
                          label: t.translate('edit_event_date'),
                          value: state.eventDate,
                          onChanged:
                              context.read<EditEventCubit>().updateEventDate,
                        ),
                        SizedBox(height: context.dynamicHeight(0.02)),
                        EditEventDateField(
                          label: t.translate('edit_event_rsvp_deadline'),
                          value: state.rsvpDeadline,
                          onChanged:
                              context.read<EditEventCubit>().updateRsvpDeadline,
                        ),
                        SizedBox(height: context.dynamicHeight(0.02)),
                        EditEventSwitchField(
                          label: t.translate('edit_event_allow_companions'),
                          value: state.allowCompanions,
                          onChanged: context
                              .read<EditEventCubit>()
                              .updateAllowCompanions,
                        ),
                        if (state.allowCompanions) ...[
                          SizedBox(height: context.dynamicHeight(0.02)),
                          EditEventTextField(
                            label: t.translate('edit_event_max_companions'),
                            controller: _maxCompanionsController,
                            focusNode: _maxCompanionsFocus,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return t.translate(
                                    'edit_event_max_companions_required');
                              }
                              final parsed = int.tryParse(value);
                              if (parsed == null) {
                                return t.translate(
                                    'edit_event_max_companions_invalid');
                              }
                              if (parsed < 1) {
                                return t.translate(
                                    'edit_event_max_companions_min');
                              }
                              if (parsed > 10) {
                                return t.translate(
                                    'edit_event_max_companions_max');
                              }
                              return null;
                            },
                            onChanged: (value) {
                              final parsed = int.tryParse(value);
                              if (parsed != null) {
                                context
                                    .read<EditEventCubit>()
                                    .updateMaxCompanions(parsed);
                              }
                            },
                          ),
                        ],
                        if (!state.editsDirectly &&
                            state.previousRequests.isNotEmpty) ...[
                          SizedBox(height: context.dynamicHeight(0.03)),
                          Text(
                            t.translate('edit_event_previous_requests'),
                            style: AppTextStyles.titleSmall.copyWith(
                              color: context.textPrimary,
                            ),
                          ),
                          SizedBox(height: context.dynamicHeight(0.015)),
                          ...state.previousRequests
                              .map((r) => EditRequestStatusCard(request: r)),
                        ],
                        SizedBox(height: context.dynamicHeight(0.04)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, EditEventState state, AppLocalizations t) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                context.dynamicWidth(0.04),
                context.dynamicHeight(0.015),
                context.dynamicWidth(0.04),
                context.dynamicHeight(0.03),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: context.dynamicWidth(0.101),
                          height: context.dynamicWidth(0.101),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(Icons.close,
                              color: Colors.white,
                              size: context.dynamicWidth(0.056)),
                        ),
                      ),
                      const Spacer(),
                      _buildSaveButton(context, state, t),
                    ],
                  ),
                  SizedBox(height: context.dynamicHeight(0.025)),
                  Row(
                    children: [
                      Container(
                        width: context.dynamicWidth(0.12),
                        height: context.dynamicWidth(0.12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                              context.dynamicWidth(0.04)),
                        ),
                        child: Icon(Icons.edit_outlined,
                            color: Colors.white,
                            size: context.dynamicWidth(0.061)),
                      ),
                      SizedBox(width: context.dynamicWidth(0.035)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.translate('edit_event_title'),
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: context.dynamicHeight(0.005)),
                            Text(
                              state.event?.name ?? '',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -30,
              right: -30,
              child: IgnorePointer(
                child: Container(
                  width: context.dynamicWidth(0.4),
                  height: context.dynamicWidth(0.4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: IgnorePointer(
                child: Container(
                  width: context.dynamicWidth(0.3),
                  height: context.dynamicWidth(0.3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
      BuildContext context, EditEventState state, AppLocalizations t) {
    if (state.isSaving) {
      return Container(
        width: context.dynamicWidth(0.101),
        height: context.dynamicWidth(0.101),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.dynamicWidth(0.025)),
          child: const MkSpinner(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: state.canSave ? _saveChanges : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.012),
        ),
        decoration: BoxDecoration(
          color: state.canSave
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          state.editsDirectly
              ? t.translate('common_save')
              : t.translate('edit_event_submit_request'),
          style: TextStyle(
            color: state.canSave
                ? AppColors.primaryColor
                : Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
            fontSize: context.dynamicWidth(0.033),
          ),
        ),
      ),
    );
  }
}
