import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/institution_entity.dart';

/// Flat card with a 1px outline (DESIGN.md).
class OutlinedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const OutlinedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.themeSurface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: child,
    );
  }
}

/// Pending / approved / rejected pill.
class InstitutionStatusBadge extends StatelessWidget {
  final InstitutionStatus status;

  const InstitutionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final (Color bg, Color fg) = switch (status) {
      InstitutionStatus.approved => (AppColors.green50, AppColors.green600),
      InstitutionStatus.rejected => (AppColors.red100, AppColors.red500),
      InstitutionStatus.pending => (AppColors.amber50, AppColors.amber700),
      InstitutionStatus.suspended => (AppColors.gray100, AppColors.gray700),
    };
    return Container(
      key: Key('institution_status_${status.name}'),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.borderRadiusRound,
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Text(
        t.translate(status.labelKey),
        style: AppTextStyles.labelMedium.copyWith(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Square logo, or a building icon when there is none.
class InstitutionLogo extends StatelessWidget {
  final String? url;
  final double size;

  const InstitutionLogo({super.key, this.url, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(Icons.business_rounded, color: AppColors.primaryColor, size: size * 0.5);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: AlignmentDirectional.center,
      child: (url ?? '').isEmpty
          ? placeholder
          : Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder),
    );
  }
}

/// A label/value row inside a details card.
class InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const InfoRow({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    if ((value ?? '').isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary)),
          ),
          Expanded(
            child: Text(value!, style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary)),
          ),
        ],
      ),
    );
  }
}

/// Section title used by the institution screens.
class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTextStyles.titleMedium.copyWith(color: context.textPrimary, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Shows a one-shot cubit message: translation key or server text.
void showInstitutionMessage(BuildContext context, String? message, {bool isError = false}) {
  if (message == null || message.isEmpty) return;
  final t = AppLocalizations.of(context)!;
  final text = t.translateOr(message, message);
  if (isError) {
    AppSnackBar.showError(context, message: text);
  } else {
    AppSnackBar.showSuccess(context, message: text);
  }
}
