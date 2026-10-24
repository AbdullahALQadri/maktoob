import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';

/// Nothing to list: no events yet, none in this status, or no name matches.
class MyEventsEmpty extends StatelessWidget {
  const MyEventsEmpty({super.key, required this.query, required this.filtered, required this.onShowAll});

  final String query;

  /// A status tab or a search is narrowing the list.
  final bool filtered;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final title = query.isNotEmpty
        ? context.tr('my_events_no_match', {'query': query})
        : context.tr(filtered ? 'my_events_none_here' : 'my_events_empty_title');
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: context.primaryWash, shape: BoxShape.circle),
            child: Icon(
              filtered ? Icons.search_off_rounded : Icons.event_note_outlined,
              size: 30,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.textPrimary),
          ),
          if (!filtered) ...[
            const SizedBox(height: 6),
            Text(
              context.tr('my_events_empty_text'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.textSecondary, height: 1.5),
            ),
          ],
          if (filtered) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onShowAll, child: Text(context.tr('my_events_show_all'))),
          ],
        ],
      ),
    );
  }
}
