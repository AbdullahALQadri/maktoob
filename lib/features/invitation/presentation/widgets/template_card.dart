import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../cubit/invitation_state.dart';

/// Template card widget for displaying template options in a grid.
class TemplateCard extends StatelessWidget {
  final TemplateModel template;
  final bool isSelected;
  final File? uploadedFile;
  final bool isEnglish;
  final VoidCallback onTap;

  const TemplateCard({
    super.key,
    required this.template,
    required this.isSelected,
    this.uploadedFile,
    this.isEnglish = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            _buildPreview(context),
            _buildNameOverlay(context),
            if (template.hasExtraFee) _buildExtraFeeBadge(context),
            if (isSelected) _buildSelectionIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        child: template.isCustom
            ? _buildCustomPlaceholder(context)
            : _buildTemplatePreview(context),
      ),
    );
  }

  Widget _buildCustomPlaceholder(BuildContext context) {
    if (uploadedFile != null) {
      return Image.file(uploadedFile!, fit: BoxFit.cover);
    }

    return Container(
      color: context.overlayBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file,
              size: context.dynamicWidth(0.08), color: context.iconDefault),
          SizedBox(height: context.dynamicHeight(0.01)),
          Text(
            isEnglish ? 'Upload your design' : 'ارفع تصميمك',
            style: TextStyle(
              color: context.iconSecondary,
              fontSize: context.dynamicWidth(0.029),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatePreview(BuildContext context) {
    if (template.previewUrl != null) {
      return Image.network(
        template.previewUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: context.overlayBg,
      child: Center(
        child: Icon(Icons.image,
            size: context.dynamicWidth(0.101), color: context.borderColor),
      ),
    );
  }

  Widget _buildNameOverlay(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.021),
          vertical: context.dynamicHeight(0.007),
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(context.dynamicWidth(0.029)),
            bottomRight: Radius.circular(context.dynamicWidth(0.029)),
          ),
        ),
        child: Text(
          template.isCustom
              ? (isEnglish ? 'Custom Template' : 'قالب مخصص')
              : (isEnglish ? template.name : template.nameAr),
          style: TextStyle(
            color: Colors.white,
            fontSize: context.dynamicWidth(0.029),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildExtraFeeBadge(BuildContext context) {
    return Positioned(
      top: context.dynamicWidth(0.021),
      left: context.dynamicWidth(0.021),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.016),
          vertical: context.dynamicHeight(0.002),
        ),
        decoration: BoxDecoration(
          color: AppColors.amber500,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_money,
                color: Colors.white, size: context.dynamicWidth(0.029)),
            Text(
              'رسوم',
              style: TextStyle(
                  color: Colors.white, fontSize: context.dynamicWidth(0.024)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(BuildContext context) {
    return Positioned(
      top: context.dynamicWidth(0.021),
      right: context.dynamicWidth(0.021),
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.005)),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: context.dynamicWidth(0.035),
        ),
      ),
    );
  }
}
