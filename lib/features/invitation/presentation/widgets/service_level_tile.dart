import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../data/models/extra_service_model.dart';

class ServiceLevelTile extends StatelessWidget {
  final ExtraServiceOptionModel option;
  final bool isEnglish;
  final VoidCallback onTap;

  const ServiceLevelTile({super.key, required this.option, required this.isEnglish, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final includes = isEnglish ? option.includes : option.includesAr;
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish ? option.name : option.nameAr,
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: context.textPrimary),
                  ),
                  for (final item in includes.take(3))
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: AppSpacing.xxs),
                      child: Text(
                        '✓ $item',
                        style: TextStyle(fontSize: 13, color: context.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.smd),
            Text(
              '${option.price.toStringAsFixed(0)} ₪',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
