import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
        const SizedBox(height: 12),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: template.gradientColors,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.gray900,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 24,
                  height: 24,
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
                    size: 14,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.purple600, AppColors.pink600],
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              'Request Custom Template',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Our team will create a unique design for you',
              style: TextStyle(
                fontSize: 12,
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
