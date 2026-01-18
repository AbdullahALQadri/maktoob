import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../data/models/golden_package_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/golden_package_card.dart';

/// Package Selection Screen - Smart, not greedy
class PackageSelectionScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final VoidCallback? onSelectFree;

  const PackageSelectionScreen({
    super.key,
    this.onBack,
    this.onContinue,
    this.onSelectFree,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final packages = GoldenPackageModel.packages;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.gray800),
          onPressed: () {
            context.read<InvitationCubit>().previousStep();
            onBack?.call();
          },
        ),
      ),
      body: BlocBuilder<InvitationCubit, InvitationState>(
        builder: (context, state) {
          return Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  children: [
                    Text(
                      'Choose Your Plan',
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Select the level of organization for your event',
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                        color: AppColors.gray500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Package cards
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
                      child: GoldenPackageCard(
                        package: package,
                        isSelected: state.selectedPackageId == package.id,
                        onTap: () {
                          context
                              .read<InvitationCubit>()
                              .selectPackage(package.id);
                        },
                      ),
                    );
                  },
                ),
              ),

              // Bottom button
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: state.isFreePlanSelected
                              ? 'Continue with Free Plan'
                              : 'Continue',
                          onPressed: state.canProceedFromPackage
                              ? () {
                                  if (state.isFreePlanSelected) {
                                    // Skip payment, go directly to confirmation
                                    context
                                        .read<InvitationCubit>()
                                        .skipToConfirmation();
                                    onSelectFree?.call();
                                  } else {
                                    // Go to payment
                                    context.read<InvitationCubit>().nextStep();
                                    onContinue?.call();
                                  }
                                }
                              : null,
                          isDisabled: !state.canProceedFromPackage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
