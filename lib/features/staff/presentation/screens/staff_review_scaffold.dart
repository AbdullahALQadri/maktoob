import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../cubit/staff_item_cubit.dart';
import '../widgets/staff_page.dart';
import '../widgets/staff_review_bar.dart';

/// The frame of a review page (an identity, an institution): the file, then
/// approve / refuse while it is pending. It closes once decided.
class StaffReviewScaffold<T> extends StatelessWidget {
  const StaffReviewScaffold({
    super.key,
    required this.title,
    required this.isPending,
    required this.builder,
    required this.confirmKey,
    this.mustConfirmKey,
  });

  final String title;
  final bool Function(T item) isPending;
  final List<Widget> Function(BuildContext context, T item) builder;

  /// What approving means, asked before it is sent.
  final String confirmKey;

  /// A statement the reviewer ticks before approving (an identity's match).
  final String? mustConfirmKey;

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    return BlocConsumer<StaffItemCubit<T>, StaffItemState<T>>(
      listenWhen: (before, now) =>
          (now.reviewed != null && before.reviewed == null) || (now.message != null && now.message != before.message),
      listener: (context, state) {
        if (state.reviewed != null) {
          AppSnackBar.showSuccess(context, message: context.tr(state.reviewed! ? 'staff_approved' : 'staff_rejected'));
          return Navigator.of(context).pop();
        }
        if (state.item != null) AppSnackBar.showError(context, message: context.tr(state.message!));
      },
      builder: (context, state) {
        final cubit = context.read<StaffItemCubit<T>>();
        final item = state.item;
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          appBar: AppBar(title: Text(title)),
          body: item == null
              ? (state.loading
                  ? const Center(child: MkSpinner())
                  : StaffNotice(text: state.message ?? '', onRetry: cubit.load))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 24),
                        children: builder(context, item),
                      ),
                    ),
                    if (isPending(item))
                      StaffReviewBar(
                        busy: state.busy,
                        onApprove: cubit.approve,
                        onReject: cubit.reject,
                        confirmKey: confirmKey,
                        mustConfirmKey: mustConfirmKey,
                      ),
                  ],
                ),
        );
      },
    );
  }
}
