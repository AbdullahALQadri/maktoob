import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/core.dart';
import '../../data/models/location_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';

/// Page 1 (of 3): Event Setup
///
/// Compact single-screen form. Order:
///   name → type dropdown → date+time card (start + end) → location → AI cover
class Page1EventSetupScreen extends StatefulWidget {
  const Page1EventSetupScreen({super.key});

  @override
  State<Page1EventSetupScreen> createState() => _Page1EventSetupScreenState();
}

class _Page1EventSetupScreenState extends State<Page1EventSetupScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<InvitationCubit>().state;
    _nameController.text = state.eventName ?? '';
    _locationController.text = state.customLocation?.placeName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _openAiDesign(BuildContext ctx, InvitationState state) async {
    final l = AppLocalizations.of(ctx);

    final eventTypeId = state.selectedEventType?.id;
    if (eventTypeId == null || eventTypeId <= 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(l?.translate('invitation_select_event_type_first') ??
            'اختر نوع المناسبة أولاً'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    int? eventId = state.draftEventId;
    if (eventId == null) {
      final cubit = ctx.read<InvitationCubit>();
      if (_nameController.text.isNotEmpty) {
        cubit.updateEventName(_nameController.text);
      }
      await cubit.initializeWizardIfNeeded();

      if (!mounted) return;
      eventId = cubit.state.draftEventId;
      if (eventId == null) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(l?.translate('invitation_fill_details_first') ??
              'أدخل اسم المناسبة أولاً'),
          backgroundColor: Colors.orange,
        ));
        return;
      }
    }

    // Carry the title the user already entered on this page into the AI design
    // form (pre-filled + editable) instead of asking for it again. Prefer the
    // live field text, falling back to the committed state value.
    final eventTitle = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (state.eventName ?? '');

    final result = await Navigator.of(ctx).pushNamed(
      Routes.aiDesign,
      arguments: {
        'eventId': eventId,
        'eventTypeId': eventTypeId,
        'eventTitle': eventTitle,
      },
    );

    if (result is String && result.isNotEmpty && mounted) {
      ctx.read<InvitationCubit>().setAiGeneratedImage(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          final msg = l?.translate(state.errorMessage!) ?? state.errorMessage!;
          AppSnackBar.showError(context, message: msg);
          context.read<InvitationCubit>().clearError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          appBar: MaktoobAppBar(
            title: l?.translate('wizard_event_setup_app_bar') ?? 'إعداد الفعالية',
            onForward: () => Navigator.of(context).pop(),
          ),
          body: Column(
            children: [
              WizardStepHeader(
                currentStep: 1,
                totalSteps: 3,
                title: l?.translate('wizard_step1_label') ?? 'تفاصيل الفعالية',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LabeledInput(
                        label: l?.translate('wizard_event_name_label') ??
                            'اسم الفعالية',
                        child: _RoundedTextField(
                          controller: _nameController,
                          hintText: l?.translate('wizard_event_name_hint') ??
                              'مثلاً: حفل تخرج سارة 2024',
                          onChanged: (v) =>
                              context.read<InvitationCubit>().updateEventName(v),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _LabeledInput(
                        label: l?.translate('wizard_event_type_label') ??
                            'نوع الفعالية',
                        child: _EventTypeDropdownTrigger(state: state),
                      ),
                      const SizedBox(height: 20),
                      _DateTimeCard(state: state),
                      const SizedBox(height: 20),
                      _LabeledInput(
                        label: l?.translate('wizard_event_location_label') ??
                            'الموقع',
                        child: _RoundedTextField(
                          controller: _locationController,
                          hintText:
                              l?.translate('wizard_event_location_hint') ??
                                  'ابحث عن الموقع أو القاعة...',
                          prefixIcon: Icons.location_on_outlined,
                          onChanged: (v) {
                            // Round-trip the typed text via customLocation so
                            // saveEventDetails sends it as custom_venue_name_ar.
                            // Coordinates default to 0 when the user only typed
                            // an address — a richer map picker lives in
                            // EventLocationSection if exact coords are needed.
                            final loc = LocationModel(
                              placeName: v,
                              address: state.customLocation?.address ?? v,
                              latitude: state.customLocation?.latitude ?? 0,
                              longitude: state.customLocation?.longitude ?? 0,
                            );
                            context.read<InvitationCubit>().setCustomLocation(loc);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _AiCoverHero(
                        imageUrl: state.generatedImageUrl,
                        onTap: () => _openAiDesign(context, state),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              _BottomBar(state: state, nameController: _nameController),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// Labeled input wrapper
// =============================================================================

class _LabeledInput extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledInput({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

// =============================================================================
// Rounded text field — matches the mockup's input style
// =============================================================================

class _RoundedTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;

  const _RoundedTextField({
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.gray400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon != null ? 14 : 16,
          vertical: 14,
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
                child: Icon(prefixIcon, color: AppColors.gray500, size: 22),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        border: _border(AppColors.gray200),
        enabledBorder: _border(AppColors.gray200),
        focusedBorder: _border(AppColors.primaryColor, width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

// =============================================================================
// Event type dropdown trigger
// =============================================================================

class _EventTypeDropdownTrigger extends StatelessWidget {
  final InvitationState state;
  const _EventTypeDropdownTrigger({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    final selected = state.selectedEventType;
    final hasSelection = selected != null;
    final hasTypes = state.availableEventTypes.isNotEmpty;
    final isLoading = state.isLoading && !hasTypes;

    final displayLabel = !hasSelection
        ? (l?.translate('invitation_select_event_type') ?? 'اختر نوع الفعالية')
        : selected.isCustom
            ? (state.customEventTypeName ??
                l?.translate('invitation_custom') ??
                'مخصص')
            : (isEnglish ? selected.name : selected.nameAr);

    return InkWell(
      // Always tappable. When the list is empty or still loading we still
      // open the sheet so the user gets feedback (loader / retry) instead
      // of a silent dead button.
      onTap: () => _showPicker(context, l, isEnglish),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(
              _iconFor(selected),
              color: AppColors.primaryColor,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasSelection ? context.textPrimary : AppColors.gray400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              )
            else
              Icon(Icons.expand_more_rounded, color: AppColors.gray500),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(EventTypeModel? type) {
    if (type == null) return Icons.event_outlined;
    if (type.isCustom) return Icons.more_horiz_rounded;
    final n = type.name.toLowerCase();
    if (n.contains('wed') || n.contains('marriage') || n.contains('engage')) {
      return Icons.celebration_rounded;
    }
    if (n.contains('birth')) return Icons.cake_rounded;
    if (n.contains('business') || n.contains('meet') || n.contains('corp')) {
      return Icons.business_center_rounded;
    }
    if (n.contains('graduat')) return Icons.school_rounded;
    return Icons.event_rounded;
  }

  Future<void> _showPicker(
      BuildContext context, AppLocalizations? l, bool isEnglish) async {
    final cubit = context.read<InvitationCubit>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<InvitationCubit, InvitationState>(
            buildWhen: (p, c) =>
                p.availableEventTypes != c.availableEventTypes ||
                p.isLoading != c.isLoading ||
                p.errorMessage != c.errorMessage ||
                p.selectedEventType != c.selectedEventType ||
                p.customEventTypeName != c.customEventTypeName,
            builder: (innerCtx, s) {
              return SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(sheetCtx).size.height * 0.75,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.gray300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              l?.translate('wizard_event_type_label') ??
                                  'نوع الفعالية',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: _PickerBody(
                          state: s,
                          isEnglish: isEnglish,
                          iconFor: _iconFor,
                          onSelect: (type) {
                            cubit.selectEventType(type);
                            Navigator.of(sheetCtx).pop();
                          },
                          onTapCustom: () async {
                            final name = await _promptCustomName(sheetCtx, l);
                            if (name == null || name.trim().isEmpty) return;
                            cubit.setCustomEventTypeName(name.trim());
                            if (sheetCtx.mounted) {
                              Navigator.of(sheetCtx).pop();
                            }
                          },
                          onRetry: () =>
                              cubit.initializeWizard(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<String?> _promptCustomName(
      BuildContext context, AppLocalizations? l) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l?.translate('invitation_custom_event_type_title') ??
                'نوع فعالية مخصص',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText:
                  l?.translate('invitation_custom_event_type_hint') ??
                      'اسم الفعالية المخصص',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (v) => Navigator.of(dialogCtx).pop(v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(l?.translate('common_cancel') ?? 'إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(controller.text.trim()),
              child: Text(l?.translate('common_save') ?? 'حفظ'),
            ),
          ],
        );
      },
    );
  }
}

class _PickerBody extends StatelessWidget {
  final InvitationState state;
  final bool isEnglish;
  final IconData Function(EventTypeModel?) iconFor;
  final void Function(EventTypeModel) onSelect;
  final VoidCallback onTapCustom;
  final VoidCallback onRetry;

  const _PickerBody({
    required this.state,
    required this.isEnglish,
    required this.iconFor,
    required this.onSelect,
    required this.onTapCustom,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasTypes = state.availableEventTypes.isNotEmpty;

    // Loading and empty are different things — show a spinner only when
    // we're actually loading and have nothing yet.
    if (!hasTypes && state.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );
    }

    if (!hasTypes && state.errorMessage != null) {
      return _EmptyOrErrorState(
        icon: Icons.cloud_off_outlined,
        title: l?.translate('invitation_event_types_failed') ??
            'تعذر تحميل أنواع الفعاليات',
        subtitle: l?.translate(state.errorMessage!) ?? state.errorMessage!,
        primaryLabel: l?.translate('home_try_again') ?? 'حاول مرة أخرى',
        onPrimaryTap: onRetry,
        secondaryLabel: l?.translate('invitation_use_custom_type') ??
            'استخدم نوع مخصص',
        onSecondaryTap: onTapCustom,
      );
    }

    if (!hasTypes) {
      return _EmptyOrErrorState(
        icon: Icons.event_busy_outlined,
        title: l?.translate('invitation_no_event_types') ??
            'لا توجد أنواع متاحة',
        subtitle: l?.translate('invitation_no_event_types_subtitle') ??
            'يمكنك إنشاء نوع مخصص أو إعادة المحاولة.',
        primaryLabel: l?.translate('invitation_use_custom_type') ??
            'استخدم نوع مخصص',
        onPrimaryTap: onTapCustom,
        secondaryLabel: l?.translate('home_try_again') ?? 'حاول مرة أخرى',
        onSecondaryTap: onRetry,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.availableEventTypes.length + 1, // +1 for "Custom"
      itemBuilder: (_, i) {
        if (i == state.availableEventTypes.length) {
          // Trailing "Custom event type" option.
          return _EventTypePickerRow(
            label: l?.translate('invitation_custom_event_type_option') ??
                'نوع آخر…',
            icon: Icons.add_circle_outline_rounded,
            isSelected: state.selectedEventType?.isCustom == true,
            onTap: onTapCustom,
          );
        }
        final type = state.availableEventTypes[i];
        return _EventTypePickerRow(
          label: isEnglish ? type.name : type.nameAr,
          icon: iconFor(type),
          isSelected: state.selectedEventType?.id == type.id,
          onTap: () => onSelect(type),
        );
      },
    );
  }
}

class _EmptyOrErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final String secondaryLabel;
  final VoidCallback onSecondaryTap;

  const _EmptyOrErrorState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimaryTap,
    required this.secondaryLabel,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.gray400),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onPrimaryTap,
            child: Text(primaryLabel),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onSecondaryTap,
            child: Text(
              secondaryLabel,
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTypePickerRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _EventTypePickerRow({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Date + Time card (start + optional end)
// =============================================================================

class _DateTimeCard extends StatelessWidget {
  final InvitationState state;
  const _DateTimeCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l?.translate('wizard_event_datetime_label') ??
                    'التاريخ والوقت',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DateTimeField(
            label: l?.translate('wizard_event_start_label') ?? 'بداية الفعالية',
            hint: l?.translate('wizard_event_start_hint') ??
                'اختر تاريخ ووقت البداية',
            icon: Icons.event_repeat_rounded,
            iconActive: true,
            date: state.eventDate,
            time: state.eventTime,
            onPick: (d, t) {
              final cubit = context.read<InvitationCubit>();
              cubit.updateDate(d);
              cubit.updateTime(t);
            },
          ),
          const SizedBox(height: 12),
          _DateTimeField(
            label: l?.translate('wizard_event_end_label') ?? 'نهاية الفعالية',
            hint: l?.translate('wizard_event_end_hint') ??
                'اختر تاريخ ووقت النهاية',
            icon: Icons.event_available_rounded,
            iconActive: false,
            date: state.eventEndDate,
            time: state.eventEndTime,
            // Default end pick to start date so the picker opens near a sane month.
            anchorDate: state.eventEndDate ?? state.eventDate,
            onPick: (d, t) {
              final cubit = context.read<InvitationCubit>();
              cubit.updateEndDate(d);
              cubit.updateEndTime(t);
            },
          ),
        ],
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool iconActive;
  final DateTime? date;
  final TimeOfDay? time;
  final DateTime? anchorDate;
  final void Function(DateTime, TimeOfDay) onPick;

  const _DateTimeField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconActive,
    required this.date,
    required this.time,
    required this.onPick,
    this.anchorDate,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode != 'en';
    final filled = date != null && time != null;
    final display = filled ? _format(date!, time!, isAr) : hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray500,
            ),
          ),
        ),
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: iconActive
                        ? AppColors.primaryColor
                        : AppColors.gray500,
                    size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    display,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
                      color:
                          filled ? context.textPrimary : AppColors.gray400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final initial =
        date ?? anchorDate ?? DateTime.now().add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked == null || !context.mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: time ?? const TimeOfDay(hour: 20, minute: 0),
    );
    if (pickedTime == null) return;
    onPick(picked, pickedTime);
  }

  String _format(DateTime d, TimeOfDay t, bool isAr) {
    const monthsAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const monthsEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = (isAr ? monthsAr : monthsEn)[d.month - 1];
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final am = t.period == DayPeriod.am;
    final ampm = isAr ? (am ? 'ص' : 'م') : (am ? 'AM' : 'PM');
    final mm = t.minute.toString().padLeft(2, '0');
    return isAr
        ? '${d.day} $month ${d.year}، ${hour12.toString().padLeft(2, '0')}:$mm $ampm'
        : '${d.day} $month ${d.year}, ${hour12.toString().padLeft(2, '0')}:$mm $ampm';
  }
}

// =============================================================================
// AI cover hero — image-based 21:9 with overlay
// =============================================================================

class _AiCoverHero extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;

  const _AiCoverHero({this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Row(
            children: [
              Text(
                l?.translate('wizard_invitation_cover') ?? 'غلاف الدعوة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l?.translate('wizard_ai_badge') ?? 'ذكاء اصطناعي',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 21 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _gradientBg(),
                      errorWidget: (_, __, ___) => _gradientBg(),
                    )
                  else
                    _gradientBg(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.10),
                          Colors.black.withValues(alpha: 0.70),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                            ),
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                imageUrl != null
                                    ? (l?.translate('ai_regenerate_image') ??
                                        'تغيير الصورة')
                                    : (l?.translate(
                                            'wizard_ai_cover_compact_title') ??
                                        'تصميم غلاف سحري'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l?.translate(
                                        'wizard_ai_cover_compact_subtitle') ??
                                    'ابتكر تصميماً فريداً بالذكاء الاصطناعي',
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _gradientBg() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Bottom action bar
// =============================================================================

class _BottomBar extends StatelessWidget {
  final InvitationState state;
  final TextEditingController nameController;

  const _BottomBar({required this.state, required this.nameController});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canProceed =
        state.canProceedFromEventType && state.canProceedFromEventDetails;
    final isLoading = state.isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          text: l?.translate('wizard_continue_to_guests') ??
              'متابعة إلى الضيوف',
          icon: Icons.arrow_forward_rounded,
          isLoading: isLoading,
          onPressed: canProceed && !isLoading
              ? () {
                  final cubit = context.read<InvitationCubit>();
                  if (nameController.text.isNotEmpty) {
                    cubit.updateEventName(nameController.text);
                  }
                  cubit.createDraftAndSaveDetails();
                }
              : null,
        ),
      ),
    );
  }
}
