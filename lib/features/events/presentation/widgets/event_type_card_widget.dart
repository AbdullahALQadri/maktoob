import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/event_models.dart';

class EventTypeSelectionWidget extends StatelessWidget {
  final List<EventTypeModel> eventTypes;
  final String? selectedEventType;
  final bool showCustomEventType;
  final String customEventType;
  final Function(String) onEventTypeSelected;
  final VoidCallback onToggleCustomEventType;
  final Function(String) onCustomEventTypeChanged;

  const EventTypeSelectionWidget({
    super.key,
    required this.eventTypes,
    required this.selectedEventType,
    required this.showCustomEventType,
    required this.customEventType,
    required this.onEventTypeSelected,
    required this.onToggleCustomEventType,
    required this.onCustomEventTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Type',
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
            crossAxisCount: 3,
            crossAxisSpacing: 11.w,
            mainAxisSpacing: 11.w,
            childAspectRatio: 0.9,
          ),
          itemCount: eventTypes.length,
          itemBuilder: (context, index) {
            final type = eventTypes[index];
            final isSelected = selectedEventType == type.id;
            return _EventTypeCard(
              eventType: type,
              isSelected: isSelected,
              onTap: () => onEventTypeSelected(type.id),
            );
          },
        ),
        SizedBox(height: 12.h),
        _CustomEventTypeButton(
          isActive: showCustomEventType,
          onTap: onToggleCustomEventType,
        ),
        if (showCustomEventType) ...[
          SizedBox(height: 12.h),
          _CustomEventTypeForm(
            value: customEventType,
            onChanged: onCustomEventTypeChanged,
          ),
        ],
      ],
    );
  }
}

class _EventTypeCard extends StatelessWidget {
  final EventTypeModel eventType;
  final bool isSelected;
  final VoidCallback onTap;

  const _EventTypeCard({
    required this.eventType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(11.w),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: eventType.gradientColors,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? eventType.gradientColors.first.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  eventType.icon,
                  style: TextStyle(fontSize: 26.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  eventType.name,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.gray900,
                  ),
                  textAlign: TextAlign.center,
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

class _CustomEventTypeButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CustomEventTypeButton({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple50 : Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          border: Border.all(
            color: isActive ? AppColors.primaryColor : AppColors.gray300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add,
              color: AppColors.primaryColor,
              size: 23.w,
            ),
            SizedBox(height: 4.h),
            Text(
              'Add Custom Type',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomEventTypeForm extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const _CustomEventTypeForm({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        style: TextStyle(fontSize: 15.sp),
        decoration: InputDecoration(
          hintText: 'Custom Event Type',
          hintStyle: TextStyle(fontSize: 15.sp),
          filled: true,
          fillColor: AppColors.gray100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11.w),
            borderSide: BorderSide(color: AppColors.gray100, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11.w),
            borderSide: BorderSide(color: AppColors.gray100, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11.w),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 15.h,
          ),
        ),
      ),
    );
  }
}
