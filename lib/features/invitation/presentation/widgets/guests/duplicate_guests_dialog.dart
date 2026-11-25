import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../cubit/invitation_cubit.dart';

/// Tells the host which repeated numbers were dropped from the list.
void showDuplicateGuestsDialog(BuildContext context, Set<String> duplicates) {
  if (duplicates.isEmpty) return;
  final cubit = context.read<InvitationCubit>();

  showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.orange500),
          const SizedBox(width: 8),
          Expanded(child: Text(context.tr('invitation_duplicates_found'))),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('invitation_duplicates_removed'), style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final phone in duplicates)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, size: 16),
                          const SizedBox(width: 8),
                          Text(phone, textDirection: TextDirection.ltr),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialog).pop();
            cubit.clearDuplicateNotification();
          },
          child: Text(context.tr('common_ok')),
        ),
      ],
    ),
  );
}
