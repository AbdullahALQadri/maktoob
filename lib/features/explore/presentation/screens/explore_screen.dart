import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/template_preview_entity.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import '../widgets/widgets.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

/// Browse-without-account home. Shown when nobody is signed in so new users
/// and store reviewers can look around. Uses `/public/*` endpoints only;
/// any create action hands over to sign-up via [onStartTap].
///
/// Tapping a design calls [onDesignTap] with the occasion type (the
/// design's own, else the selected chip) and the design id, so the caller
/// can continue into the wizard after sign-up. Without it, [onStartTap].
typedef ExploreDesignTap = void Function(int? eventTypeId, int? templateId);

class ExploreScreen extends StatelessWidget {
  final VoidCallback onStartTap;
  final VoidCallback onLoginTap;
  final ExploreDesignTap? onDesignTap;

  const ExploreScreen({
    super.key,
    required this.onStartTap,
    required this.onLoginTap,
    this.onDesignTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExploreCubit>(
      create: (_) => di.sl<ExploreCubit>()..load(),
      child: _ExploreView(
        onStartTap: onStartTap,
        onLoginTap: onLoginTap,
        onDesignTap: onDesignTap,
      ),
    );
  }
}

class _ExploreView extends StatelessWidget {
  final VoidCallback onStartTap;
  final VoidCallback onLoginTap;
  final ExploreDesignTap? onDesignTap;

  const _ExploreView({
    required this.onStartTap,
    required this.onLoginTap,
    this.onDesignTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: () => context.read<ExploreCubit>().load(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      sliver: SliverToBoxAdapter(child: _Hero(t: t)),
                    ),
                    BlocBuilder<ExploreCubit, ExploreState>(
                      builder: (context, state) => _body(context, t, state),
                    ),
                  ],
                ),
              ),
            ),
            _BottomActions(
              t: t,
              onStartTap: onStartTap,
              onLoginTap: onLoginTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations t, ExploreState state) {
    // Nothing to browse (server unreachable or not updated) reads as an
    // error with a retry, never as a blank screen.
    if (state is ExploreError || (state is ExploreLoaded && state.groups.isEmpty)) {
      return SliverPadding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              Text(
                t.translate('explore_load_error'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: context.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextButton(
                text: t.translate('explore_retry'),
                onPressed: () => context.read<ExploreCubit>().load(),
              ),
            ],
          ),
        ),
      );
    }

    if (state is! ExploreLoaded) {
      return const SliverPadding(
        padding: EdgeInsetsDirectional.all(AppSpacing.xl),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: MkSpinner(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
        ),
      );
    }

    final lang = Localizations.localeOf(context).languageCode;
    final cubit = context.read<ExploreCubit>();
    final group = state.selectedGroup;

    return SliverPadding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _SectionTitle(text: t.translate('explore_occasions_title')),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.8,
            children: [
              for (final g in state.groups)
                OccasionGroupCard(
                  group: g,
                  selected: g.id == state.selectedGroupId,
                  onTap: () => cubit.selectGroup(g.id),
                ),
            ],
          ),
          if (group != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle(text: t.translate('explore_designs_title')),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: group.types.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final type = group.types[i];
                  return ChoiceChip(
                    label: Text(type.localizedName(lang)),
                    selected: type.id == state.selectedTypeId,
                    showCheckmark: false,
                    selectedColor:
                        AppColors.primaryColor.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: type.id == state.selectedTypeId
                          ? AppColors.primaryColor
                          : context.borderColor,
                    ),
                    onSelected: (_) => cubit.selectType(type.id),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _Gallery(
              state: state,
              t: t,
              onTemplateTap: (tpl) {
                final tap = onDesignTap;
                if (tap == null) {
                  onStartTap();
                } else {
                  tap(tpl.eventTypeId ?? state.selectedTypeId, tpl.id);
                }
              },
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ]),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final AppLocalizations t;

  const _Hero({required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('explore_brand'),
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          t.translate('explore_hero_title'),
          style: AppTextStyles.headlineMedium.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          t.translate('explore_hero_subtitle'),
          style:
              AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTextStyles.titleSmall.copyWith(
          color: context.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  final ExploreLoaded state;
  final AppLocalizations t;
  final ValueChanged<TemplatePreviewEntity> onTemplateTap;

  const _Gallery({
    required this.state,
    required this.t,
    required this.onTemplateTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state.templatesLoading) {
      return const Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Center(
          child: MkSpinner(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );
    }
    if (state.templates.isEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Text(
          t.translate('explore_no_designs'),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.templates.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (_, i) => TemplatePreviewTile(
        template: state.templates[i],
        onTap: () => onTemplateTap(state.templates[i]),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final AppLocalizations t;
  final VoidCallback onStartTap;
  final VoidCallback onLoginTap;

  const _BottomActions({
    required this.t,
    required this.onStartTap,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        AppSpacing.smd,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.themeSurface,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: t.translate('explore_start_free'),
              onPressed: onStartTap,
            ),
          ),
          TextButton(
            onPressed: onLoginTap,
            child: Text(
              t.translate('explore_have_account'),
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
