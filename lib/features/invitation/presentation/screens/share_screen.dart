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
          padding: EdgeInsets.all(context.dynamicWidth(0.021)),
          child: GestureDetector(
            onTap: () {
              context.read<InvitationCubit>().previousStep();
              onBack?.call();
            },
            child: Container(
              width: context.dynamicWidth(0.101),
              height: context.dynamicWidth(0.101),
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
                size: context.dynamicWidth(0.056),
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
                padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
                child: Column(
                  children: [
                    Text(
                      'Your invitation is ready!',
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.064),
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.dynamicHeight(0.01)),
                    Text(
                      'Preview how your guests will see it',
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.04),
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.dynamicHeight(0.03)),

              // Full invitation preview
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.08)),
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

              SizedBox(height: context.dynamicHeight(0.03)),

              // Guest count summary
              if (state.totalGuests > 0)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
                  padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                  decoration: BoxDecoration(
                    color: AppColors.purple50,
                    borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: AppColors.primaryColor,
                        size: context.dynamicWidth(0.061),
                      ),
                      SizedBox(width: context.dynamicWidth(0.021)),
                      Text(
                        '${state.totalGuests} guests will receive this invitation',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: context.dynamicWidth(0.037),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: context.dynamicHeight(0.02)),

              // Bottom button with BackdropFilter
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.all(context.dynamicWidth(0.04)),
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
          SizedBox(height: context.dynamicHeight(0.02)),

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

          SizedBox(height: context.dynamicHeight(0.03)),

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
          width: context.dynamicWidth(0.141),
          height: context.dynamicWidth(0.141),
          decoration: BoxDecoration(
            color: AppColors.purple50,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: context.dynamicWidth(0.069),
          ),
        ),
        SizedBox(height: context.dynamicWidth(0.021)),
        Text(
          label,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.032),
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }
}
