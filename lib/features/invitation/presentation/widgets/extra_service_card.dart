import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../data/models/extra_service_model.dart';
import '../cubit/invitation_cubit.dart';

/// Card widget for displaying an extra service option.
class ExtraServiceCard extends StatelessWidget {
  final ExtraServiceModel service;
  final bool isSelected;
  final bool isEnglish;

  const ExtraServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<InvitationCubit>().toggleService(service),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: context.dynamicWidth(0.024),
              offset: Offset(0, context.dynamicHeight(0.005)),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildContent(context),
            if (isSelected) _buildSelectionIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIcon(context),
          SizedBox(height: context.dynamicHeight(0.015)),
          _buildPrimaryName(context),
          if (service.name != service.nameAr) ...[
            SizedBox(height: context.dynamicHeight(0.005)),
            _buildSecondaryName(context),
          ],
          const Spacer(),
          _buildPrice(context),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.141),
      height: context.dynamicWidth(0.141),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
      ),
      child: service.iconUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              child: Image.network(
                service.iconUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultIcon(context),
              ),
            )
          : _buildDefaultIcon(context),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Icon(
      Icons.room_service,
      size: context.dynamicWidth(0.069),
      color: isSelected ? AppColors.primary : Colors.grey.shade600,
    );
  }

  Widget _buildPrimaryName(BuildContext context) {
    return Text(
      isEnglish ? service.name : service.nameAr,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.035),
        fontWeight: FontWeight.bold,
        color: isSelected ? AppColors.primary : Colors.grey.shade800,
      ),
    );
  }

  Widget _buildSecondaryName(BuildContext context) {
    return Text(
      isEnglish ? service.nameAr : service.name,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.029),
        color: context.iconSecondary,
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.029),
        vertical: context.dynamicHeight(0.007),
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
      ),
      child: Text(
        '${service.price.toStringAsFixed(0)} ₪',
        style: TextStyle(
          fontSize: context.dynamicWidth(0.035),
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(BuildContext context) {
    return Positioned(
      top: context.dynamicWidth(0.021),
      right: context.dynamicWidth(0.021),
      child: Container(
        width: context.dynamicWidth(0.061),
        height: context.dynamicWidth(0.061),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: context.dynamicWidth(0.04),
        ),
      ),
    );
  }
}
