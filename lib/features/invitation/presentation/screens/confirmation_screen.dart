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
              padding: EdgeInsets.symmetric(horizontal: 23.w),
              child: Column(
                children: [
                  SizedBox(height: 41.h),

                  // Success animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 94.w,
                      height: 94.w,
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
                        size: 45.w,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Success message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Your invitation is live!',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Share it with your guests',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // QR Code
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.w),
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
                            size: 169.w,
                            backgroundColor: Colors.white,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.primaryColor,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.gray800,
                            ),
                          ),
                          SizedBox(height: 11.w),
                          Text(
                            'Scan to view invitation',
                            style: TextStyle(
                              color: AppColors.gray500,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Share link
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildShareLinkCard(context, state),
                  ),

                  SizedBox(height: 20.h),

                  // Share buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildShareButtons(context, state),
                  ),

                  SizedBox(height: 24.h),

                  // Marketing footer (only for free plan)
                  if (state.isFreePlanSelected)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const MarketingFooterWidget(),
                    ),

                  SizedBox(height: 24.h),

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
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: () {
                            context.read<InvitationCubit>().reset();
                            widget.onCreateAnother?.call();
                          },
                          child: Text(
                            'Create Another Invitation',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
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
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(11.w),
        border: Border.all(color: AppColors.gray200),
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
                    color: AppColors.gray500,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 4.w),
                Text(
                  link,
                  style: TextStyle(
                    color: AppColors.gray800,
                    fontSize: 13.sp,
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
              size: 23.w,
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
          color: AppColors.gray600,
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
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15.w),
            ),
            child: Icon(
              icon,
              color: color,
              size: 26.w,
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.gray600,
              fontSize: 12.sp,
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
    final eventName = state.names.isNotEmpty ? state.names.first : 'My Event';
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
    final eventName = state.names.isNotEmpty ? state.names.first : 'My Event';
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
