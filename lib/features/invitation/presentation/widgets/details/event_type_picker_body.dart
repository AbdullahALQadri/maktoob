import 'package:flutter/material.dart';
import '../../../../../config/locale/app_localizations.dart';
import '../../../../../core/core.dart';
import '../../cubit/invitation_state.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';
import 'event_type_picker_parts.dart';

class EventTypePickerBody extends StatefulWidget {
  final InvitationState state;
  final bool isEnglish;
  final IconData Function(EventTypeModel?) iconFor;
  final void Function(EventTypeModel) onSelect;
  final VoidCallback onTapCustom;
  final VoidCallback onRetry;

  const EventTypePickerBody({
    super.key,
    required this.state,
    required this.isEnglish,
    required this.iconFor,
    required this.onSelect,
    required this.onTapCustom,
    required this.onRetry,
  });

  @override
  State<EventTypePickerBody> createState() => _EventTypePickerBodyState();
}


class _EventTypePickerBodyState extends State<EventTypePickerBody> {
  /// Step B when non-null: the group whose types are listed.
  EventTypeGroupModel? _openGroup;

  InvitationState get state => widget.state;
  bool get isEnglish => widget.isEnglish;
  VoidCallback get onTapCustom => widget.onTapCustom;
  VoidCallback get onRetry => widget.onRetry;

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
          child: MkSpinner(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );
    }

    if (!hasTypes && state.errorMessage != null) {
      return EventTypePickerNotice(
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
      return EventTypePickerNotice(
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

    // Older backend without occasion groups: flat list.
    if (state.availableEventTypeGroups.isEmpty) {
      return _flatList(context, state.availableEventTypes, l, showCustom: true);
    }

    final group = _openGroup;
    if (group == null) {
      return EventTypeGroupGrid(
        groups: state.availableEventTypeGroups,
        isEnglish: isEnglish,
        selectedGroupId: _groupIdOf(state.selectedEventType),
        onTap: (g) => setState(() => _openGroup = g),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => _openGroup = null),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.mdl, vertical: AppSpacing.smd),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_rounded,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    isEnglish ? group.nameEn : group.nameAr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                Text(
                  l?.translate('wizard_back_to_groups') ?? 'كل الفئات',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.primaryColor),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.gray200),
        Flexible(
          child: _flatList(context, _typesOf(group), l,
              showCustom: _isOtherGroup(group)),
        ),
      ],
    );
  }

  int? _groupIdOf(EventTypeModel? type) {
    if (type == null) return null;
    if (type.groupId != null) return type.groupId;
    // Custom types (no group) live under "other".
    for (final g in state.availableEventTypeGroups) {
      if (g.isOther) return g.id;
    }
    return null;
  }

  bool _isOtherGroup(EventTypeGroupModel g) {
    if (g.isOther) return true;
    // No explicit "other" slug: the custom entry goes in the last group.
    final groups = state.availableEventTypeGroups;
    return !groups.any((x) => x.isOther) && groups.last.id == g.id;
  }

  List<EventTypeModel> _typesOf(EventTypeGroupModel g) {
    final knownIds = state.availableEventTypeGroups.map((x) => x.id).toSet();
    return state.availableEventTypes.where((t) {
      if (t.groupId == g.id) return true;
      // Ungrouped / unknown-group types fall under "other".
      return _isOtherGroup(g) &&
          (t.groupId == null || !knownIds.contains(t.groupId));
    }).toList();
  }

  Widget _flatList(BuildContext context, List<EventTypeModel> types,
      AppLocalizations? l,
      {required bool showCustom}) {
    final count = types.length + (showCustom ? 1 : 0);
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
      itemCount: count,
      itemBuilder: (_, i) {
        if (i == types.length) {
          // Trailing "Custom event type" option.
          return EventTypePickerRow(
            label: l?.translate('invitation_custom_event_type_option') ??
                'نوع آخر…',
            icon: Icons.add_circle_outline_rounded,
            isSelected: state.selectedEventType?.isCustom == true,
            onTap: widget.onTapCustom,
          );
        }
        final type = types[i];
        return EventTypePickerRow(
          label: isEnglish ? type.name : type.nameAr,
          icon: widget.iconFor(type),
          isSelected: state.selectedEventType?.id == type.id,
          onTap: () => widget.onSelect(type),
        );
      },
    );
  }
}
