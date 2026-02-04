import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/screens/main_shell.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../screens/login_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../../domain/entities/user_entity.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;
  bool _showRegister = false;
  // Track unverified state to show OTP screen
  String? _unverifiedPhone;
  UserType? _unverifiedUserType;

  void _onSplashFinished() {
    if (!mounted) return;
    setState(() => _showSplash = false);
  }

  void _goToRegister() {
    setState(() => _showRegister = true);
  }

  void _goToLogin() {
    setState(() {
      _showRegister = false;
      _unverifiedPhone = null;
      _unverifiedUserType = null;
    });
  }

  void _onAuthSuccess() {
    context.read<HomeCubit>().loadHomeData();
    context.read<EventsListCubit>().loadEvents();
  }

  void _onOtpVerified() {
    setState(() {
      _unverifiedPhone = null;
      _unverifiedUserType = null;
    });
    _onAuthSuccess();
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
          setState(() {
            _showRegister = false;
            _unverifiedPhone = null;
            _unverifiedUserType = null;
          });
        }
        // Handle unverified account - send OTP automatically
        if (state is AuthUnverified) {
          setState(() {
            _unverifiedPhone = state.phone;
            _unverifiedUserType = state.user.userType;
          });
          // Send OTP automatically for verification
          context.read<AuthCubit>().resendOtp(
                login: state.phone,
                purpose: 'verification',
              );
        }
        // Handle successful authentication (from login, register+OTP, or unverified account OTP)
        if (state is AuthAuthenticated) {
          // Reset registration state and clear any pending OTP verification
          setState(() {
            _showRegister = false;
            _unverifiedPhone = null;
            _unverifiedUserType = null;
          });
          _onAuthSuccess();
        }
        // Handle OTP verified without auto-login
        if (state is AuthOtpVerified) {
          setState(() {
            _unverifiedPhone = null;
            _unverifiedUserType = null;
          });
        }
      },
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return const MainShell();
        }

        // Show OTP verification screen for unverified accounts
        if (_unverifiedPhone != null) {
          return OtpVerificationScreen(
            phone: _unverifiedPhone!,
            userType: _unverifiedUserType ?? UserType.user,
            onVerified: _onOtpVerified,
            onBack: _goToLogin,
            loginAfterVerify: true,
          );
        }

        if (_showRegister) {
          return RegisterScreen(
            onLoginTap: _goToLogin,
            onRegisterSuccess: _onAuthSuccess,
          );
        }

        return LoginScreen(
          onRegisterTap: _goToRegister,
          onLoginSuccess: _onAuthSuccess,
        );
      },
    );
  }
}
