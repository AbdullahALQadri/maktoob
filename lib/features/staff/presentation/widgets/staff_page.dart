import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/design/window_size.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../cubit/staff_load_cubit.dart';

/// The frame of a staff list: loading, a problem with a retry, nothing to
/// show, or the rows (pull to refresh).
class StaffPage<T> extends StatelessWidget {
  const StaffPage({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.rows,
    required this.emptyText,
    required this.rowBuilder,
    this.header,
  });

  final StaffLoadState<List<T>> state;
  final Future<void> Function() onRefresh;
  final List<T> rows;
  final String emptyText;
  final Widget Function(BuildContext context, T row) rowBuilder;

  /// Shown above the rows (a search box).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    final Widget content;
    if (state.value == null && state.loading) {
      content = const Padding(padding: EdgeInsets.all(48), child: Center(child: MkSpinner()));
    } else if (state.value == null) {
      content = StaffNotice(text: state.error ?? '', onRetry: onRefresh);
    } else if (rows.isEmpty) {
      content = StaffNotice(text: emptyText);
    } else {
      content = Column(
        children: [
          for (final row in rows) ...[rowBuilder(context, row), const SizedBox(height: 8)],
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, 32),
        children: [
          if (header != null) ...[header!, const SizedBox(height: 12)],
          content,
        ],
      ),
    );
  }
}

/// A line of text in the middle of a page, with a retry when one is given.
class StaffNotice extends StatelessWidget {
  const StaffNotice({super.key, required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Text(
            text.isEmpty ? context.tr('staff_load_failed') : text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.6, color: context.textSecondary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(context.tr('common_retry'))),
          ],
        ],
      ),
    );
  }
}

/// A flat, outlined row of a staff list.
class StaffRowCard extends StatelessWidget {
  const StaffRowCard({super.key, required this.title, required this.lines, this.trailing, this.onTap});

  final String title;

  /// Short facts under the title; empty ones are skipped.
  final List<String?> lines;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final facts = [for (final line in lines) if (line != null && line.isNotEmpty) line];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 12, 10),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  for (final fact in facts)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(fact, style: TextStyle(fontSize: 12.5, height: 1.45, color: context.textSecondary)),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}

/// A search box that asks again shortly after the typing stops.
class StaffSearchField extends StatefulWidget {
  const StaffSearchField({super.key, required this.hint, required this.onSearch});

  final String hint;
  final ValueChanged<String> onSearch;

  @override
  State<StaffSearchField> createState() => _StaffSearchFieldState();
}

class _StaffSearchFieldState extends State<StaffSearchField> {
  int _typed = 0;

  Future<void> _changed(String text) async {
    final mine = ++_typed;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted && mine == _typed) widget.onSearch(text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: _changed,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSearch,
      decoration: InputDecoration(hintText: widget.hint, prefixIcon: const Icon(Icons.search), isDense: true),
    );
  }
}
