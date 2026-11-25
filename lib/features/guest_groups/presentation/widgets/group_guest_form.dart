import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';

/// Adds one person to a group: a name, and a mobile number when there is one.
class GroupGuestForm extends StatefulWidget {
  const GroupGuestForm({super.key, required this.busy, required this.onAdd});

  final bool busy;

  /// Answers true when the guest was saved (the fields are then cleared).
  final Future<bool> Function(String name, String phone) onAdd;

  @override
  State<GroupGuestForm> createState() => _GroupGuestFormState();
}

class _GroupGuestFormState extends State<GroupGuestForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    if (await widget.onAdd(name, _phone.text.trim()) && mounted) {
      _name.clear();
      _phone.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('group_guest_name'),
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: context.tr('groups_guest_name'), isDense: true),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('group_guest_phone'),
            controller: _phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _add(),
            decoration: InputDecoration(labelText: context.tr('groups_guest_phone'), isDense: true),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('group_guest_add'),
            onPressed: widget.busy ? null : _add,
            icon: const Icon(Icons.person_add_alt_outlined, size: 18),
            label: Text(context.tr('groups_add_guest')),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}
