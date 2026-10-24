import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../locale/l10n_context.dart';
import 'shell_tab.dart';

/// Wide windows: the web portal's navy sidebar, with the create button
/// above the four places.
class ShellSidebar extends StatelessWidget {
  const ShellSidebar({super.key, required this.current, required this.onSelect, required this.onCreate});

  final ShellTab current;
  final ValueChanged<ShellTab> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      color: context.isDarkMode ? AppColors.darkBg : AppColors.tertiaryColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 22, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                child: Text(
                  context.tr('app_name'),
                  style: const TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.navy700, height: 1),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_rounded),
                label: Text(context.tr('home_create_event')),
              ),
              const SizedBox(height: 18),
              for (final tab in ShellTab.values)
                _SidebarItem(tab: tab, selected: tab == current, onTap: () => onSelect(tab)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.tab, required this.selected, required this.onTap});

  final ShellTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.white : AppColors.sidebarInk;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 4),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? AppColors.primaryColor.withValues(alpha: .18) : AppColors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 46),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(selected ? tab.selectedIcon : tab.icon, size: 20, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.tr(tab.labelKey),
                        style: TextStyle(
                          color: color,
                          fontSize: 15,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
