import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/widgets.dart';

/// Login screen with modern glassmorphism design.
class LoginScreen extends StatefulWidget {
  final VoidCallback? onRegisterTap;
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onRegisterTap, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _handleAuthState,
      child: Scaffold(
        body: _AuthBackground(
          child: _AnimatedContent(
            fadeAnimation: _fadeAnimation,
            slideAnimation: _slideAnimation,
            onRegisterTap: widget.onRegisterTap,
            onLoginSuccess: widget.onLoginSuccess,
          ),
        ),
      ),
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      widget.onLoginSuccess?.call();
    } else if (state is AuthError) {
      AppSnackBar.showError(context, message: state.message);
    }
  }
}

class _AuthBackground extends StatelessWidget {
  final Widget child;

  const _AuthBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.85),
            AppColors.tertiaryColor.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Stack(
        children: [
          const AuthDecorativePattern(),
          child,
        ],
      ),
    );
  }
}

class _AnimatedContent extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onLoginSuccess;

  const _AnimatedContent({
    required this.fadeAnimation,
    required this.slideAnimation,
    this.onRegisterTap,
    this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.061),
            ),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: context.dynamicHeight(0.06)),
                    const AuthLogo(),
                    SizedBox(height: context.dynamicHeight(0.03)),
                    _WelcomeText(t: t),
                    SizedBox(height: context.dynamicHeight(0.039)),
                    LoginFormCard(onLoginSuccess: onLoginSuccess),
                    SizedBox(height: context.dynamicHeight(0.025)),
                    _RegisterLink(onTap: onRegisterTap),
                    SizedBox(height: context.dynamicHeight(0.039)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  final AppLocalizations t;

  const _WelcomeText({required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          t.translate('auth_welcome_back'),
          style: AppTextStyles.headlineXLarge.white,
        ),
        SizedBox(height: context.dynamicHeight(0.007)),
        Text(
          t.translate('auth_sign_in_subtitle'),
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _RegisterLink extends StatelessWidget {
  final VoidCallback? onTap;

  const _RegisterLink({this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          t.translate('auth_no_account'),
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              t.translate('auth_register_now'),
              style: AppTextStyles.labelMedium.primary.bold,
            ),
          ),
        ),
      ],
    );
  }
}
