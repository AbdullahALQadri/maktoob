import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/design/window_size.dart';

/// The decision on a payment request: approve it, or refuse it with the
/// reason the client will read.
class StaffReviewBar extends StatelessWidget {
  const StaffReviewBar({
    super.key,
    required this.busy,
    required this.onApprove,
    required this.onReject,
    this.confirmKey = 'staff_approve_confirm',
    this.mustConfirmKey,
  });

  final bool busy;
  final Future<void> Function() onApprove;
  final Future<void> Function(String reason) onReject;

  /// What approving means, asked before it is sent.
  final String confirmKey;

  /// A statement the reviewer must tick before approving.
  final String? mustConfirmKey;

  Future<void> _approve(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => _ApproveDialog(confirmKey: confirmKey, mustConfirmKey: mustConfirmKey),
    );
    if (yes == true) await onApprove();
  }

  Future<void> _reject(BuildContext context) async {
    final reason = await showDialog<String>(context: context, builder: (_) => const _ReasonDialog());
    if (reason != null) await onReject(reason);
  }

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(gutter, 12, gutter, 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const Key('staff_reject'),
                onPressed: busy ? null : () => _reject(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppColors.red500,
                ),
                child: FittedBox(child: Text(context.tr('staff_reject'))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                key: const Key('staff_approve'),
                text: context.tr('staff_approve'),
                icon: Icons.check,
                height: 52,
                isLoading: busy,
                onPressed: busy ? null : () => _approve(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog();

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('staff_reject')),
      content: TextField(
        key: const Key('staff_reason'),
        controller: _reason,
        autofocus: true,
        maxLines: 3,
        maxLength: 1000,
        decoration: InputDecoration(
          labelText: context.tr('staff_reason'),
          helperText: context.tr('staff_reason_hint'),
          helperMaxLines: 2,
          counterText: '',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.tr('common_cancel'))),
        TextButton(
          key: const Key('staff_reject_send'),
          onPressed: () {
            final reason = _reason.text.trim();
            if (reason.isNotEmpty) Navigator.of(context).pop(reason);
          },
          child: Text(context.tr('staff_reject'), style: const TextStyle(color: AppColors.red500)),
        ),
      ],
    );
  }
}

class _ApproveDialog extends StatefulWidget {
  const _ApproveDialog({required this.confirmKey, required this.mustConfirmKey});

  final String confirmKey;
  final String? mustConfirmKey;

  @override
  State<_ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<_ApproveDialog> {
  late bool _ticked = widget.mustConfirmKey == null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr(widget.confirmKey), style: const TextStyle(fontSize: 15, height: 1.6)),
          if (widget.mustConfirmKey != null)
            CheckboxListTile(
              key: const Key('staff_approve_tick'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _ticked,
              onChanged: (value) => setState(() => _ticked = value ?? false),
              title: Text(context.tr(widget.mustConfirmKey!), style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.tr('common_cancel'))),
        TextButton(
          key: const Key('staff_approve_yes'),
          onPressed: _ticked ? () => Navigator.of(context).pop(true) : null,
          child: Text(context.tr('staff_approve')),
        ),
      ],
    );
  }
}
