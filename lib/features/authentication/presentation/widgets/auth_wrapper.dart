import '../../../home/presentation/utils/refresh_event_lists.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../config/screens/main_shell.dart';
import '../../../../core/core.dart';
import '../../../../core/services/pending_wizard_intent_service.dart';
import '../../../../injection_container.dart' as di;
import '../../../events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../../explore/presentation/screens/explore_screen.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../../invitation/presentation/cubit/invitation_cubit.dart';
import '../../../invitation/presentation/screens/invitation_wizard_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../screens/admin_approval_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/terms_acceptance_screen.dart';
import '../../../settings/presentation/screens/change_password_screen.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

class AuthWrapper extends StatefulWidget {
  /// Skips the splash animation (tests).
  final bool skipSplash;

  /// Explore → sign-up → wizard hand-off. Defaults to the DI singleton.
  final PendingWizardIntentService? pendingIntents;

  /// Opens the wizard for a consumed intent. Defaults to pushing
  /// [InvitationWizardScreen] (overridable for tests).
  final void Function(BuildContext context, PendingWizardIntent intent)?
      onOpenWizard;

  const AuthWrapper({
    super.key,
    this.skipSplash = false,
    this.pendingIntents,
    this.onOpenWizard,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late bool _showSplash = !widget.skipSplash;
  bool _showRegister = false;

  /// Signed-out users land on the browse-without-account home first;
  /// sign-up / sign-in is asked only when they want to create something.
  bool _showExplore = true;

  /// Login / register was opened from Explore: Android back returns there.
  bool _cameFromExplore = false;

  /// Set while a team-opened account must replace its temporary password.
  String? _forcedPasswordPhone;

  /// Set while the client must accept a newly published Terms / Privacy
  /// version (kept through loading / error until the profile clears it).
  bool _mustAcceptTerms = false;

  late final PendingWizardIntentService _intents = widget.pendingIntents ??
      (di.sl.isRegistered<PendingWizardIntentService>()
          ? di.sl<PendingWizardIntentService>()
          : PendingWizardIntentService());

  void _onSplashFinished() {
    if (!mounted) return;
    setState(() => _showSplash = false);
  }

  void _goToRegister() {
    setState(() {
      if (_showExplore) _cameFromExplore = true;
      _showExplore = false;
      _showRegister = true;
    });
  }

  void _goToLogin() {
    setState(() {
      if (_showExplore) _cameFromExplore = true;
      _showExplore = false;
      _showRegister = false;
    });
  }

  void _goToExplore() {
    setState(() {
      _showExplore = true;
      _showRegister = false;
      _cameFromExplore = false;
    });
  }

  /// A design tapped in Explore: remember it, then ask to sign up.
  void _onExploreDesignTap(int? eventTypeId, int? templateId) {
    _intents.set(PendingWizardIntent(
      eventTypeId: eventTypeId,
      templateId: templateId,
    ));
    _goToRegister();
  }

  void _onAuthSuccess() {
    context.read<HomeCubit>().loadHomeData();
    context.read<EventsListCubit>().loadEvents();
  }

  /// After sign-in, continue into the wizard with what was picked in
  /// Explore (consumed once).
  void _continuePendingIntent() {
    final intent = _intents.consume();
    if (intent == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final open = widget.onOpenWizard ?? _openWizard;
      open(context, intent);
    });
  }

  static void _openWizard(BuildContext context, PendingWizardIntent intent) {
    final nav = Navigator.of(context);
    nav.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<InvitationCubit>(),
          child: InvitationWizardScreen(
            initialEventTypeId: intent.eventTypeId,
            initialTemplateId: intent.templateId,
            onComplete: () => nav.pop(),
          ),
        ),
      ),
    ).then((_) {
      if (context.mounted) refreshEventLists(context);
    });
  }

  /// Wraps login / register so Android back returns to Explore when the
  /// user came from there (instead of closing the app).
  Widget _backToExplore(Widget child) {
    if (!_cameFromExplore) return child;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToExplore();
      },
      child: child,
    );
  }

  void _showUnverifiedAccountDialog(String phone) {
    // Send OTP automatically for verification
    context.read<AuthCubit>().resendOtp(
          login: phone,
          purpose: 'registration',
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: _UnverifiedAccountOtpDialog(
          phone: phone,
          onVerified: () {
            Navigator.of(context).pop();
            _onAuthSuccess();
          },
          onCancel: () {
            Navigator.of(context).pop();
            context.read<AuthCubit>().resetState();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onFinished: _onSplashFinished);
    }

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // When user logs out or deletes account, pop all pushed routes
        if (state is AuthUnauthenticated || state is AuthAccountDeleted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          setState(() => _showRegister = false);
          if (state is AuthAccountDeleted) _intents.clear();
        }
        // Handle unverified account - show OTP dialog
        if (state is AuthUnverified) {
          _showUnverifiedAccountDialog(state.phone);
        }
        // Handle successful authentication
        if (state is AuthAuthenticated) {
          setState(() {
            _showRegister = false;
            _cameFromExplore = false;
          });
          _onAuthSuccess();
          if (!state.user.needsInstitutionApproval) _continuePendingIntent();
        }
      },
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: MkSpinner(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            ),
          );
        }

        // Temporary password from the team: choose your own first. While the
        // change is in flight the cubit leaves AuthAuthenticated (loading /
        // changed / error), so the same screen stays until the refreshed
        // profile comes back without the flag.
        if (state is AuthAuthenticated && state.user.mustChangePassword) {
          _forcedPasswordPhone = state.user.phone ?? '';
        } else if (state is AuthAuthenticated || state is AuthUnauthenticated) {
          _forcedPasswordPhone = null;
        }
        if (_forcedPasswordPhone != null) {
          return PopScope(
            canPop: false,
            child: ChangePasswordScreen(phone: _forcedPasswordPhone!, forced: true),
          );
        }

        // New Terms / Privacy version from the team: accept it first.
        if (state is AuthAuthenticated) {
          _mustAcceptTerms = state.user.mustAcceptTerms;
        } else if (state is AuthUnauthenticated) {
          _mustAcceptTerms = false;
        }
        if (_mustAcceptTerms) {
          return const PopScope(canPop: false, child: TermsAcceptanceScreen());
        }

        if (state is AuthAuthenticated) {
          // Institution not approved yet (pending / rejected): waiting screen
          // until GET /auth/profile reports approved.
          if (state.user.needsInstitutionApproval) {
            return const AdminApprovalWaitingScreen();
          }
          return const MainShell();
        }

        if (_showExplore) {
          return ExploreScreen(
            onStartTap: () {
              // A plain "start" drops any earlier design pick.
              _intents.clear();
              _goToRegister();
            },
            onLoginTap: _goToLogin,
            onDesignTap: _onExploreDesignTap,
          );
        }

        if (_showRegister) {
          return _backToExplore(RegisterScreen(
            onLoginTap: _goToLogin,
            onRegisterSuccess: _onAuthSuccess,
          ));
        }

        return _backToExplore(LoginScreen(
          onRegisterTap: _goToRegister,
          onLoginSuccess: _onAuthSuccess,
          onBrowseTap: _goToExplore,
        ));
      },
    );
  }
}

/// OTP verification dialog for unverified accounts attempting to login.
class _UnverifiedAccountOtpDialog extends StatefulWidget {
  final String phone;
  final VoidCallback onVerified;
  final VoidCallback onCancel;

  const _UnverifiedAccountOtpDialog({
    required this.phone,
    required this.onVerified,
    required this.onCancel,
  });

  @override
  State<_UnverifiedAccountOtpDialog> createState() =>
      _UnverifiedAccountOtpDialogState();
}

class _UnverifiedAccountOtpDialogState
    extends State<_UnverifiedAccountOtpDialog> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _verifyOtp() {
    if (_pinController.text.length == 6) {
      context.read<AuthCubit>().verifyOtp(
            login: widget.phone,
            otp: _pinController.text,
            loginAfterVerify: true,
          );
    }
  }

  void _resendOtp() {
    if (_canResend) {
      context.read<AuthCubit>().resendOtp(
            login: widget.phone,
            purpose: 'registration',
          );
      _startResendTimer();
      _pinController.clear();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          widget.onVerified();
        } else if (state is AuthOtpSent) {
          AppSnackBar.showSuccess(
            context,
            message: t.translate('auth_new_code_sent'),
          );
        } else if (state is AuthError) {
          AppSnackBar.showError(context, message: state.message);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.06)),
        child: Padding(
          padding: EdgeInsets.all(context.dynamicWidth(0.06)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.amber100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 32,
                  color: AppColors.amber600,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.02)),

              // Title
              Text(
                t.translate('auth_account_not_verified'),
                style: AppTextStyles.titleLarge.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.dynamicHeight(0.01)),

              // Subtitle
              Text(
                t.translate('auth_verify_to_continue'),
                style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.dynamicHeight(0.01)),

              // Phone number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    widget.phone,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.025)),

              // Pinput
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  focusNode: _focusNode,
                  defaultPinTheme: PinTheme(
                    width: 44,
                    height: 52,
                    textStyle: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    decoration: BoxDecoration(
                      color: context.themeSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.borderColor, width: 1.5),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 44,
                    height: 52,
                    textStyle: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    decoration: BoxDecoration(
                      color: context.themeSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 44,
                    height: 52,
                    textStyle: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryColor, width: 1.5),
                    ),
                  ),
                  showCursor: true,
                  keyboardType: TextInputType.number,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  closeKeyboardWhenCompleted: true,
                  onCompleted: (_) => _verifyOtp(),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.025)),

              // Verify button
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  final canVerify = _pinController.text.length == 6 && !isLoading;
                  return SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: t.translate('auth_verify'),
                      onPressed: canVerify ? _verifyOtp : null,
                      isLoading: isLoading,
                      isDisabled: !canVerify,
                    ),
                  );
                },
              ),
              SizedBox(height: context.dynamicHeight(0.01)),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: widget.onCancel,
                  child: Text(
                    t.translate('common_cancel'),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.01)),

              // Resend section
              if (_canResend)
                AppTextButton(
                  text: t.translate('auth_resend_code'),
                  onPressed: _resendOtp,
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: context.iconDefault),
                    const SizedBox(width: 4),
                    Text(
                      isArabic
                          ? 'إعادة الإرسال بعد $_resendSeconds ثانية'
                          : 'Resend in $_resendSeconds seconds',
                      style: AppTextStyles.caption.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
