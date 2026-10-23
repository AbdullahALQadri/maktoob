import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entities/template_preview_entity.dart';

/// A starter design thumbnail. Tapping it starts sign-up.
class TemplatePreviewTile extends StatelessWidget {
  final TemplatePreviewEntity template;
  final VoidCallback onTap;

  const TemplatePreviewTile({
    super.key,
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.themeSurface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: context.borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppImage.network(
                template.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
            if (template.title != null)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  template.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
