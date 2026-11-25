import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';
import '../../widgets/settings/extra_services_grid.dart';
import '../../widgets/settings/settings_section.dart';
import '../../widgets/widgets.dart';

/// Step 4: how the invitation reaches the guests, how they reply, and
/// anything extra for the day.
class SettingsStep extends StatefulWidget {
  const SettingsStep({super.key});

  @override
  State<SettingsStep> createState() => _SettingsStepState();
}

class _SettingsStepState extends State<SettingsStep> {
  static const _methods = [('whatsapp', Icons.chat_outlined), ('email', Icons.mail_outline)];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InvitationCubit>().loadExtraServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InvitationCubit>();
    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (before, now) => before.errorMessage != now.errorMessage && now.errorMessage != null,
      listener: showWizardError,
      builder: (context, state) {
        return WizardStepFrame(
          step: InvitationStep.settings,
          actionLabel: context.tr('wizard_next_payment'),
          isBusy: state.isLoading,
          onAction: cubit.saveSettingsAndProceed,
          children: [
            SettingsSection(
              title: context.tr('wizard_delivery_title'),
              subtitle: context.tr('wizard_delivery_subtitle'),
              children: [
                for (final (method, icon) in _methods) ...[
                  SettingsChoiceTile(
                    key: Key('delivery_$method'),
                    icon: icon,
                    title: context.tr('wizard_delivery_$method'),
                    hint: context.tr('wizard_delivery_${method}_hint'),
                    selected: state.deliveryMethod == method,
                    onTap: () => cubit.setDeliveryMethod(method),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
            const SizedBox(height: 20),
            SettingsSection(
              title: context.tr('wizard_reply_title'),
              subtitle: context.tr('wizard_reply_subtitle'),
              children: [
                SettingsChoiceTile(
                  key: const Key('require_response'),
                  icon: Icons.how_to_reg_outlined,
                  title: context.tr('wizard_require_response'),
                  hint: context.tr('wizard_require_response_hint'),
                  selected: state.requireResponse,
                  isSwitch: true,
                  onTap: () => cubit.setRequireResponse(!state.requireResponse),
                ),
                const SizedBox(height: 12),
                CompanionsSection(state: state),
                const SizedBox(height: 12),
                RsvpSettingsSection(state: state),
              ],
            ),
            const SizedBox(height: 20),
            SettingsSection(
              title: context.tr('wizard_extras_title'),
              subtitle: context.tr('wizard_extras_subtitle'),
              children: [ExtraServicesGrid(state: state)],
            ),
            if (state.selectedServices.isNotEmpty) ...[
              const SizedBox(height: 12),
              ServicesSummaryBar(
                selectedServices: state.selectedServices,
                isEnglish: context.languageCode == 'en',
              ),
            ],
          ],
        );
      },
    );
  }
}
