import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/screens/main_shell.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showRegister = false;

  void _goToRegister() {
    setState(() => _showRegister = true);
  }

  void _goToLogin() {
    setState(() => _showRegister = false);
  }

  void _onAuthSuccess() {
    context.read<HomeCubit>().loadHomeData();
    context.read<EventsListCubit>().loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistered) {
          _goToLogin();
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

        if (_showRegister) {
          return RegisterScreen(
            onLoginTap: _goToLogin,
            onRegisterSuccess: _goToLogin,
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
