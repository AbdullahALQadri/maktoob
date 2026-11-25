import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/guest_group.dart';
import '../../domain/usecases/guest_group_usecases.dart';
import 'guest_group_tile.dart';

/// Lets the host pick one of their saved groups and returns it with its
/// people (to add them to an event's guest list). Null when nothing is picked.
Future<GuestGroup?> showGroupPickerSheet(BuildContext context) {
  return showModalBottomSheet<GuestGroup>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => GroupPickerSheet(getGroups: di.sl(), getGroup: di.sl()),
  );
}

class GroupPickerSheet extends StatefulWidget {
  const GroupPickerSheet({super.key, required this.getGroups, required this.getGroup});

  final GetGuestGroupsUseCase getGroups;
  final GetGuestGroupUseCase getGroup;

  @override
  State<GroupPickerSheet> createState() => _GroupPickerSheetState();
}

class _GroupPickerSheetState extends State<GroupPickerSheet> {
  List<GuestGroup>? _groups;
  bool _failed = false;
  int? _opening;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    final result = await widget.getGroups(const NoParams());
    if (!mounted) return;
    setState(() {
      _groups = result.fold((_) => null, (overview) => overview.groups);
      _failed = result.isLeft();
    });
  }

  Future<void> _pick(GuestGroup group) async {
    setState(() => _opening = group.id);
    final result = await widget.getGroup(group.id);
    if (!mounted) return;
    final full = result.fold((_) => null, (g) => g);
    if (full != null) return Navigator.of(context).pop(full);
    setState(() {
      _opening = null;
      _failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('groups_pick'),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.textPrimary),
            ),
            const SizedBox(height: 12),
            if (_failed)
              OutlinedButton(onPressed: _load, child: Text(context.tr('common_retry')))
            else if (groups == null)
              const Padding(padding: EdgeInsets.all(24), child: Center(child: MkSpinner()))
            else if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '${context.tr('groups_empty')}. ${context.tr('groups_empty_hint')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.6, color: context.textSecondary),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: groups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => Opacity(
                    opacity: _opening == null || _opening == groups[index].id ? 1 : 0.5,
                    child: GuestGroupTile(
                      group: groups[index],
                      onTap: _opening == null ? () => _pick(groups[index]) : () {},
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
