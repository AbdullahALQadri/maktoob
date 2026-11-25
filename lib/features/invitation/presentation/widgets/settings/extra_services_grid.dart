import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/design/window_size.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';
import '../widgets.dart';

/// The extra services offered for this occasion: two across on a phone,
/// more on wider windows.
class ExtraServicesGrid extends StatelessWidget {
  const ExtraServicesGrid({super.key, required this.state});

  final InvitationState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingServices) return const ServicesListSkeleton(count: 2);
    if (state.servicesError != null) {
      return Column(
        children: [
          Text(context.tr('invitation_services_error'), style: TextStyle(color: context.textSecondary)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: context.read<InvitationCubit>().loadExtraServices,
            child: Text(context.tr('common_retry')),
          ),
        ],
      );
    }
    if (state.availableServices.isEmpty) {
      return Text(context.tr('wizard_extras_empty'), style: TextStyle(color: context.textSecondary));
    }
    final columns = switch (context.windowSize) {
      WindowSize.compact => 2,
      WindowSize.medium => 3,
      _ => 4,
    };
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: state.availableServices.length,
      itemBuilder: (context, index) {
        final service = state.availableServices[index];
        return ExtraServiceCard(
          service: service,
          isSelected: state.selectedServices.contains(service),
          isEnglish: context.languageCode == 'en',
        );
      },
    );
  }
}
