import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/network/saved_copy_note.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../authentication/presentation/cubit/auth_state.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../../institution/presentation/screens/institution_screen.dart';
import '../../../invitation/presentation/screens/invitation_wizard_screen.dart';
import '../../../events/domain/entities/event_card.dart';
import '../../domain/entities/home_summary.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_error_state.dart';
import '../widgets/home_events_section.dart';
import '../widgets/home_first_visit.dart';
import '../widgets/home_hero.dart';
import '../widgets/home_kpis.dart';
import '../widgets/home_loading.dart' as skeleton;
import '../widgets/home_top_bar.dart';
import '../widgets/institution_notice.dart';

/// Home: the hour's banner with the nearest occasion and its next step, the
/// four numbers, then the events that need the host first. The same
/// content as the web dashboard, laid out for the window.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onViewEvent, this.onCreateEvent, this.onViewAllEvents});

  final ValueChanged<String>? onViewEvent;
  final VoidCallback? onCreateEvent;

  /// Opens the My events tab.
  final VoidCallback? onViewAllEvents;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
  }

  /// Setup steps continue in the wizard; everything else opens the event.
  void _act(EventCard event) {
    const wizardSteps = {NextAction.completeDetails, NextAction.addGuests, NextAction.chooseDesign, NextAction.pay};
    if (event.status == EventStatus.draft && event.role.canManage && wizardSteps.contains(event.nextAction)) {
      context.openInvitationWizardWithDraft(event.id);
    } else {
      widget.onViewEvent?.call('${event.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: HomeTopBar(onOpenEvent: widget.onViewEvent),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoaded(:final summary) => RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: context.read<HomeCubit>().load,
            child: _Content(
              summary: summary,
              onAction: _act,
              onCreate: widget.onCreateEvent ?? context.openInvitationWizard,
              onViewAll: widget.onViewAllEvents ?? () {},
            ),
          ),
          HomeError(:final message) => HomeErrorState(message: message, onRetry: context.read<HomeCubit>().load),
          _ => const skeleton.HomeLoading(),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.summary, required this.onAction, required this.onCreate, required this.onViewAll});

  final HomeSummary summary;
  final ValueChanged<EventCard> onAction;
  final VoidCallback onCreate;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthCubit, UserEntity?>(
      (c) => switch (c.state) {
        AuthAuthenticated(:final user) => user,
        _ => null,
      },
    );
    final institution = user?.institution;
    final gutter = EdgeInsetsDirectional.symmetric(horizontal: context.pageGutter);
    Widget padded(Widget child) => Padding(padding: gutter, child: child);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.only(top: 8, bottom: 32),
      children: [
        if (summary.isSavedCopy) ...[padded(const SavedCopyNote()), const SizedBox(height: 12)],
        padded(
          HomeHero(
            summary: summary,
            firstName: _firstName(user?.name ?? ''),
            orgLine: _orgLine(context, user),
            onCreate: onCreate,
            onMyEvents: onViewAll,
            onAction: onAction,
          ),
        ),
        if (user != null && user.needsInstitutionApproval && institution != null) ...[
          const SizedBox(height: 22),
          padded(
            InstitutionNotice(
              status: institution.status,
              verification: institution.verification,
              onComplete: () => Navigator.of(context).push(InstitutionScreen.route()),
            ),
          ),
        ],
        const SizedBox(height: 22),
        if (summary.isFirstVisit)
          padded(const HomeFirstVisit())
        else ...[
          padded(HomeKpis(totals: summary.totals)),
          const SizedBox(height: 26),
          HomeEventsSection(events: summary.events, onOpen: onAction, onViewAll: onViewAll),
        ],
      ],
    );
  }

  static String _firstName(String name) => name.trim().split(RegExp(r'\s+')).first;

  /// "Al-Nour Society · 300 invitation credits · 10% off" for an approved institution.
  static String? _orgLine(BuildContext context, UserEntity? user) {
    final institution = user?.institution;
    if (user == null || institution == null || !user.isApprovedInstitutionOwner) return null;
    final name = institution.officialName(context.languageCode == 'ar');
    final balance = context.tr('home_inst_line', {
      'credits': institution.invitationCredits,
      'discount': institution.discountPercent.round(),
    });
    return '$name · $balance';
  }
}
