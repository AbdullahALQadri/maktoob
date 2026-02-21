import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
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
    final screenHeight = context.height;
    final screenWidth = context.width;
    final packages = GoldenPackageModel.packages;

    return Scaffold(
      backgroundColor: context.themeSurface,
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
                color: context.overlayBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.borderColor,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: context.textPrimary,
                size: 22,
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
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  children: [
                    Text(
                      'Choose Your Plan',
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Select the level of organization for your event',
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                        color: context.iconSecondary,
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
                        isSelected: state.selectedPackage?.id.toString() == package.id,
                        onTap: () {
                          context
                              .read<InvitationCubit>()
                              // ignore: deprecated_member_use_from_same_package
                              .selectPackageById(package.id);
                        },
                      ),
                    );
                  },
                ),
              ),

              // Bottom button with BackdropFilter
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              text: state.selectedPackage?.price == 0
                                  ? 'Continue with Free Plan'
                                  : 'Continue',
                              onPressed: state.canProceedFromPackage
                                  ? () {
                                      if (state.selectedPackage?.price == 0) {
                                        // Skip payment, go directly to confirmation
                                        context
                                            .read<InvitationCubit>()
                                            .goToStep(InvitationStep.invoiceSummary);
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
