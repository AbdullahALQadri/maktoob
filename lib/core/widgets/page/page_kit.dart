import 'package:flutter/material.dart';

import '../../design/window_size.dart';
import '../../utils/app_colors.dart';

/// The building blocks of the app's plain pages (account, identity,
/// institution): flat cards with a hairline, fixed sizes that do not grow
/// with the window, and colours that follow the light / night theme.

/// A flat outlined card, with an optional title above its content.
class PageCard extends StatelessWidget {
  const PageCard({super.key, this.title, required this.child, this.padding = const EdgeInsetsDirectional.all(16)});

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  /// A card of rows separated by hairlines.
  factory PageCard.rows({Key? key, String? title, required List<Widget> rows}) => PageCard(
        key: key,
        title: title,
        padding: EdgeInsets.zero,
        child: Builder(
          builder: (context) => Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) Divider(height: 1, thickness: 1, color: context.dividerColor),
                rows[i],
              ],
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
    if (title == null) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            title!,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: context.textSecondary),
          ),
        ),
        card,
      ],
    );
  }
}

/// One row of a [PageCard.rows]: an icon, a title, an optional second line,
/// and where it leads.
class PageRow extends StatelessWidget {
  const PageRow({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.destructive = false,
    this.selected = false,
    this.subtitleLtr = false,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Replaces the arrow (a value, a tick, a switch).
  final Widget? trailing;
  final bool destructive;

  /// The chosen one of a set (a language, an account kind).
  final bool selected;

  /// The second line is a number or an address read left to right.
  final bool subtitleLtr;

  @override
  Widget build(BuildContext context) {
    final ink = destructive ? AppColors.red500 : (selected ? context.primaryText : context.textPrimary);
    final forward = Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right;
    return Material(
      color: selected ? context.primaryWash : AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 12, 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 22, color: destructive ? AppColors.red500 : context.primaryText),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ink)),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          textDirection: subtitleLtr ? TextDirection.ltr : null,
                          style: TextStyle(fontSize: 12.5, height: 1.45, color: context.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing ??
                    (selected
                        ? Icon(Icons.check_circle, size: 20, color: context.primaryText)
                        : onTap == null
                            ? const SizedBox.shrink()
                            : Icon(forward, size: 20, color: context.iconDefault)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The title of a page that has no app bar (a tab), with a line under it.
class PageHeading extends StatelessWidget {
  const PageHeading({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimary)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: TextStyle(fontSize: 14, height: 1.5, color: context.textSecondary)),
        ],
      ],
    );
  }
}

/// A page's scrolling content inside the readable gutter. On wide windows
/// [side] sits in a second column beside [children]; on a phone it follows
/// them.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.side = const [], this.gap = 16, this.bottom = 32});

  final List<Widget> children;
  final List<Widget> side;
  final double gap;
  final double bottom;

  List<Widget> _spaced(List<Widget> items) => [
        for (var i = 0; i < items.length; i++) ...[if (i > 0) SizedBox(height: gap), items[i]],
      ];

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    final twoColumns = side.isNotEmpty && context.windowSize.atLeastExpanded;
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(gutter, 16, gutter, bottom),
      children: twoColumns
          ? [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(children: _spaced(children))),
                  SizedBox(width: gap),
                  Expanded(child: Column(children: _spaced(side))),
                ],
              ),
            ]
          : _spaced([...children, ...side]),
    );
  }
}

/// A small flat label (an account kind, "verified").
class PagePill extends StatelessWidget {
  const PagePill({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: context.primaryWash, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: context.primaryText), const SizedBox(width: 4)],
          // A long label (or very large text) shortens instead of spilling out.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
