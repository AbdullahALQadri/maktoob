import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../locale/l10n_context.dart';
import 'shell_tab.dart';

/// Tablets: a rail on the reading side with the create button on top.
class ShellRail extends StatelessWidget {
  const ShellRail({super.key, required this.current, required this.onSelect, required this.onCreate});

  final ShellTab current;
  final ValueChanged<ShellTab> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: context.cardBg,
      selectedIndex: current.index,
      onDestinationSelected: (i) => onSelect(ShellTab.values[i]),
      labelType: NavigationRailLabelType.all,
      groupAlignment: -0.85,
      indicatorColor: context.primaryWash,
      selectedIconTheme: IconThemeData(color: context.primaryText),
      unselectedIconTheme: IconThemeData(color: context.textSecondary),
      selectedLabelTextStyle: TextStyle(color: context.primaryText, fontWeight: FontWeight.w700, fontSize: 13),
      unselectedLabelTextStyle: TextStyle(color: context.textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(top: 8, bottom: 12),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.tertiaryColor, borderRadius: BorderRadius.circular(12)),
              child: Text(
                context.tr('app_name').characters.first,
                style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 18),
            FloatingActionButton(
              heroTag: null,
              tooltip: context.tr('home_create_event'),
              onPressed: onCreate,
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
              child: const Icon(Icons.add_rounded, size: 28),
            ),
          ],
        ),
      ),
      destinations: [
        for (final tab in ShellTab.values)
          NavigationRailDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.selectedIcon),
            label: Text(context.tr(tab.labelKey)),
          ),
      ],
    );
  }
}
