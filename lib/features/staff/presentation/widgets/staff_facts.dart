import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';

/// A labelled fact of a review; nothing is drawn when the value is empty.
class StaffFact extends StatelessWidget {
  const StaffFact(this.labelKey, this.value, {super.key, this.ltr = false});

  final String labelKey;
  final String? value;

  /// Numbers and Latin text read left to right in any language.
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr(labelKey), style: TextStyle(fontSize: 12.5, color: context.textSecondary)),
          const SizedBox(height: 2),
          Text(
            text,
            textDirection: ltr ? TextDirection.ltr : null,
            style: TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w600, color: context.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// A warning staff must read before deciding.
class StaffWarning extends StatelessWidget {
  const StaffWarning(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: AppColors.amber50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.amber700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.amber700)),
          ),
        ],
      ),
    );
  }
}

/// A button that opens one private file of the review.
class StaffFileButton extends StatelessWidget {
  const StaffFileButton({super.key, required this.label, required this.onOpen, this.icon = Icons.image_outlined});

  final String label;
  final VoidCallback onOpen;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: onOpen,
        icon: Icon(icon, size: 18),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
    );
  }
}
