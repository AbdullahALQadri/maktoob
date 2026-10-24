import 'package:flutter/material.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../domain/entities/guest_entity.dart';

/// Fix the name or number of a guest before their invitation is sent.
/// Returns the new (name, phone), or null when the host closes it.
class FixGuestDialog extends StatefulWidget {
  const FixGuestDialog({super.key, required this.guest});

  final GuestEntity guest;

  static Future<(String, String)?> show(BuildContext context, GuestEntity guest) => showDialog<(String, String)>(
    context: context,
    builder: (_) => FixGuestDialog(guest: guest),
  );

  @override
  State<FixGuestDialog> createState() => _FixGuestDialogState();
}

class _FixGuestDialogState extends State<FixGuestDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.guest.name);
  late final _phone = TextEditingController(text: widget.guest.phone);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (_form.currentState!.validate()) Navigator.pop(context, (_name.text.trim(), _phone.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    String? required(String? v) => (v ?? '').trim().isEmpty ? context.tr('event_page_required') : null;
    return AlertDialog(
      title: Text(context.tr('event_page_fix_guest')),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: context.tr('event_page_guest_name')),
              validator: required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: context.tr('event_page_guest_phone')),
              validator: required,
              onFieldSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('common_cancel'))),
        FilledButton(onPressed: _save, child: Text(context.tr('common_save'))),
      ],
    );
  }
}
