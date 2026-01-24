import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/wizard_step_header.dart';

class Page6PackageSelectionScreen extends StatefulWidget {
  const Page6PackageSelectionScreen({super.key});

  @override
  State<Page6PackageSelectionScreen> createState() =>
      _Page6PackageSelectionScreenState();
}

class _Page6PackageSelectionScreenState
    extends State<Page6PackageSelectionScreen> {
  final TextEditingController _customLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load packages when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationCubit>().loadPackages();
    });
  }

  @override
  void dispose() {
    _customLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return BlocConsumer<InvitationCubit, InvitationState>(
      listener: (context, state) {
        // Show validation error if needed
        if (state.packageValidationError) {
          _showValidationWarning(context, state, l);
        }

        // Update custom limit controller if needed
        if (state.customPackageLimit != null &&
            _customLimitController.text !=
                state.customPackageLimit.toString()) {
          _customLimitController.text = state.customPackageLimit.toString();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Step Header
                WizardStepHeader(
                  currentStep: 6,
                  totalSteps: 7,
                  title: l?.translate('invitation_step6_title') ?? 'Package Selection',
                ),

                // Guest Count Info
                _buildGuestCountInfo(state, l),

                // Content
                Expanded(
                  child: _buildContent(context, state, l, isEnglish),
                ),

                // Navigation Buttons
                _buildNavigationButtons(context, state, l),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestCountInfo(InvitationState state, AppLocalizations? l) {
    final guestCount = state.allGuests.length;
    final packageLimit = state.selectedPackage?.invitationLimit ?? 0;
    final isOverLimit =
        state.selectedPackage != null && guestCount > packageLimit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isOverLimit ? Colors.red.shade100 : AppColors.primary,
      child: Row(
        children: [
          Icon(
            isOverLimit ? Icons.warning : Icons.people,
            color: isOverLimit ? Colors.red.shade700 : Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l?.translate('invitation_guest_count') ?? 'Guest count'}: $guestCount',
                  style: TextStyle(
                    color: isOverLimit ? Colors.red.shade900 : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.selectedPackage != null)
                  Text(
                    '${l?.translate('invitation_package_limit') ?? 'Package limit'}: $packageLimit ${l?.translate('invitation_invitations') ?? 'invitations'}',
                    style: TextStyle(
                      color: isOverLimit
                          ? Colors.red.shade700
                          : Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (isOverLimit)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l?.translate('invitation_limit_exceeded') ?? 'Limit exceeded!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, InvitationState state, AppLocalizations? l, bool isEnglish) {
    if (state.isLoadingPackages) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l?.translate('invitation_loading_packages') ?? 'Loading packages...',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (state.packagesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                l?.translate('invitation_packages_error') ?? 'Error loading packages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.packagesError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: l?.translate('common_retry') ?? 'Retry',
                onPressed: () {
                  context.read<InvitationCubit>().loadPackages();
                },
                width: 200,
              ),
            ],
          ),
        ),
      );
    }

    if (state.availablePackages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                l?.translate('invitation_no_packages') ?? 'No packages available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info text
          Text(
            l?.translate('invitation_select_package') ?? 'Select the appropriate package for your guest count',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Packages List
          ...state.availablePackages.map((package) {
            final isSelected = state.selectedPackage?.id == package.id;
            final isCustom = package.isCustom;
            return _buildPackageCard(
              context,
              state,
              package,
              isSelected,
              isCustom,
              l,
              isEnglish,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    InvitationState state,
    PackageModel package,
    bool isSelected,
    bool isCustom,
    AppLocalizations? l,
    bool isEnglish,
  ) {
    final guestCount = state.allGuests.length;
    final isOverLimit =
        !isCustom && package.invitationLimit != null && guestCount > package.invitationLimit!;

    return GestureDetector(
      onTap: () {
        context.read<InvitationCubit>().selectPackage(package);
        if (isCustom) {
          // Set minimum custom limit to current guest count
          _customLimitController.text = guestCount.toString();
          context
              .read<InvitationCubit>()
              .setCustomPackageLimit(guestCount);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isOverLimit
                    ? Colors.red.shade300
                    : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Selection indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Package Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isEnglish ? package.name : package.nameAr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade800,
                            ),
                          ),
                          if (isCustom) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l?.translate('invitation_custom') ?? 'Custom',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.purple.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (package.name != package.nameAr)
                        Text(
                          isEnglish ? package.nameAr : package.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),

                // Price
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isCustom && state.customPackagePrice != null
                            ? '${state.customPackagePrice!.toStringAsFixed(0)} ₪'
                            : '${package.price.toStringAsFixed(0)} ₪',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      if (state.isLoadingCustomPrice && isCustom && isSelected)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Features
            if (package.features.isNotEmpty) ...[
              ...package.features.map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
            ],

            // Invitation Limit
            if (!isCustom && package.invitationLimit != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOverLimit
                      ? Colors.red.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: isOverLimit
                      ? Border.all(color: Colors.red.shade300)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isOverLimit ? Icons.warning : Icons.mail_outline,
                      size: 20,
                      color: isOverLimit
                          ? Colors.red.shade700
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l?.translate('invitation_invitation_limit') ?? 'Invitation limit'}: ${package.invitationLimit}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isOverLimit
                              ? Colors.red.shade700
                              : Colors.grey.shade700,
                          fontWeight:
                              isOverLimit ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isOverLimit)
                      Text(
                        '${l?.translate('invitation_exceeded_by') ?? 'Exceeded by'} ${guestCount - package.invitationLimit!}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

            // Custom Package Limit Input
            if (isCustom && isSelected) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l?.translate('invitation_specify_invitations') ?? 'Specify the number of invitations needed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l?.translate('invitation_minimum') ?? 'Minimum'}: $guestCount (${l?.translate('invitation_current_guest_count') ?? 'current guest count'})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _customLimitController,
                      hintText: l?.translate('invitation_number_of_invitations') ?? 'Number of invitations',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        final limit = int.tryParse(value);
                        if (limit != null && limit >= guestCount) {
                          context
                              .read<InvitationCubit>()
                              .setCustomPackageLimit(limit);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showValidationWarning(BuildContext context, InvitationState state, AppLocalizations? l) {
    final guestCount = state.allGuests.length;
    final packageLimit = state.selectedPackage?.invitationLimit ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 8),
            Text(l?.translate('invitation_package_limit_exceeded_title') ?? 'Package Limit Exceeded'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l?.translate('invitation_guest_count_exceeds') ?? 'Guest count'} ($guestCount) ${l?.translate('invitation_exceeds_package_limit') ?? 'exceeds the selected package limit'} ($packageLimit).',
            ),
            const SizedBox(height: 16),
            Text(
              l?.translate('invitation_available_options') ?? 'Available options:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• ${l?.translate('invitation_option_higher_package') ?? 'Select a package with a higher limit'}'),
            Text('• ${l?.translate('invitation_option_custom_package') ?? 'Select the custom package'}'),
            Text('• ${l?.translate('invitation_option_reduce_guests') ?? 'Reduce the number of guests'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l?.translate('common_ok') ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, InvitationState state, AppLocalizations? l) {
    final canProceed = state.canProceedFromPackageSelection;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Validation message
          if (!canProceed && state.selectedPackage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l?.translate('invitation_guest_exceeds_package_message') ?? 'Guest count exceeds package limit. Please select another package or reduce guests.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              // Back Button
              Expanded(
                child: AppButton(
                  text: l?.translate('common_back') ?? 'Back',
                  onPressed: () {
                    context.read<InvitationCubit>().previousStep();
                  },
                  backgroundColor: Colors.grey.shade200,
                  textColor: Colors.black87,
                ),
              ),

              const SizedBox(width: 12),

              // Next Button
              Expanded(
                flex: 2,
                child: AppButton(
                  text: l?.translate('common_next') ?? 'Next',
                  onPressed: canProceed
                      ? () {
                          context.read<InvitationCubit>().nextStep();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
