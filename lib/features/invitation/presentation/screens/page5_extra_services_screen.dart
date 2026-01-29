import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';

/// Page 5: Extra Services Selection Screen
class Page5ExtraServicesScreen extends StatefulWidget {
  const Page5ExtraServicesScreen({super.key});

  @override
  State<Page5ExtraServicesScreen> createState() =>
      _Page5ExtraServicesScreenState();
}

class _Page5ExtraServicesScreenState extends State<Page5ExtraServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationCubit>().loadExtraServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                WizardStepHeader(
                  currentStep: 5,
                  totalSteps: 7,
                  title:
                      l?.translate('invitation_step5_title') ?? 'Extra Services',
                ),
                _PaidServicesNotice(l: l),
                Expanded(
                  child: _ExtraServicesContent(
                      state: state, l: l, isEnglish: isEnglish),
                ),
                if (state.selectedServices.isNotEmpty)
                  ServicesSummaryBar(
                    selectedServices: state.selectedServices,
                    isEnglish: isEnglish,
                  ),
                WizardBottomBar(
                  canProceed: !state.isLoadingServices,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaidServicesNotice extends StatelessWidget {
  final AppLocalizations? l;

  const _PaidServicesNotice({this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.012),
      ),
      color: Colors.amber.shade100,
      child: Row(
        children: [
          Icon(
            Icons.monetization_on,
            color: Colors.amber.shade800,
            size: context.dynamicWidth(0.051),
          ),
          SizedBox(width: context.dynamicWidth(0.021)),
          Expanded(
            child: Text(
              l?.translate('invitation_paid_services_notice') ??
                  'These are paid services that will be added to the final invoice',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.032),
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtraServicesContent extends StatelessWidget {
  final InvitationState state;
  final AppLocalizations? l;
  final bool isEnglish;

  const _ExtraServicesContent({
    required this.state,
    this.l,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingServices) {
      return _LoadingState(l: l);
    }

    if (state.servicesError != null) {
      return _ErrorState(error: state.servicesError!, l: l);
    }

    if (state.availableServices.isEmpty) {
      return _EmptyState(l: l);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l?.translate('invitation_select_services') ??
                'Select the extra services you want for your event',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.037),
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: context.dynamicWidth(0.029),
              mainAxisSpacing: context.dynamicWidth(0.029),
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
            l?.translate('invitation_loading_services') ?? 'Loading services...',
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
            Icon(
              Icons.error_outline,
              size: context.dynamicWidth(0.16),
              color: Colors.red.shade300,
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              l?.translate('invitation_services_error') ??
                  'Error loading services',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            SizedBox(
              width: context.dynamicWidth(0.501),
              child: PrimaryButton(
                text: l?.translate('common_retry') ?? 'Retry',
                onPressed: () {
                  context.read<InvitationCubit>().loadExtraServices();
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
            Icon(
              Icons.room_service_outlined,
              size: context.dynamicWidth(0.2),
              color: Colors.grey.shade400,
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              l?.translate('invitation_no_services') ??
                  'No extra services available',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              l?.translate('invitation_continue_next_step') ??
                  'You can continue to the next step',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                color: context.iconSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
