import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';

/// Asks for a group's name. Returns it trimmed, or null when cancelled or
/// left empty.
Future<String?> showGroupNameDialog(
  BuildContext context, {
  required String title,
  required String action,
  String initial = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _GroupNameDialog(title: title, action: action, initial: initial),
  );
}

class _GroupNameDialog extends StatefulWidget {
  const _GroupNameDialog({required this.title, required this.action, required this.initial});

  final String title;
  final String action;
  final String initial;

  @override
  State<_GroupNameDialog> createState() => _GroupNameDialogState();
}

class _GroupNameDialogState extends State<_GroupNameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() {
    final name = _controller.text.trim();
    Navigator.of(context).pop(name.isEmpty ? null : name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('group_name_input'),
        controller: _controller,
        autofocus: true,
        maxLength: 255,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _done(),
        decoration: InputDecoration(
          labelText: context.tr('groups_name'),
          hintText: context.tr('groups_name_hint'),
          counterText: '',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.tr('common_cancel'))),
        TextButton(key: const Key('group_name_done'), onPressed: _done, child: Text(widget.action)),
      ],
    );
  }
}
