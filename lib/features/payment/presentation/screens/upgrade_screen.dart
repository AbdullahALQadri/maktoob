import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/core.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/upgrade_cubit.dart';
import '../cubit/upgrade_state.dart';
import '../widgets/upgrade_custom_field.dart';
import '../widgets/upgrade_option_tile.dart';

/// "Increase invitations": an active event moves to a bigger package, or to
/// a number the host names, and pays only the difference.
class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key, required this.eventId, this.eventTitle});

  final String eventId;
  final String? eventTitle;

  /// The screen with its own cubit, already loading. Pops `true` once a
  /// payment for the upgrade was sent.
  static Route<bool> route({required String eventId, String? eventTitle}) => MaterialPageRoute(
        settings: const RouteSettings(name: '/r/upgrade'),
        builder: (_) => BlocProvider(
          create: (_) => UpgradeCubit(getOptions: di.sl(), getCustomQuote: di.sl(), eventId: eventId)..load(),
          child: UpgradeScreen(eventId: eventId, eventTitle: eventTitle),
        ),
      );

  void _pay(BuildContext context, UpgradeState state) {
    final quote = state.quote;
    if (quote == null) return;
    final navigator = Navigator.of(context);
    navigator.pushNamed(
      Routes.payment,
      arguments: {
        'eventId': eventId,
        'amount': quote.total,
        'eventTitle': eventTitle,
        'endpoint': Endpoints.paymentRequestUpgrade(
          packageId: state.usesCustom ? null : state.packageId,
          customInvitations: state.customInvitations,
        ),
        'onComplete': () {
          navigator.pop(); // the payment screen
          if (navigator.canPop()) navigator.pop(true); // this screen
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(title: Text(context.tr('upgrade_title'))),
      body: BlocBuilder<UpgradeCubit, UpgradeState>(
        builder: (context, state) {
          final cubit = context.read<UpgradeCubit>();
          final options = state.options;
          if (state.loading) return const Center(child: MkSpinner());
          if (options == null) {
            return _Notice(text: state.error ?? '', action: context.tr('common_retry'), onAction: cubit.load);
          }
          if (options.hasPendingRequest) return _Notice(text: context.tr('upgrade_pending'));
          if (options.isEmpty) return _Notice(text: context.tr('upgrade_none'));

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 24),
                  children: [
                    Text(
                      context.tr('upgrade_choose'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('upgrade_current', {'count': options.currentLimit}),
                      style: TextStyle(fontSize: 14, height: 1.5, color: context.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    for (final package in options.packages) ...[
                      UpgradeOptionTile(
                        key: Key('upgrade_package_${package.id}'),
                        package: package,
                        selected: state.packageId == package.id,
                        onTap: () => cubit.selectPackage(package.id),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (options.customEnabled) ...[
                      const SizedBox(height: 8),
                      UpgradeCustomField(state: state, onCalculate: cubit.calculateCustom),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsetsDirectional.fromSTEB(gutter, 12, gutter, 12),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  border: Border(top: BorderSide(color: context.borderColor)),
                ),
                child: SafeArea(
                  top: false,
                  child: PrimaryButton(
                    key: const Key('upgrade_continue'),
                    text: state.quote == null
                        ? context.tr('upgrade_continue')
                        : '${context.tr('upgrade_continue')} · ${state.quote!.total.toStringAsFixed(2)} ${context.tr('currency_ils')}',
                    onPressed: state.quote == null ? null : () => _pay(context, state),
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

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.6, color: context.textSecondary),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(action!)),
            ],
          ],
        ),
      ),
    );
  }
}
