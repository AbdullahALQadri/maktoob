import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/invitation_preview_widget.dart';

/// Share Screen - Conversion moment with soft paywall
class ShareScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const ShareScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: GestureDetector(
            onTap: () {
              context.read<InvitationCubit>().previousStep();
              onBack?.call();
            },
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gray200,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.gray800,
                size: 21.w,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<InvitationCubit, InvitationState>(
        builder: (context, state) {
          return Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 23.w),
                child: Column(
                  children: [
                    Text(
                      'Your invitation is ready!',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Preview how your guests will see it',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Full invitation preview
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: InvitationPreviewWidget(
                    eventType: state.eventType,
                    names: state.names,
                    eventDate: state.eventDate,
                    eventTime: state.eventTime,
                    location: state.location,
                    templateId: state.selectedTemplateId,
                    showMarketingFooter: true,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Guest count summary
              if (state.totalGuests > 0)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 23.w),
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: AppColors.purple50,
                    borderRadius: BorderRadius.circular(11.w),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: AppColors.primaryColor,
                        size: 23.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${state.totalGuests} guests will receive this invitation',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16.h),

              // Bottom button with BackdropFilter
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.gray200.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: 'Share Invitation',
                          onPressed: () => _showPackageModal(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPackageModal(BuildContext context) {
    AppBottomSheet.show(
      context,
      title: 'Choose How You Want to\nManage Your Event',
      subtitle: 'Select the level of organization that fits your event',
      icon: Icons.celebration_rounded,
      iconColor: AppColors.primaryColor,
      iconBackgroundColor: AppColors.purple50,
      showCloseButton: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16.h),

          // Features preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureIcon(
                context,
                icon: Icons.qr_code,
                label: 'QR Entry',
              ),
              _buildFeatureIcon(
                context,
                icon: Icons.analytics_outlined,
                label: 'Reports',
              ),
              _buildFeatureIcon(
                context,
                icon: Icons.support_agent,
                label: 'Support',
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // CTA button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: 'See Options',
              onPressed: () {
                Navigator.pop(context);
                context.read<InvitationCubit>().nextStep();
                onContinue?.call();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(BuildContext context,
      {required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          width: 53.w,
          height: 53.w,
          decoration: BoxDecoration(
            color: AppColors.purple50,
            borderRadius: BorderRadius.circular(13.w),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 26.w,
          ),
        ),
        SizedBox(height: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }
}
