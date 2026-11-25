import 'package:flutter/material.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';

/// What sits over the bottom of the map: what to do, a problem, the place
/// that was tapped and the button that confirms it.
class MapPickerPanel extends StatelessWidget {
  const MapPickerPanel({
    super.key,
    required this.hasSelection,
    required this.isLoading,
    required this.address,
    required this.errorMessage,
    required this.onConfirm,
  });

  final bool hasSelection;

  /// The address of the tapped point is still being looked up.
  final bool isLoading;
  final String? address;
  final String? errorMessage;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.red100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.red500),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.red500),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage!, style: const TextStyle(color: AppColors.red500))),
              ],
            ),
          ),
        if (!hasSelection)
          _Card(
            child: Row(
              children: [
                const Icon(Icons.touch_app, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('map_tap_instruction'),
                    style: TextStyle(fontSize: 14, color: context.textPrimary),
                  ),
                ),
              ],
            ),
          )
        else ...[
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('map_selected_location'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isLoading)
                  const Center(child: SizedBox(width: 20, height: 20, child: MkSpinner(strokeWidth: 2)))
                else
                  Text(address ?? '', style: TextStyle(fontSize: 13, color: context.textTertiary)),
              ],
            ),
          ),
          if (!isLoading) ...[
            const SizedBox(height: 12),
            PrimaryButton(text: context.tr('map_confirm_location'), onPressed: onConfirm, width: double.infinity),
          ],
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: child,
    );
  }
}
