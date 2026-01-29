import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/extra_service_model.dart';

/// Summary bar showing selected services and total price.
class ServicesSummaryBar extends StatelessWidget {
  final List<ExtraServiceModel> selectedServices;
  final bool isEnglish;

  const ServicesSummaryBar({
    super.key,
    required this.selectedServices,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final totalPrice = selectedServices.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_cart,
            color: AppColors.primary,
            size: context.dynamicWidth(0.061),
          ),
          SizedBox(width: context.dynamicWidth(0.029)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l?.translate('invitation_selected_services') ?? 'Selected services'}: ${selectedServices.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.dynamicWidth(0.035),
                  ),
                ),
                Text(
                  selectedServices
                      .map((s) => isEnglish ? s.name : s.nameAr)
                      .join(isEnglish ? ', ' : ' ، '),
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.029),
                    color: context.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.029),
              vertical: context.dynamicHeight(0.01),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
            ),
            child: Text(
              '${totalPrice.toStringAsFixed(0)} ₪',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: context.dynamicWidth(0.035),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
