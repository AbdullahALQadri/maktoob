import 'package:flutter/material.dart';

import '../../../config/locale/l10n_context.dart';
import '../../utils/app_colors.dart';

/// "Offline · showing the last saved copy": shown above a screen whose data
/// came from the offline cache, so the host knows it may be out of date.
class SavedCopyNote extends StatelessWidget {
  const SavedCopyNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: context.chipBg, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, size: 18, color: context.textTertiary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr('offline_saved_copy'),
                style: TextStyle(fontSize: 13, color: context.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
