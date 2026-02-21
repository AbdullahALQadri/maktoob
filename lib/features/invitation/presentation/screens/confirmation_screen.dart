import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/marketing_footer_widget.dart';

/// Confirmation Screen with QR code and share options
class ConfirmationScreen extends StatefulWidget {
  final VoidCallback? onGoToDashboard;
  final VoidCallback? onCreateAnother;

  const ConfirmationScreen({
    super.key,
    this.onGoToDashboard,
    this.onCreateAnother,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Generate share link when screen loads
    // ignore: deprecated_member_use_from_same_package
    context.read<InvitationCubit>().generateShareLink();

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
      backgroundColor: Colors.white,
      body: BlocBuilder<InvitationCubit, InvitationState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
              child: Column(
                children: [
                  SizedBox(height: context.dynamicHeight(0.05)),

                  // Success animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: context.dynamicWidth(0.251),
                      height: context.dynamicWidth(0.251),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.green600, AppColors.emerald500],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green600.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: context.dynamicWidth(0.12),
                      ),
                    ),
                  ),

                  SizedBox(height: context.dynamicHeight(0.03)),

                  // Success message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Your invitation is live!',
                          style: TextStyle(
                            fontSize: context.dynamicWidth(0.064),
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: context.dynamicHeight(0.01)),
                        Text(
                          'Share it with your guests',
                          style: TextStyle(
                            fontSize: context.dynamicWidth(0.04),
                            color: context.iconSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.dynamicHeight(0.039)),

                  // QR Code
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: state.shareLink ?? 'https://maktoob.app',
                            version: QrVersions.auto,
                            size: context.dynamicWidth(0.451),
                            backgroundColor: Colors.white,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.primaryColor,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: context.textPrimary,
                            ),
                          ),
                          SizedBox(height: context.dynamicWidth(0.029)),
                          Text(
                            'Scan to view invitation',
                            style: TextStyle(
                              color: context.iconSecondary,
                              fontSize: context.dynamicWidth(0.035),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: context.dynamicHeight(0.03)),

                  // Share link
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildShareLinkCard(context, state),
                  ),

                  SizedBox(height: context.dynamicHeight(0.025)),

                  // Share buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildShareButtons(context, state),
                  ),

                  SizedBox(height: context.dynamicHeight(0.03)),

                  // Marketing footer (only for free plan)
                  if (state.selectedPackage?.price == 0)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const MarketingFooterWidget(),
                    ),

                  SizedBox(height: context.dynamicHeight(0.03)),

                  // Action buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: 'Go to Dashboard',
                            onPressed: widget.onGoToDashboard,
                          ),
                        ),
                        SizedBox(height: context.dynamicHeight(0.015)),
                        TextButton(
                          onPressed: () {
                            context.read<InvitationCubit>().reset();
                            widget.onCreateAnother?.call();
                          },
                          child: Text(
                            'Create Another Invitation',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: context.dynamicWidth(0.037),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.dynamicHeight(0.039)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShareLinkCard(BuildContext context, InvitationState state) {
    final link = state.shareLink ?? 'Generating link...';

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: context.themeSurface,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invitation Link',
                  style: TextStyle(
                    color: context.iconSecondary,
                    fontSize: context.dynamicWidth(0.032),
                  ),
                ),
                SizedBox(height: context.dynamicWidth(0.011)),
                Text(
                  link,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: context.dynamicWidth(0.035),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copyLink(link),
            icon: Icon(
              Icons.copy,
              color: AppColors.primaryColor,
              size: context.dynamicWidth(0.061),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButtons(BuildContext context, InvitationState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildShareButton(
          context,
          icon: Icons.message,
          label: 'WhatsApp',
          color: const Color(0xFF25D366),
          onTap: () => _shareViaWhatsApp(state),
        ),
        _buildShareButton(
          context,
          icon: Icons.copy,
          label: 'Copy Link',
          color: AppColors.primaryColor,
          onTap: () => _copyLink(state.shareLink ?? ''),
        ),
        _buildShareButton(
          context,
          icon: Icons.share,
          label: 'More',
          color: context.textSecondary,
          onTap: () => _shareGeneric(state),
        ),
      ],
    );
  }

  Widget _buildShareButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: context.dynamicWidth(0.149),
            height: context.dynamicWidth(0.149),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
            ),
            child: Icon(
              icon,
              color: color,
              size: context.dynamicWidth(0.069),
            ),
          ),
          SizedBox(height: context.dynamicWidth(0.021)),
          Text(
            label,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: context.dynamicWidth(0.032),
            ),
          ),
        ],
      ),
    );
  }

  void _copyLink(String link) {
    Clipboard.setData(ClipboardData(text: link));
    AppSnackBar.showSuccess(
      context,
      message: 'Link copied to clipboard!',
      duration: const Duration(seconds: 2),
    );
  }

  void _shareViaWhatsApp(InvitationState state) async {
    final link = state.shareLink ?? '';
    final eventName = state.eventName ?? 'My Event';
    final message = 'You\'re invited to $eventName! View invitation: $link';

    try {
      await Share.share(message);
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          message: 'Could not share',
        );
      }
    }
  }

  void _shareGeneric(InvitationState state) async {
    final link = state.shareLink ?? '';
    final eventName = state.eventName ?? 'My Event';
    final message = 'You\'re invited to $eventName! View invitation: $link';

    try {
      await Share.share(message);
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          message: 'Could not share',
        );
      }
    }
  }
}
