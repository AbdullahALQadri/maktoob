import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
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
                        horizontal: context.dynamicWidth(0.06),
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: context.dynamicHeight(0.06)),
                              _buildLogo(),
                              SizedBox(height: context.dynamicHeight(0.03)),
                              _buildWelcomeText(),
                              SizedBox(height: context.dynamicHeight(0.04)),
                              _buildFormCard(),
                              SizedBox(height: context.dynamicHeight(0.025)),
                              _buildRegisterLink(),
                              SizedBox(height: context.dynamicHeight(0.04)),
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
          top: -context.dynamicWidth(0.35),
          right: -context.dynamicWidth(0.25),
          child: Container(
            width: context.dynamicWidth(0.8),
            height: context.dynamicWidth(0.8),
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
          bottom: -context.dynamicWidth(0.2),
          left: -context.dynamicWidth(0.3),
          child: Container(
            width: context.dynamicWidth(0.6),
            height: context.dynamicWidth(0.6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Small accent circles
        Positioned(
          top: context.dynamicHeight(0.15),
          left: context.dynamicWidth(0.1),
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
          top: context.dynamicHeight(0.25),
          right: context.dynamicWidth(0.15),
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
        width: context.dynamicWidth(0.26),
        height: context.dynamicWidth(0.26),
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
            padding: EdgeInsets.all(context.dynamicWidth(0.035)),
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
    return Column(
      children: [
        Text(
          _isArabic ? 'مرحباً بعودتك' : 'Welcome Back',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.07),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: _isArabic ? 0 : 0.5,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.008)),
        Text(
          _isArabic
              ? 'سجّل دخولك للمتابعة إلى مكتوب'
              : 'Sign in to continue to Maktoob',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.038),
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
          padding: EdgeInsets.all(context.dynamicWidth(0.06)),
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
                _buildModernTextField(
                  controller: _loginController,
                  label: _isArabic ? 'رقم الهاتف أو البريد' : 'Phone or Email',
                  hint: _isArabic
                      ? 'أدخل رقم هاتفك أو بريدك'
                      : 'Enter your phone or email',
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _isArabic
                          ? 'الرجاء إدخال رقم الهاتف أو البريد'
                          : 'Please enter your phone or email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.dynamicHeight(0.02)),
                // Password Field
                _buildModernTextField(
                  controller: _passwordController,
                  label: _isArabic ? 'كلمة المرور' : 'Password',
                  hint: _isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
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
                      return _isArabic
                          ? 'الرجاء إدخال كلمة المرور'
                          : 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return _isArabic
                          ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                          : 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.dynamicHeight(0.012)),
                // Forgot Password
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen(
                            onBack: () => Navigator.pop(context),
                            onSuccess: () {
                              AppSnackBar.showSuccess(
                                context,
                                message: _isArabic
                                    ? 'تم تغيير كلمة المرور بنجاح'
                                    : 'Password changed successfully',
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
                      _isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: context.dynamicWidth(0.033),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.025)),
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
            fontSize: context.dynamicWidth(0.035),
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.008)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            color: AppColors.gray900,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: context.dynamicWidth(0.035),
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
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicHeight(0.018),
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
              fontSize: context.dynamicWidth(0.03),
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
          height: context.dynamicHeight(0.065),
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
                    _isArabic ? 'تسجيل الدخول' : 'Sign In',
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.043),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isArabic ? 'ليس لديك حساب؟ ' : "Don't have an account? ",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: context.dynamicWidth(0.037),
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
              _isArabic ? 'سجّل الآن' : 'Register',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: context.dynamicWidth(0.035),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
