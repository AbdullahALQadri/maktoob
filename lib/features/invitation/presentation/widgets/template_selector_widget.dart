import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../data/models/invitation_draft_model.dart';

/// Horizontal scrollable template selector
class TemplateSelectorWidget extends StatelessWidget {
  final String? selectedTemplateId;
  final Function(String) onTemplateSelected;

  const TemplateSelectorWidget({
    super.key,
    this.selectedTemplateId,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final templates = InvitationTemplateModel.templates;

    return SizedBox(
      height: screenWidth * 0.28,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          final isSelected = selectedTemplateId == template.id;

          return Padding(
            padding: EdgeInsets.only(
              right: screenWidth * 0.03,
            ),
            child: GestureDetector(
              onTap: () => onTemplateSelected(template.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: screenWidth * 0.22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: template.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.primaryColor,
                          width: 3,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: template.gradientColors.first.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Stack(
                  children: [
                    // Template preview
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            template.preview,
                            style: TextStyle(fontSize: screenWidth * 0.08),
                          ),
                          SizedBox(height: screenWidth * 0.015),
                          Text(
                            template.name,
                            style: TextStyle(
                              fontSize: screenWidth * 0.028,
                              color: _getTextColor(template.id),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Selection indicator
                    if (isSelected)
                      Positioned(
                        top: screenWidth * 0.02,
                        right: screenWidth * 0.02,
                        child: Container(
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: screenWidth * 0.03,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getTextColor(String templateId) {
    switch (templateId) {
      case 'classic_white':
        return AppColors.gray800;
      default:
        return Colors.white;
    }
  }
}
