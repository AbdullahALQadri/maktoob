import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
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
            crossAxisCount: 3,
            crossAxisSpacing: context.dynamicWidth(0.03),
            mainAxisSpacing: context.dynamicWidth(0.03),
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
        SizedBox(height: context.dynamicHeight(0.015)),
        _CustomEventTypeButton(
          isActive: showCustomEventType,
          onTap: onToggleCustomEventType,
        ),
        if (showCustomEventType) ...[
          SizedBox(height: context.dynamicHeight(0.015)),
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
        padding: EdgeInsets.all(context.dynamicWidth(0.03)),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: eventType.gradientColors,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? eventType.gradientColors.first.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
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
                  style: TextStyle(fontSize: context.dynamicWidth(0.07)),
                ),
                SizedBox(height: context.dynamicHeight(0.01)),
                Text(
                  eventType.name,
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.028),
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.gray900,
                  ),
                  textAlign: TextAlign.center,
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
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple50 : Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          border: Border.all(
            color: isActive ? AppColors.purple600 : AppColors.gray300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add,
              color: AppColors.purple600,
              size: context.dynamicWidth(0.06),
            ),
            SizedBox(height: context.dynamicHeight(0.005)),
            Text(
              'Add Custom Type',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
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
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        style: TextStyle(fontSize: context.dynamicWidth(0.04)),
        decoration: InputDecoration(
          hintText: 'Custom Event Type',
          hintStyle: TextStyle(fontSize: context.dynamicWidth(0.04)),
          filled: true,
          fillColor: AppColors.gray100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
            borderSide: BorderSide(color: AppColors.gray100, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
            borderSide: BorderSide(color: AppColors.gray100, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
            borderSide: BorderSide(color: AppColors.purple600, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.04),
            vertical: context.dynamicHeight(0.018),
          ),
        ),
      ),
    );
  }
}
