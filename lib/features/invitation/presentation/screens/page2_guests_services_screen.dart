import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';

/// Page 2 (of 3): Guests & Services
/// Combines guest management and extra services into a single tabbed page.
class Page2GuestsServicesScreen extends StatefulWidget {
  const Page2GuestsServicesScreen({super.key});

  @override
  State<Page2GuestsServicesScreen> createState() =>
      _Page2GuestsServicesScreenState();
}

class _Page2GuestsServicesScreenState extends State<Page2GuestsServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showManualForm = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load extra services when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationCubit>().loadExtraServices();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (previous, current) {
        return (previous.duplicatePhoneNumbers.isEmpty &&
                current.duplicatePhoneNumbers.isNotEmpty) ||
            (previous.errorMessage != current.errorMessage &&
                current.errorMessage != null);
      },
      listener: (context, state) {
        if (state.duplicatePhoneNumbers.isNotEmpty) {
          _showDuplicateDialog(context, state.duplicatePhoneNumbers, l);
        }
        if (state.errorMessage != null) {
          final l = AppLocalizations.of(context);
          final msg = l?.translate(state.errorMessage!) ?? state.errorMessage!;
          AppSnackBar.showError(context, message: msg);
          context.read<InvitationCubit>().clearError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          appBar: MaktoobAppBar(
            title: l?.translate('app_name') ?? 'Maktoob',
            titleFontSize: 20,
            titleFontWeight: FontWeight.w800,
            onForward: () => context.read<InvitationCubit>().previousStep(),
          ),
          body: Column(
            children: [
              WizardStepHeader(
                currentStep: 2,
                totalSteps: 3,
                title: l?.translate('wizard_step2_label') ?? 'الضيوف والخدمات',
              ),
              // Pill-style tabs
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.dynamicWidth(0.05),
                  4,
                  context.dynamicWidth(0.05),
                  16,
                ),
                child: PillTabs(
                  controller: _tabController,
                  tabs: [
                    '${l?.translate('invitation_guests') ?? 'الضيوف'} (${state.totalGuestCount})',
                    '${l?.translate('invitation_services') ?? 'الخدمات'} (${state.selectedServices.length})',
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _GuestsTab(
                      state: state,
                      showManualForm: _showManualForm,
                      onToggleManualForm: () => setState(() {
                        _showManualForm = !_showManualForm;
                      }),
                    ),
                    _ServicesTab(state: state),
                  ],
                ),
              ),
              if (state.selectedServices.isNotEmpty)
                ServicesSummaryBar(
                  selectedServices: state.selectedServices,
                  isEnglish:
                      Localizations.localeOf(context).languageCode == 'en',
                ),
              _BottomBar(state: state),
            ],
          ),
        );
      },
    );
  }

  void _showDuplicateDialog(
    BuildContext context,
    Set<String> duplicates,
    AppLocalizations? l,
  ) {
    if (duplicates.isEmpty) return;
    final cubit = context.read<InvitationCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Text(l?.translate('invitation_duplicates_found') ??
                'Duplicates Found'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l?.translate('invitation_duplicates_removed') ??
                  'The following duplicate numbers were automatically removed:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: duplicates
                      .map((phone) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.phone, size: 16),
                                const SizedBox(width: 8),
                                Text(phone),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.clearDuplicateNotification();
            },
            child: Text(l?.translate('common_ok') ?? 'OK'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// GUESTS TAB
// =============================================================================

class _GuestsTab extends StatelessWidget {
  final InvitationState state;
  final bool showManualForm;
  final VoidCallback onToggleManualForm;

  const _GuestsTab({
    required this.state,
    required this.showManualForm,
    required this.onToggleManualForm,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GuestImportOptions(
            state: state,
            showManualForm: showManualForm,
            onToggleManualForm: onToggleManualForm,
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          if (showManualForm) ...[
            ManualGuestForm(
              onGuestAdded: (guest) {
                context.read<InvitationCubit>().addManualGuest(guest);
              },
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
          ],
          GuestListSection(state: state),
        ],
      ),
    );
  }
}

// =============================================================================
// SERVICES TAB
// =============================================================================

class _ServicesTab extends StatelessWidget {
  final InvitationState state;

  const _ServicesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    if (state.isLoadingServices) {
      return const ServicesListSkeleton();
    }

    if (state.servicesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: context.dynamicWidth(0.12), color: Colors.red.shade300),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              l?.translate('invitation_services_error') ??
                  'Error loading services',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            PrimaryButton(
              text: l?.translate('common_retry') ?? 'Retry',
              onPressed: () =>
                  context.read<InvitationCubit>().loadExtraServices(),
            ),
          ],
        ),
      );
    }

    if (state.availableServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.room_service_outlined,
                size: context.dynamicWidth(0.16), color: context.iconDefault),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              l?.translate('invitation_no_services') ??
                  'No extra services available',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.04),
                fontWeight: FontWeight.bold,
                color: context.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paid services notice
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.03)),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius:
                  BorderRadius.circular(context.dynamicWidth(0.03)),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on,
                    color: Colors.amber.shade700,
                    size: context.dynamicWidth(0.05)),
                SizedBox(width: context.dynamicWidth(0.02)),
                Expanded(
                  child: Text(
                    l?.translate('invitation_paid_services_notice') ??
                        'These are paid services added to the final invoice',
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.031),
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: context.dynamicWidth(0.025),
              mainAxisSpacing: context.dynamicWidth(0.025),
              childAspectRatio: 0.85,
            ),
            itemCount: state.availableServices.length,
            itemBuilder: (context, index) {
              final service = state.availableServices[index];
              return ExtraServiceCard(
                service: service,
                isSelected: state.selectedServices.contains(service),
                isEnglish: isEnglish,
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BOTTOM BAR
// =============================================================================

class _BottomBar extends StatelessWidget {
  final InvitationState state;

  const _BottomBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canProceed = state.canProceedFromGuestManagement && !state.isLoading;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          text: l?.translate('wizard_continue_to_review') ??
              'متابعة إلى المراجعة',
          icon: Icons.arrow_forward_rounded,
          isLoading: state.isLoading,
          onPressed: canProceed
              ? () => context
                  .read<InvitationCubit>()
                  .saveGuestsAndServicesAndProceed()
              : null,
        ),
      ),
    );
  }
}
