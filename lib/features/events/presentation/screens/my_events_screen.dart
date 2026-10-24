import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';
import '../../../../core/widgets/network/saved_copy_note.dart';
import '../../domain/entities/event_card.dart';
import '../cubit/my_events/my_events_cubit.dart';
import '../cubit/my_events/my_events_state.dart';
import '../widgets/event_card_grid.dart';
import '../widgets/event_row_tile.dart';
import '../widgets/my_events_empty.dart';
import '../widgets/my_events_filters.dart';
import '../widgets/my_events_search_field.dart';

/// "My events": the same list as the web portal (status tabs with counts,
/// search by name). Phones get rows, wider screens a grid of cards; the next
/// page loads as the list scrolls.
class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key, required this.onOpenEvent});

  final ValueChanged<String> onOpenEvent;

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  late final MyEventsCubit _cubit = context.read<MyEventsCubit>();
  late final _search = TextEditingController(text: _cubit.state.query);

  @override
  void initState() {
    super.initState();
    if (_cubit.state.page == 0) _cubit.load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _showAll() {
    _search.clear();
    _cubit.clearFilters();
  }

  bool _nearEnd(ScrollNotification n) {
    if (n.metrics.extentAfter < 400) _cubit.loadMore();
    return false;
  }

  void _open(EventCard event) => widget.onOpenEvent('${event.id}');

  @override
  Widget build(BuildContext context) {
    final compact = context.windowSize.isCompact;
    final gutter = context.pageGutter;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MyEventsCubit, MyEventsState>(
          builder: (context, state) => RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: _cubit.refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: _nearEnd,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsetsDirectional.fromSTEB(gutter, 20, gutter, 12),
                    sliver: SliverList.list(
                      children: [
                        Text(
                          context.tr('home_my_events'),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimary),
                        ),
                        if (state.savedAgo != null) ...[const SizedBox(height: 12), const SavedCopyNote()],
                        const SizedBox(height: 12),
                        MyEventsSearchField(controller: _search, onChanged: _cubit.search),
                        const SizedBox(height: 12),
                        MyEventsFilters(
                          selected: state.status,
                          counts: state.counts,
                          onSelect: _cubit.showStatus,
                          wrap: !compact,
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsetsDirectional.fromSTEB(gutter, 4, gutter, 32),
                    sliver: _body(context, state, compact),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, MyEventsState state, bool compact) {
    if (state.phase == MyEventsPhase.loading) {
      return SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const SkeletonBox(height: 110, borderRadius: 12),
      );
    }
    if (state.phase == MyEventsPhase.failed) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(context.tr('home_something_wrong'), style: TextStyle(fontSize: 16, color: context.textSecondary)),
            TextButton(onPressed: _cubit.load, child: Text(context.tr('common_retry'))),
          ],
        ),
      );
    }
    if (state.items.isEmpty) {
      return SliverToBoxAdapter(
        child: MyEventsEmpty(query: state.query, filtered: state.isFiltered, onShowAll: _showAll),
      );
    }
    final more = state.phase == MyEventsPhase.loadingMore
        ? const Padding(
            padding: EdgeInsetsDirectional.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        : const SizedBox.shrink();
    if (!compact) {
      return SliverList.list(
        children: [
          EventCardGrid(events: state.items, onOpen: _open),
          more,
        ],
      );
    }
    return SliverList.separated(
      itemCount: state.items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) =>
          i == state.items.length ? more : EventRowTile(event: state.items[i], onTap: () => _open(state.items[i])),
    );
  }
}
