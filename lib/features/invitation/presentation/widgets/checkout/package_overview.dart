import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/locale/app_localizations.dart';
import '../../../../../core/core.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';
import '../../widgets/widgets.dart';
import 'selected_package_card.dart';


/// Package step: picker when nothing is chosen; otherwise the chosen
/// package, a guests-vs-limit warning, and a way to change it (allowed
/// until payment — the backend replaces the previous choice).
class PackageOverview extends StatelessWidget {
  final InvitationState state;
  final bool isEnglish;
  final TextEditingController customLimitController;

  const PackageOverview({
    super.key,
    required this.state,
    required this.isEnglish,
    required this.customLimitController,
  });

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedPackage;
    if (state.isLoadingPackages || selected == null) {
      return SelectedPackageCard(
        state: state,
        isEnglish: isEnglish,
        customLimitController: customLimitController,
      );
    }
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectedPackageCard(
          state: state,
          isEnglish: isEnglish,
          customLimitController: customLimitController,
        ),
        PackageLimitNotice(state: state, isEnglish: isEnglish),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: state.isSaving
                ? null
                : () => context.read<InvitationCubit>().clearPackage(),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text(
              l?.translate('wizard_change_package') ?? 'تغيير الباقة',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}


/// Warns when the host added more guests than the chosen package allows and
/// suggests the backend's best-fitting package.
class PackageLimitNotice extends StatelessWidget {
  final InvitationState state;
  final bool isEnglish;
  const PackageLimitNotice({super.key, required this.state, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedPackage;
    final guests = state.guests.length;
    final limit = selected?.isCustom == true
        ? state.customPackageLimit
        : selected?.invitationLimit;
    if (selected == null ||
        limit == null ||
        limit <= 0 ||
        selected.hasUnlimitedInvitations && !selected.isCustom ||
        guests <= limit) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    PackageModel? suggested;
    for (final p in state.availablePackages) {
      if (p.id == state.suggestedPackageId) suggested = p;
    }
    var text = (l?.translate('wizard_guests_over_limit') ??
            'أضفت {guests} ضيفاً والباقة تسمح بـ {limit} دعوة فقط.')
        .replaceAll('{guests}', '$guests')
        .replaceAll('{limit}', '$limit');
    if (suggested != null && suggested.id != selected.id) {
      text += ' ${(l?.translate('wizard_suggest_package') ?? 'ننصحك بباقة {name}.').replaceAll('{name}', isEnglish ? suggested.name : suggested.nameAr)}';
    }
    return Container(
      margin: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.amber50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.amber700),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: context.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}


class PackagePicker extends StatelessWidget {
  final InvitationState state;
  final bool isEnglish;
  const PackagePicker({super.key, required this.state, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    if (state.availablePackages.isEmpty) {
      return const PackageListSkeleton();
    }

    final l = AppLocalizations.of(context);
    final hasFree = state.availablePackages.any((p) => p.isFree);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasFree)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            child: Text(
              state.freeTrialAvailable
                  ? (l?.translate('wizard_free_trial_explainer') ??
                        'تجربة مجانية: دعوة واحدة لتجرّب كيف تصل الدعوة')
                  : (l?.translate('wizard_free_trial_used_note') ??
                        'استخدمت تجربتك المجانية على هذا الرقم، اختر باقة للمتابعة.'),
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ),
        for (final package in state.availablePackages.where(
          (p) => p.isAvailable,
        )) ...[
          PackageCard(
            package: package,
            isSelected: state.selectedPackage?.id == package.id,
            guestCount: state.guests.length,
            customPrice: state.customPackagePrice,
            isLoadingPrice: state.isLoadingCustomPrice,
            customLimit: state.customPackageLimit,
            isEnglish: isEnglish,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
