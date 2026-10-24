import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/shell/app_shell.dart';
import '../../../../core/services/pending_wizard_intent_service.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../core/widgets/scaffold/app_content_width.dart';
import '../../../../injection_container.dart' as di;
import '../../../events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../../home/presentation/utils/refresh_event_lists.dart';
import '../../../invitation/presentation/cubit/invitation_cubit.dart';
import '../../../invitation/presentation/screens/invitation_wizard_screen.dart';
import '../../../scanner/data/door_session_manager.dart';
import '../../../scanner/domain/entities/door_entities.dart';
import '../../../scanner/presentation/screens/door_staff_shell.dart';
import '../../../settings/presentation/screens/change_password_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../screens/splash_screen.dart';
import '../screens/terms_acceptance_screen.dart';
import 'signed_out_flow.dart';
import 'unverified_otp_dialog.dart';

/// Decides what the app shows: the splash, then (signed in) a forced
/// password change, new Terms to accept, or the app itself; (signed out) a
/// staff phone's door, or browsing / sign-in / sign-up.
///
/// Institutions not approved yet enter the app too, as on the web portal:
/// home tells them how far their file is, and events go live after approval.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key, this.skipSplash = false, this.pendingIntents, this.onOpenWizard});

  /// Skips the splash animation (tests).
  final bool skipSplash;

  /// Browse → sign-up → wizard hand-off. Defaults to the DI singleton.
  final PendingWizardIntentService? pendingIntents;

  /// Opens the wizard for a consumed intent (overridable for tests).
  final void Function(BuildContext context, PendingWizardIntent intent)? onOpenWizard;

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late bool _showSplash = !widget.skipSplash;

  /// Set while a team-opened account must replace its temporary password.
  String? _forcedPasswordPhone;

  /// Set while a newly published Terms / Privacy version awaits acceptance.
  bool _mustAcceptTerms = false;

  /// After signing out, the sign-in screen opens instead of browsing.
  bool _wasSignedIn = false;

  /// Door-only mode of a staff phone, restored after a restart.
  DoorSession? _staffSession;

  late final PendingWizardIntentService _intents =
      widget.pendingIntents ??
      (di.sl.isRegistered<PendingWizardIntentService>()
          ? di.sl<PendingWizardIntentService>()
          : PendingWizardIntentService());

  @override
  void initState() {
    super.initState();
    if (di.sl.isRegistered<DoorSessionManager>()) {
      di
          .sl<DoorSessionManager>()
          .activeStaffSession()
          .then((s) {
            if (mounted && s != null) setState(() => _staffSession = s);
          })
          .catchError((_) {});
    }
  }

  void _onAuthSuccess() {
    context.read<HomeCubit>().load();
    context.read<EventsListCubit>().loadEvents();
  }

  /// After sign-in, continue into the wizard with what was picked while
  /// browsing (consumed once).
  void _continuePendingIntent() {
    final intent = _intents.consume();
    if (intent == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) (widget.onOpenWizard ?? _openWizard)(context, intent);
    });
  }

  static void _openWizard(BuildContext context, PendingWizardIntent intent) {
    final navigator = Navigator.of(context);
    navigator
        .push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider(
              create: (_) => di.sl<InvitationCubit>(),
              child: InvitationWizardScreen(
                initialEventTypeId: intent.eventTypeId,
                initialTemplateId: intent.templateId,
                onComplete: navigator.pop,
              ),
            ),
          ),
        )
        .then((_) => context.mounted ? refreshEventLists(context) : null);
  }

  /// A sign-in on a number never confirmed: a code goes out at once.
  void _confirmNumber(String phone) {
    final auth = context.read<AuthCubit>()..resendOtp(login: phone, purpose: 'registration');
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialog) => BlocProvider.value(
        value: auth,
        child: UnverifiedAccountOtpDialog(
          phone: phone,
          onVerified: () {
            Navigator.of(dialog).pop();
            _onAuthSuccess();
          },
          onCancel: () {
            Navigator.of(dialog).pop();
            auth.resetState();
          },
        ),
      ),
    );
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state is AuthUnauthenticated || state is AuthAccountDeleted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      if (state is AuthAccountDeleted) _intents.clear();
    }
    if (state is AuthUnverified) _confirmNumber(state.phone);
    if (state is AuthAuthenticated) {
      _wasSignedIn = true;
      _onAuthSuccess();
      _continuePendingIntent();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onFinished: () => mounted ? setState(() => _showSplash = false) : null);
    }
    return BlocConsumer<AuthCubit, AuthState>(listener: _onAuthState, builder: _screenFor);
  }

  Widget _screenFor(BuildContext context, AuthState state) {
    if (state is AuthInitial) {
      return const Scaffold(
        body: Center(child: MkSpinner(valueColor: AlwaysStoppedAnimation(AppColors.primaryColor))),
      );
    }

    // A temporary password from the team: the client chooses their own first.
    // While the change is in flight the cubit leaves AuthAuthenticated, so the
    // screen stays until the refreshed profile comes back without the flag.
    if (state is AuthAuthenticated) {
      _forcedPasswordPhone = state.user.mustChangePassword ? (state.user.phone ?? '') : null;
      _mustAcceptTerms = state.user.mustAcceptTerms;
    } else if (state is AuthUnauthenticated) {
      _forcedPasswordPhone = null;
      _mustAcceptTerms = false;
    }
    if (_forcedPasswordPhone != null) {
      return _column(PopScope(canPop: false, child: ChangePasswordScreen(phone: _forcedPasswordPhone!, forced: true)));
    }
    if (_mustAcceptTerms) return _column(const PopScope(canPop: false, child: TermsAcceptanceScreen()));
    if (state is AuthAuthenticated) return const AppShell();

    final staff = _staffSession;
    if (staff != null) {
      return _column(
        DoorStaffShell(key: ValueKey(staff.id), session: staff, onLeft: () => setState(() => _staffSession = null)),
      );
    }
    return _column(
      SignedOutFlow(
        key: ValueKey(_wasSignedIn),
        intents: _intents,
        onAuthSuccess: _onAuthSuccess,
        onStaffSession: (session) => setState(() => _staffSession = session),
        start: _wasSignedIn ? SignedOutPage.login : SignedOutPage.explore,
      ),
    );
  }

  /// Screens not rebuilt for wide windows yet keep the readable column.
  static Widget _column(Widget child) => AppContentWidth(child: child);
}
