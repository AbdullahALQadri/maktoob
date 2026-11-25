import 'package:flutter/material.dart';

import '../../../../../core/utils/app_colors.dart';

/// A titled block of the settings step: a heading, a line under it, content.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.subtitle, required this.children});

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.textPrimary)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 13, height: 1.5, color: context.textSecondary)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

/// A flat, outlined row the host taps to choose or switch something.
class SettingsChoiceTile extends StatelessWidget {
  const SettingsChoiceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.hint,
    required this.selected,
    required this.onTap,
    this.isSwitch = false,
  });

  final IconData icon;
  final String title;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  /// A switch instead of a single-choice mark.
  final bool isSwitch;

  @override
  Widget build(BuildContext context) {
    final picked = selected && !isSwitch;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 10, 12),
          decoration: BoxDecoration(
            color: picked ? context.primaryWash : context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: picked ? AppColors.primaryColor : context.borderColor,
              width: picked ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: selected ? context.primaryText : context.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                    const SizedBox(height: 2),
                    Text(hint, style: TextStyle(fontSize: 12.5, height: 1.45, color: context.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isSwitch)
                ExcludeSemantics(child: Switch(value: selected, onChanged: (_) => onTap()))
              else
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 22,
                  color: selected ? AppColors.primaryColor : context.borderColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
