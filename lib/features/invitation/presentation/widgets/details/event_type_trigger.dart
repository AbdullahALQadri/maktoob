import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/locale/app_localizations.dart';
import '../../../../../core/core.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';
import 'event_type_picker_body.dart';


class EventTypeTrigger extends StatelessWidget {
  final InvitationState state;
  const EventTypeTrigger({super.key, required this.state});

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
                child: MkSpinner(
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
                        child: EventTypePickerBody(
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
