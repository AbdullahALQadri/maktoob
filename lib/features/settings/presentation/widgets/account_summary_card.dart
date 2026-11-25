import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/page/page_kit.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../authentication/presentation/cubit/auth_state.dart';

/// Who is signed in: photo, name, sign-in number, the kind of account. Shows
/// the account from the session, or [user] when one is given (the profile).
class AccountSummaryCard extends StatelessWidget {
  const AccountSummaryCard({super.key, this.user, this.onTap});

  final UserEntity? user;

  /// Opens the profile; no arrow when null.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final given = user;
    if (given != null) return _card(context, given);
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (before, now) => now is AuthAuthenticated,
      builder: (context, state) => state is AuthAuthenticated ? _card(context, state.user) : const SizedBox.shrink(),
    );
  }

  Widget _card(BuildContext context, UserEntity user) {
    final contact = (user.phone ?? '').isNotEmpty ? user.phone! : user.email;
    final forward = Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right;
    return PageCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        key: const Key('account_summary'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Row(
            children: [
              AppAvatar(
                imageUrl: user.avatar,
                initials: user.initials,
                size: 56,
                backgroundColor: context.primaryWash,
                textColor: context.primaryText,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.textPrimary),
                    ),
                    if (contact.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(fontSize: 13, color: context.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        PagePill(
                          icon: user.isInstitution ? Icons.business : Icons.person,
                          label: context.tr(user.isInstitution ? 'auth_institution' : 'auth_individual'),
                        ),
                        if (user.isIdentityVerified)
                          PagePill(icon: Icons.verified, label: context.tr('profile_verified')),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) Icon(forward, size: 20, color: context.iconDefault),
            ],
          ),
        ),
      ),
    );
  }
}
