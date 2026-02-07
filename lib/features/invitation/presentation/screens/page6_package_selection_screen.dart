import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';

/// Page 6: Package Selection Screen
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<InvitationCubit>().state;
      if (state.customPackageLimit != null && state.customPackageLimit! > 0) {
        _customLimitController.text = state.customPackageLimit.toString();
      }
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
      listenWhen: (previous, current) =>
          previous.customPackageLimit != current.customPackageLimit,
      listener: (context, state) {
        if (state.customPackageLimit != null &&
            _customLimitController.text != state.customPackageLimit.toString()) {
          _customLimitController.text = state.customPackageLimit.toString();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                WizardStepHeader(
                  currentStep: 6,
                  totalSteps: 7,
                  title: l?.translate('invitation_step6_title') ??
                      'Package Selection',
                ),
                GuestCountInfoBar(state: state),
                Expanded(
                  child: _PackageContent(
                    state: state,
                    l: l,
                    isEnglish: isEnglish,
                    customLimitController: _customLimitController,
                  ),
                ),
                _PackageBottomBar(state: state, l: l),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _PackageContent extends StatelessWidget {
  final InvitationState state;
  final AppLocalizations? l;
  final bool isEnglish;
  final TextEditingController customLimitController;

  const _PackageContent({
    required this.state,
    this.l,
    required this.isEnglish,
    required this.customLimitController,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingPackages) {
      return _LoadingState(l: l);
    }

    if (state.packagesError != null) {
      return _ErrorState(error: state.packagesError!, l: l);
    }

    if (state.availablePackages.isEmpty) {
      return _EmptyState(l: l);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l?.translate('invitation_select_package') ??
                'Select the appropriate package for your guest count',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.037),
              color: context.textTertiary,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          ...state.availablePackages.map((package) {
            final isSelected = state.selectedPackage?.id == package.id;
            return PackageCard(
              package: package,
              isSelected: isSelected,
              guestCount: state.allGuests.length,
              customPrice: state.customPackagePrice,
              isLoadingPrice: state.isLoadingCustomPrice,
              customLimit: state.customPackageLimit,
              isEnglish: isEnglish,
              customLimitController:
                  package.isCustom ? customLimitController : null,
            );
          }),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final AppLocalizations? l;

  const _LoadingState({this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: context.dynamicHeight(0.02)),
          Text(
            l?.translate('invitation_loading_packages') ?? 'Loading packages...',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.04),
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final AppLocalizations? l;

  const _ErrorState({required this.error, this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.061)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: context.dynamicWidth(0.16), color: Colors.red.shade300),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              l?.translate('invitation_packages_error') ??
                  'Error loading packages',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                color: context.textSecondary,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            SizedBox(
              width: context.dynamicWidth(0.501),
              child: PrimaryButton(
                text: l?.translate('common_retry') ?? 'Retry',
                onPressed: () {
                  context.read<InvitationCubit>().loadPackages();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations? l;

  const _EmptyState({this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.061)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: context.dynamicWidth(0.2), color: context.iconDefault),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              l?.translate('invitation_no_packages') ?? 'No packages available',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.bold,
                color: context.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageBottomBar extends StatelessWidget {
  final InvitationState state;
  final AppLocalizations? l;

  const _PackageBottomBar({required this.state, this.l});

  @override
  Widget build(BuildContext context) {
    final canProceed = state.canProceedFromPackageSelection;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.024),
            offset: Offset(0, -context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!canProceed && state.selectedPackage != null)
              _ValidationMessage(l: l),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: l?.translate('common_back') ?? 'Back',
                    onPressed: () =>
                        context.read<InvitationCubit>().previousStep(),
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.029)),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    text: l?.translate('common_next') ?? 'Next',
                    isLoading: state.isLoading,
                    onPressed: canProceed && !state.isLoading
                        ? () => context.read<InvitationCubit>().savePackageAndProceed()
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationMessage extends StatelessWidget {
  final AppLocalizations? l;

  const _ValidationMessage({this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.dynamicWidth(0.029)),
      margin: EdgeInsets.only(bottom: context.dynamicHeight(0.015)),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: Colors.red.shade700, size: context.dynamicWidth(0.051)),
          SizedBox(width: context.dynamicWidth(0.021)),
          Expanded(
            child: Text(
              l?.translate('invitation_guest_exceeds_package_message') ??
                  'Guest count exceeds package limit. Please select another package or reduce guests.',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
