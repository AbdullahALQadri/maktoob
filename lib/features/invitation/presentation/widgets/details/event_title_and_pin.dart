import 'package:flutter/material.dart';
import '../../../../../config/locale/app_localizations.dart';
import '../../../../../core/core.dart';
import '../../../domain/utils/event_setup_rules.dart';
import '../../cubit/invitation_state.dart';
import 'wizard_inputs.dart';


class EventTitleInput extends StatelessWidget {
  final TextEditingController controller;
  final InvitationState state;
  final ValueChanged<String> onChanged;

  const EventTitleInput({
    super.key,
    required this.controller,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final type = state.selectedEventType;
    final suggestion = EventSetupRules.suggestTitle(
      slug: type?.slug,
      typeNameAr: type?.nameAr,
      values: state.eventTypeFormData,
    );
    final typed = (state.eventName ?? '').trim();
    final prefix = l?.translate('wizard_title_suggestion') ?? 'سيظهر كـ:';

    return WizardLabeledInput(
      label: l?.translate('wizard_event_name_label') ?? 'عنوان الدعوة (اختياري)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WizardTextField(
            controller: controller,
            hintText: suggestion,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l?.translate('wizard_event_name_hint') ??
                'نكتبه لك تلقائياً من الأسماء، أو اكتب عنوانك',
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
          if (typed.isEmpty && type != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.auto_awesome_outlined,
                    size: 16, color: AppColors.primaryColor),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '$prefix $suggestion',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}



class MapPinButton extends StatelessWidget {
  final InvitationState state;
  final VoidCallback onPick;
  const MapPinButton({super.key, required this.state, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = state.customLocation;
    final pinned =
        loc != null && EventSetupRules.isInGaza(loc.latitude, loc.longitude);

    return OutlinedButton.icon(
      onPressed: onPick,
      icon: Icon(pinned ? Icons.check_circle_rounded : Icons.map_outlined,
          size: 20),
      label: Text(
        pinned
            ? (l?.translate('wizard_location_pinned') ??
                'تم تحديد الموقع على الخريطة (تعديل)')
            : (l?.translate('wizard_pick_on_map') ?? 'حدّد الموقع على الخريطة'),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: const BorderSide(color: AppColors.gray200),
        padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      ),
    );
  }
}
