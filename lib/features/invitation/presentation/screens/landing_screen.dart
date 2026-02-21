import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';

/// Landing screen - Zero Fear Entry point
/// "Invite people in a way that matches your special occasion"
class LandingScreen extends StatefulWidget {
  final VoidCallback? onGetStarted;
  final VoidCallback? onLogin;

  const LandingScreen({
    super.key,
    this.onGetStarted,
    this.onLogin,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.tertiaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
            child: Column(
              children: [
                // Top spacer
                SizedBox(height: context.dynamicHeight(0.08)),

                // Logo/Brand area
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: context.dynamicWidth(0.251),
                    height: context.dynamicWidth(0.251),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.061)),
                    ),
                    child: Center(
                      child: Text(
                        '📨',
                        style: TextStyle(fontSize: context.dynamicWidth(0.12)),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.dynamicHeight(0.039)),

                // Main heading
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Invite people in a way that\nmatches your special occasion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.064),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.dynamicHeight(0.02)),

                // Subtitle
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'One link – QR code – Full organization',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.04),
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                // Flexible spacer
                const Spacer(),

                // Feature highlights
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFeatureHighlights(context),
                  ),
                ),

                SizedBox(height: context.dynamicHeight(0.039)),

                // Primary CTA
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Create Your Invitation',
                        onPressed: _onGetStarted,
                        gradientColors: const [Colors.white, Colors.white],
                        textStyle: TextStyle(
                          fontSize: context.dynamicWidth(0.04),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.dynamicHeight(0.02)),

                // Secondary option - Login
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: TextButton(
                    onPressed: widget.onLogin,
                    child: Text(
                      'Already have an account? Sign in',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: context.dynamicWidth(0.035),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.dynamicHeight(0.039)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(BuildContext context) {
    final features = [
      {'icon': '🎨', 'text': 'Beautiful templates'},
      {'icon': '📊', 'text': 'Track responses'},
      {'icon': '📱', 'text': 'QR code entry'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features.map((feature) {
        return Column(
          children: [
            Container(
              width: context.dynamicWidth(0.141),
              height: context.dynamicWidth(0.141),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
              ),
              child: Center(
                child: Text(
                  feature['icon']!,
                  style: TextStyle(fontSize: context.dynamicWidth(0.061)),
                ),
              ),
            ),
            SizedBox(height: context.dynamicWidth(0.021)),
            Text(
              feature['text']!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: context.dynamicWidth(0.029),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _onGetStarted() {
    // Navigate to event type selection
    context.read<InvitationCubit>().goToStep(InvitationStep.eventTypeSelection);
    widget.onGetStarted?.call();
  }
}
