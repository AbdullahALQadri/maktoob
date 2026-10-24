import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../locale/l10n_context.dart';
import 'shell_tab.dart';

/// Phones: Home · My events · (create) · Door · My account.
class ShellBottomBar extends StatelessWidget {
  const ShellBottomBar({super.key, required this.current, required this.onSelect, required this.onCreate});

  final ShellTab current;
  final ValueChanged<ShellTab> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    Widget item(ShellTab tab) => Expanded(
      child: _Item(tab: tab, selected: tab == current, onTap: () => onSelect(tab)),
    );
    // Labels stay readable with large system text without pushing the bar up.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.cardBg,
          border: Border(top: BorderSide(color: context.borderColor)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                item(ShellTab.home),
                item(ShellTab.events),
                Expanded(
                  child: Center(child: _CreateButton(onPressed: onCreate)),
                ),
                item(ShellTab.door),
                item(ShellTab.account),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.tab, required this.selected, required this.onTap});

  final ShellTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.primaryText : context.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? context.primaryWash : AppColors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(selected ? tab.selectedIcon : tab.icon, size: 22, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr(tab.labelKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: color, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.tr('home_create_event'),
      child: Material(
        color: AppColors.primaryColor,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox.square(dimension: 52, child: Icon(Icons.add_rounded, size: 28, color: AppColors.white)),
        ),
      ),
    );
  }
}
