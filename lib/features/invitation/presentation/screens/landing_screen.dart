import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purple600,
              AppColors.pink600,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Column(
              children: [
                // Top spacer
                SizedBox(height: screenHeight * 0.08),

                // Logo/Brand area
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    ),
                    child: Center(
                      child: Text(
                        '📨',
                        style: TextStyle(fontSize: screenWidth * 0.12),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // Main heading
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Invite people in a way that\nmatches your special occasion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Subtitle
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'One link – QR code – Full organization',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white.withOpacity(0.85),
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
                    child: _buildFeatureHighlights(screenWidth),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

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
                        textColor: AppColors.purple600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Secondary option - Login
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: TextButton(
                    onPressed: widget.onLogin,
                    child: Text(
                      'Already have an account? Sign in',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(double screenWidth) {
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
              width: screenWidth * 0.14,
              height: screenWidth * 0.14,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(screenWidth * 0.035),
              ),
              child: Center(
                child: Text(
                  feature['icon']!,
                  style: TextStyle(fontSize: screenWidth * 0.06),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              feature['text']!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: screenWidth * 0.03,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _onGetStarted() {
    // Navigate to event type selection
    context.read<InvitationCubit>().goToStep(InvitationStep.eventType);
    widget.onGetStarted?.call();
  }
}
