import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onRegisterTap;
  final VoidCallback? onLoginSuccess;

  const LoginScreen({
    super.key,
    this.onRegisterTap,
    this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            login: _loginController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  bool get _isArabic {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          widget.onLoginSuccess?.call();
        } else if (state is AuthError) {
          AppSnackBar.showError(context, message: state.message);
        }
      },
      child: Scaffold(
        body: Container(
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
              // Decorative Pattern
              _buildDecorativePattern(),
              // Main Content
              SafeArea(
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
                        horizontal: 23.w,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 49.h),
                              _buildLogo(),
                              SizedBox(height: 24.h),
                              _buildWelcomeText(),
                              SizedBox(height: 32.h),
                              _buildFormCard(),
                              SizedBox(height: 20.h),
                              _buildRegisterLink(),
                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativePattern() {
    return Stack(
      children: [
        // Top right decorative circle
        Positioned(
          top: -131.w,
          right: -94.w,
          child: Container(
            width: 300.w,
            height: 300.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
          ),
        ),
        // Bottom left decorative circle
        Positioned(
          bottom: -75.w,
          left: -113.w,
          child: Container(
            width: 225.w,
            height: 225.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Small accent circles
        Positioned(
          top: 122.h,
          left: 38.w,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
        Positioned(
          top: 203.h,
          right: 56.w,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: 98.w,
        height: 98.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 25,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(13.w),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          t.translate('auth_welcome_back'),
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: _isArabic ? 0 : 0.5,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          t.translate('auth_sign_in_subtitle'),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: _isArabic ? 0 : 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(23.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phone/Email Field
                Builder(builder: (context) {
                  final t = AppLocalizations.of(context)!;
                  return _buildModernTextField(
                    controller: _loginController,
                    label: t.translate('auth_phone_or_email'),
                    hint: t.translate('auth_phone_or_email_hint'),
                    prefixIcon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.translate('auth_phone_or_email_required');
                      }
                      return null;
                    },
                  );
                }),
                SizedBox(height: 16.h),
                // Password Field
                Builder(builder: (context) {
                  final t = AppLocalizations.of(context)!;
                  return _buildModernTextField(
                    controller: _passwordController,
                    label: t.translate('auth_password'),
                    hint: t.translate('auth_password_hint'),
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.gray400,
                        size: 22,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.translate('auth_password_required');
                      }
                      if (value.length < 6) {
                        return t.translate('auth_password_min_length');
                      }
                      return null;
                    },
                  );
                }),
                SizedBox(height: 10.h),
                // Forgot Password
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () {
                      final t = AppLocalizations.of(context)!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen(
                            onBack: () => Navigator.pop(context),
                            onSuccess: () {
                              AppSnackBar.showSuccess(
                                context,
                                message: t.translate('auth_password_changed'),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('auth_forgot_password'),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Login Button
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.gray900,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsetsDirectional.only(start: 14, end: 10),
              child: Icon(
                prefixIcon,
                color: AppColors.primaryColor,
                size: 22,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 15.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.gray200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.red500, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.red500, width: 2),
            ),
            errorStyle: TextStyle(
              color: AppColors.red500,
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Container(
          height: 53.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)!.translate('auth_sign_in'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: _isArabic ? 0 : 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterLink() {
    final t = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          t.translate('auth_no_account'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 14.sp,
          ),
        ),
        GestureDetector(
          onTap: widget.onRegisterTap,
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
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
