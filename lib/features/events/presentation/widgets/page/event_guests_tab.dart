import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/design/window_size.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../domain/entities/guest_entity.dart';
import '../../cubit/event_details/event_details_cubit.dart';
import '../../cubit/event_details/event_details_state.dart';
import '../../cubit/event_follow_up/event_follow_up_cubit.dart';
import '../guest_actions_bar.dart';
import '../guest_invitation_sheet.dart';
import 'fix_guest_dialog.dart';
import 'guest_row.dart';

/// The guest list: add or import, search by name or number, filter by reply
/// (with counts), and act on one guest.
class EventGuestsTab extends StatefulWidget {
  const EventGuestsTab({super.key, required this.state});

  final EventDetailsState state;

  @override
  State<EventGuestsTab> createState() => _EventGuestsTabState();
}

class _EventGuestsTabState extends State<EventGuestsTab> {
  var _filter = GuestFilter.all;
  late final _search = TextEditingController(text: widget.state.guestSearchQuery);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _fix(GuestEntity guest) async {
    final event = widget.state.event!;
    final followUp = context.read<EventFollowUpCubit>();
    final input = await FixGuestDialog.show(context, guest);
    // The event page reloads the list when the fix is saved.
    if (input != null) await followUp.fixGuest(event.id, guest.id, name: input.$1, phone: input.$2);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final event = state.event!;
    final cubit = context.read<EventDetailsCubit>();
    final manage = event.canManageGuests;
    final visible = state.filteredGuests.where((g) => g.matches(_filter)).toList();
    final gutter = context.pageGutter;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 8),
          sliver: SliverList.list(
            children: [
              if (manage) ...[GuestActionsBar(state: state), const SizedBox(height: 12)],
              TextField(
                controller: _search,
                onChanged: cubit.searchGuests,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: context.tr('event_page_search_guests'),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: context.cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final filter in GuestFilter.values)
                      if (filter == _filter || filter == GuestFilter.all || state.guests.any((g) => g.matches(filter)))
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(
                              '${context.tr('event_guests_${filter.name}')} ${state.guests.where((g) => g.matches(filter)).length}',
                            ),
                            selected: filter == _filter,
                            onSelected: (_) => setState(() => _filter = filter),
                            selectedColor: context.primaryWash,
                            side: BorderSide(color: filter == _filter ? AppColors.sky200 : context.borderColor),
                            showCheckmark: false,
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (visible.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(40),
              child: Text(
                context.tr(state.guests.isEmpty ? 'event_page_no_guests' : 'event_page_no_guest_match'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: context.textSecondary),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsetsDirectional.fromSTEB(gutter, 4, gutter, 32),
            sliver: SliverList.separated(
              itemCount: visible.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final guest = visible[i];
                Future<bool> resend() => cubit.resendInvitation(guest.id);
                Future<bool> remove() => cubit.removeInvitation(guest.id);
                return GuestRow(
                  guest: guest,
                  onOpen: () => GuestInvitationSheet.show(
                    context,
                    guest,
                    onResend: manage ? resend : null,
                    onRemove: manage ? remove : null,
                  ),
                  onResend: manage ? resend : null,
                  onRemove: manage ? remove : null,
                  onFix: manage ? () => _fix(guest) : null,
                );
              },
            ),
          ),
      ],
    );
  }
}
