import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../data/models/golden_package_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';

/// WhatsApp Payment Screen - Gaza-style human payment process
class WhatsAppPaymentScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const WhatsAppPaymentScreen({
    super.key,
    this.onBack,
    this.onComplete,
    this.onSkip,
  });

  static const String _whatsappNumber = '972599000000'; // Replace with actual number

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              context.read<InvitationCubit>().previousStep();
              onBack?.call();
            },
            child: Container(
              width: 40,
              height: 40,
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
                size: 22,
              ),
            ),
          ),
        ),
        title: Text(
          'Complete Payment',
          style: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<InvitationCubit, InvitationState>(
        builder: (context, state) {
          final selectedPackage = GoldenPackageModel.getById(
            state.selectedPackageId ?? '',
          );

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),

                // Selected package summary
                if (selectedPackage != null)
                  _buildSelectedPackageCard(selectedPackage, screenWidth),

                SizedBox(height: screenHeight * 0.03),

                // Payment instructions
                Text(
                  'One last step to activate your invitation',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Contact us on WhatsApp to complete your payment',
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    color: AppColors.gray500,
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // WhatsApp button
                _buildWhatsAppButton(context, state, screenWidth),

                SizedBox(height: screenHeight * 0.03),

                // Bank details
                _buildBankDetailsCard(screenWidth),

                SizedBox(height: screenHeight * 0.03),

                // Upload receipt section
                _buildUploadSection(screenWidth),

                SizedBox(height: screenHeight * 0.04),

                // How it works
                _buildHowItWorks(screenWidth),

                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context, screenWidth),
    );
  }

  Widget _buildSelectedPackageCard(
      GoldenPackageModel package, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: package.gradientColors,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: Row(
        children: [
          Text(
            package.emoji,
            style: TextStyle(fontSize: screenWidth * 0.1),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
                Text(
                  package.nameAr,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: screenWidth * 0.032,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${package.price} ILS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.055,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppButton(
      BuildContext context, InvitationState state, double screenWidth) {
    return GestureDetector(
      onTap: () => _openWhatsApp(context, state),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.045),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366), // WhatsApp green
          borderRadius: BorderRadius.circular(screenWidth * 0.035),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25D366).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // WhatsApp icon
            Container(
              width: screenWidth * 0.1,
              height: screenWidth * 0.1,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
              ),
              child: Center(
                child: Text(
                  '📱',
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact us on WhatsApp',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.042,
                  ),
                ),
                Text(
                  'We\'ll guide you through the payment',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: screenWidth * 0.032,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: screenWidth * 0.05,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailsCard(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: AppColors.primaryColor,
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Bank Transfer Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.042,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          _buildBankDetailRow('Bank', 'Bank of Palestine', screenWidth),
          _buildBankDetailRow('Account Name', 'Maktoob Events', screenWidth),
          _buildBankDetailRow('Account Number', '1234567890', screenWidth),
          _buildBankDetailRow('IBAN', 'PS12 BALA 0000 0012 3456 7890', screenWidth),
        ],
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: screenWidth * 0.035,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.gray800,
              fontWeight: FontWeight.w500,
              fontSize: screenWidth * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        border: Border.all(color: AppColors.blue50),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            color: AppColors.primaryColor,
            size: screenWidth * 0.12,
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            'Upload Payment Receipt',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: screenWidth * 0.04,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            'After bank transfer, upload your receipt here',
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenWidth * 0.03),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement file picker
            },
            icon: const Icon(Icons.attach_file),
            label: const Text('Choose File'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: BorderSide(color: AppColors.primaryColor),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenWidth * 0.025,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(double screenWidth) {
    final steps = [
      {'num': '1', 'text': 'Contact us on WhatsApp'},
      {'num': '2', 'text': 'We\'ll send you the invoice'},
      {'num': '3', 'text': 'Transfer the amount'},
      {'num': '4', 'text': 'Upload receipt & we activate your invitation'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How it works',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.042,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        ...steps.map((step) => Padding(
              padding: EdgeInsets.only(bottom: screenWidth * 0.02),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.07,
                    height: screenWidth * 0.07,
                    decoration: BoxDecoration(
                      color: AppColors.blue50,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        step['num']!,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    step['text']!,
                    style: TextStyle(
                      color: AppColors.gray700,
                      fontSize: screenWidth * 0.038,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, double screenWidth) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(
              top: BorderSide(
                color: AppColors.gray200.withOpacity(0.5),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'I\'ve Completed Payment',
                    onPressed: () {
                      context.read<InvitationCubit>().submitInvitation();
                      onComplete?.call();
                    },
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                TextButton(
                  onPressed: () {
                    context.read<InvitationCubit>().saveDraft();
                    onSkip?.call();
                  },
                  child: Text(
                    'I\'ll pay later (save as draft)',
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context, InvitationState state) async {
    final cubit = context.read<InvitationCubit>();
    final url = cubit.getWhatsAppUrl(_whatsappNumber);

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }
}
