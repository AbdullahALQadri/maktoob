import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../../events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../../events/presentation/cubit/events_list/events_list_state.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

/// Normalizes Arabic/Latin text for forgiving matching: lower-case, unify
/// alef forms, taa marbuta / haa, alef maqsura / yaa, strip tashkeel.
String normalizeSearchText(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[ً-ْـ]'), '')
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي')
    .trim();

/// The user's events matching [query] on name, type, venue, address,
/// description or date. Every whitespace-separated term must match.
List<EventEntity> searchEventList(List<EventEntity> events, String query) {
  final terms = normalizeSearchText(query)
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
  if (terms.isEmpty) return events;
  return events.where((e) {
    final hay = normalizeSearchText([
      e.name,
      e.type,
      e.venue,
      e.venueAddress ?? '',
      e.description ?? '',
      e.date,
    ].join(' '));
    return terms.every(hay.contains);
  }).toList();
}

/// Home search: finds the host's own events (loads them if the events tab
/// was never opened) and opens the chosen one.
class EventSearchDelegate extends SearchDelegate<String?> {
  final EventsListCubit cubit;
  final String hint;

  EventSearchDelegate({required this.cubit, required this.hint})
      : super(searchFieldLabel: hint) {
    if (cubit.state.events.isEmpty && !cubit.state.isLoading) {
      cubit.loadEvents();
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.close), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const BackButtonIcon(),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<EventsListCubit, EventsListState>(
      bloc: cubit,
      builder: (context, state) {
        if (state.isLoading && state.events.isEmpty) {
          return const Center(child: MkSpinner());
        }
        final results = searchEventList(state.events, query);
        if (results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              child: Text(
                t.translate(state.events.isEmpty
                    ? 'home_search_no_events'
                    : 'home_search_no_results'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: context.textSecondary),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final e = results[i];
            return Material(
              color: context.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: BorderSide(color: context.borderColor),
              ),
              child: ListTile(
                leading: const Icon(Icons.event_outlined,
                    color: AppColors.primary),
                title: Text(e.name,
                    style: AppTextStyles.titleSmall
                        .copyWith(color: context.textPrimary)),
                subtitle: Text(
                  [e.date, e.venue].where((s) => s.isNotEmpty).join(' · '),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: context.textSecondary),
                ),
                onTap: () => close(context, e.id),
              ),
            );
          },
        );
      },
    );
  }
}
