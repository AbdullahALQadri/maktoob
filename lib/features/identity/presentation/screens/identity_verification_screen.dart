import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../injection_container.dart' as di;
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../institution/presentation/widgets/institution_widgets.dart';
import '../../domain/entities/identity_entities.dart';
import '../cubit/identity_cubit.dart';
import '../cubit/identity_state.dart';
import '../widgets/widgets.dart';

/// Settings → Identity verification: the current state, and the form that
/// sends a photo of the ID document with the legal name typed in parts.
/// Uploading needs a connection; nothing is queued offline.
class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<IdentityCubit>(),
          child: const IdentityVerificationScreen(),
        ),
      );

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  /// Verified or under review: the form opens on request ("send a new document").
  bool _showForm = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<IdentityCubit>().load(locale: Localizations.localeOf(context).languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocConsumer<IdentityCubit, IdentityState>(
      listener: (context, state) {
        if (state is! IdentityLoaded || state.message == null) return;
        final text = t.translateOr(state.message!, state.message!);
        if (state.messageIsError) {
          AppSnackBar.showError(context, message: text);
        } else {
          AppSnackBar.showSuccess(context, message: text);
        }
        if (state.justSubmitted) {
          setState(() => _showForm = false);
          context.read<AuthCubit>().refreshProfile();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          appBar: MaktoobAppBar(title: t.translate('identity_title')),
          body: SafeArea(child: _body(context, state, t)),
        );
      },
    );
  }

  Widget _body(BuildContext context, IdentityState state, AppLocalizations t) {
    final cubit = context.read<IdentityCubit>();

    if (state is IdentityError) {
      return Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: AppSpacing.iconXl, color: context.iconSecondary),
              const SizedBox(height: AppSpacing.md),
              Text(t.translateOr(state.message, state.message), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              TextButton(onPressed: () => cubit.load(), child: Text(t.translate('common_retry'))),
            ],
          ),
        ),
      );
    }
    if (state is! IdentityLoaded) return const Center(child: MkSpinner());

    final overview = state.overview;
    final identity = overview.identity;
    final formOpen = _showForm || identity.status == IdentityStatus.none || identity.status == IdentityStatus.rejected;

    return RefreshIndicator(
      onRefresh: () => cubit.load(silent: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          IdentityStatusCard(identity: identity, countryName: overview.options.countryName),
          const SizedBox(height: AppSpacing.md),
          if (!formOpen) ...[
            Text(
              t.translate(identity.isVerified ? 'identity_change_needs_new_document' : 'identity_replace_pending_note'),
              style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              key: const Key('identity_open_form'),
              onPressed: () => setState(() => _showForm = true),
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(t.translate('identity_send_new_document')),
            ),
          ] else ...[
            OutlinedCard(
              child: IdentityForm(
                options: overview.options,
                serverErrors: state.fieldErrors,
                busy: state.isSubmitting,
                onSubmit: cubit.submit,
              ),
            ),
          ],
          if (overview.submissions.isNotEmpty) ...[
            SectionTitle(t.translate('identity_history')),
            for (final s in overview.submissions)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                child: OutlinedCard(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              [
                                t.translate('identity_doc_type_${s.documentType}'),
                                if ((s.last4 ?? '').isNotEmpty) '•••• ${s.last4}',
                              ].join(' · '),
                              style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
                            ),
                            if ((s.submittedAt ?? '').length >= 10)
                              Text(
                                s.submittedAt!.substring(0, 10),
                                textDirection: TextDirection.ltr,
                                style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
                              ),
                            if (s.status == 'rejected' && (s.rejectionReason ?? '').isNotEmpty)
                              Text(
                                s.rejectionReason!,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.red500),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        t.translate('identity_submission_${s.status}'),
                        style: AppTextStyles.labelMedium.copyWith(color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
