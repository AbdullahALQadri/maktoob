import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

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

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          widget.onLoginSuccess?.call();
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red500,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + context.dynamicHeight(0.04),
        bottom: context.dynamicHeight(0.04),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple600, AppColors.pink600],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // App Logo/Icon
          Container(
            width: context.dynamicWidth(0.2),
            height: context.dynamicWidth(0.2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration,
              color: Colors.white,
              size: context.dynamicWidth(0.1),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          Text(
            'Maktoob',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.08),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.045),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.06)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: context.dynamicHeight(0.02)),
            // Login Field (Email/Phone)
            _buildTextField(
              controller: _loginController,
              label: 'Email or Phone',
              hint: 'Enter your email or phone number',
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email or phone';
                }
                return null;
              },
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            // Password Field
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.gray500,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.purple600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            // Login Button
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: 'Login',
                  onPressed: _handleLogin,
                  isLoading: state is AuthLoading,
                );
              },
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            // Register Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    color: AppColors.gray600,
                    fontSize: context.dynamicWidth(0.035),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onRegisterTap,
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: AppColors.purple600,
                      fontWeight: FontWeight.w600,
                      fontSize: context.dynamicWidth(0.035),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
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
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            color: AppColors.gray900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: context.dynamicWidth(0.035),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColors.gray500,
              size: context.dynamicWidth(0.055),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicHeight(0.02),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.purple600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red500),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red500, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
