import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/event_models.dart';

class TemplateSelectionWidget extends StatelessWidget {
  final List<TemplateModel> templates;
  final String? selectedTemplate;
  final bool requestCustomTemplate;
  final Function(String) onTemplateSelected;
  final VoidCallback onToggleCustomTemplate;

  const TemplateSelectionWidget({
    super.key,
    required this.templates,
    required this.selectedTemplate,
    required this.requestCustomTemplate,
    required this.onTemplateSelected,
    required this.onToggleCustomTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Template',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 11.w,
            mainAxisSpacing: 11.w,
            childAspectRatio: 1.1,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            final isSelected = selectedTemplate == template.id;
            return _TemplateCard(
              template: template,
              isSelected: isSelected,
              onTap: () => onTemplateSelected(template.id),
            );
          },
        ),
        SizedBox(height: 12.h),
        _CustomTemplateButton(
          isActive: requestCustomTemplate,
          onTap: onToggleCustomTemplate,
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final TemplateModel template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: template.gradientColors,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? template.gradientColors.first.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.preview,
                  style: TextStyle(fontSize: 34.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.gray900,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: -4.w,
                right: -4.w,
                child: Container(
                  width: 23.w,
                  height: 23.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    size: 13.w,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomTemplateButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CustomTemplateButton({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(19.w),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          border: isActive
              ? null
              : Border.all(color: AppColors.purple500.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.primaryColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isActive ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.star,
              color: isActive ? Colors.white : AppColors.primaryColor,
              size: 26.w,
            ),
            SizedBox(height: 8.h),
            Text(
              'Request Custom Template',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppColors.gray900,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Our team will create a unique design for you',
              style: TextStyle(
                fontSize: 11.sp,
                color: isActive
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
