import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/staff_request_cubit.dart';
import '../widgets/staff_page.dart';
import '../widgets/staff_request_facts.dart';
import '../widgets/staff_review_bar.dart';

/// One payment request: who paid what and how, the receipt, and the decision.
class StaffRequestScreen extends StatelessWidget {
  const StaffRequestScreen({super.key});

  static Route<void> route(int id) => MaterialPageRoute(
        settings: const RouteSettings(name: '/r/staff-request'),
        builder: (_) => BlocProvider(
          create: (_) => StaffRequestCubit(getRequest: di.sl(), review: di.sl(), id: id)..load(),
          child: const StaffRequestScreen(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    return BlocConsumer<StaffRequestCubit, StaffRequestState>(
      listenWhen: (before, now) =>
          (now.reviewed != null && before.reviewed == null) || (now.message != null && now.message != before.message),
      listener: (context, state) {
        if (state.reviewed != null) {
          AppSnackBar.showSuccess(
            context,
            message: context.tr(state.reviewed! ? 'staff_approved' : 'staff_rejected'),
          );
          return Navigator.of(context).pop();
        }
        if (state.request != null) AppSnackBar.showError(context, message: context.tr(state.message!));
      },
      builder: (context, state) {
        final cubit = context.read<StaffRequestCubit>();
        final request = state.request;
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          appBar: AppBar(title: Text(context.tr('staff_request_title'))),
          body: request == null
              ? (state.loading
                  ? const Center(child: MkSpinner())
                  : StaffNotice(text: state.message ?? '', onRetry: cubit.load))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 24),
                        children: [StaffRequestFacts(request: request)],
                      ),
                    ),
                    if (request.isPending)
                      StaffReviewBar(busy: state.busy, onApprove: cubit.approve, onReject: cubit.reject),
                  ],
                ),
        );
      },
    );
  }
}
