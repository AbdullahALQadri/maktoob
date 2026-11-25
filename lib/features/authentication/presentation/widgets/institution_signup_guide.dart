import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import 'register_form_field.dart';

/// The backend's `representative_role` values.
const _roles = ['owner', 'director', 'authorized'];

/// Institution sign-up, said plainly: one person opens the account in their
/// own name, the organisation's details go beside theirs, and colleagues are
/// invited later from Team.
class InstitutionSignupIntro extends StatelessWidget {
  const InstitutionSignupIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: context.isDarkMode ? context.chipBg : AppColors.sky50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('auth_inst_who_title'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('auth_inst_who_text'),
            style: TextStyle(fontSize: 14, height: 1.6, color: context.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('auth_inst_who_team'),
            style: TextStyle(fontSize: 14, height: 1.6, color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// "1  The organisation" / "2  You": the two halves of the institution form.
class SignupStepTitle extends StatelessWidget {
  const SignupStepTitle({super.key, required this.number, required this.title});

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
          child: Text(
            '$number',
            style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// Who the person signing up is for the organisation, in everyday words.
/// Values are the backend's `representative_role` keys.
class RepresentativeRoleField extends StatelessWidget {
  const RepresentativeRoleField({super.key, required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = {for (final role in _roles) role: context.tr('auth_inst_role_$role')};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterDropdownField(
          key: const Key('register_representative_role'),
          label: context.tr('institution_representative_role'),
          hint: context.tr('auth_inst_role_hint'),
          icon: Icons.badge_outlined,
          items: labels.values.toList(),
          value: labels[value],
          onChanged: (label) => onChanged(labels.entries.firstWhere((e) => e.value == label).key),
          validator: (label) => label == null ? context.tr('auth_field_required') : null,
        ),
        if (value == 'authorized') ...[
          const SizedBox(height: 6),
          Text(
            context.tr('auth_inst_role_letter_note'),
            style: TextStyle(fontSize: 13, height: 1.5, color: context.textTertiary),
          ),
        ],
      ],
    );
  }
}

/// "Our team reviews the organisation before its events go live."
class InstitutionReviewBanner extends StatelessWidget {
  const InstitutionReviewBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 12),
      child: Container(
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          color: AppColors.amber50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.amber200),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.amber600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr('auth_institution_review'),
                style: AppTextStyles.caption.copyWith(color: AppColors.amber700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
