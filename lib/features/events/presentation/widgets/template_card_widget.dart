import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
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
            fontSize: context.dynamicWidth(0.05),
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.02)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: context.dynamicWidth(0.03),
            mainAxisSpacing: context.dynamicWidth(0.03),
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
        SizedBox(height: context.dynamicHeight(0.015)),
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
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: template.gradientColors,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? template.gradientColors.first.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
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
                  style: TextStyle(fontSize: context.dynamicWidth(0.09)),
                ),
                SizedBox(height: context.dynamicHeight(0.015)),
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.033),
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.gray900,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: -context.dynamicWidth(0.01),
                right: -context.dynamicWidth(0.01),
                child: Container(
                  width: context.dynamicWidth(0.06),
                  height: context.dynamicWidth(0.06),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    size: context.dynamicWidth(0.035),
                    color: AppColors.purple600,
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
        padding: EdgeInsets.all(context.dynamicWidth(0.05)),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.purple600, AppColors.pink600],
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          border: isActive
              ? null
              : Border.all(color: AppColors.purple500.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.purple600.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isActive ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.star,
              color: isActive ? Colors.white : AppColors.purple600,
              size: context.dynamicWidth(0.07),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              'Request Custom Template',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.038),
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppColors.gray900,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.005)),
            Text(
              'Our team will create a unique design for you',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.03),
                color: isActive
                    ? Colors.white.withOpacity(0.8)
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
