import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
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
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
        const SizedBox(height: 12),
        _CustomEventTypeButton(
          isActive: showCustomEventType,
          onTap: onToggleCustomEventType,
        ),
        if (showCustomEventType) ...[
          const SizedBox(height: 12),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: eventType.gradientColors,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  eventType.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.gray900,
                  ),
                  textAlign: TextAlign.center,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Custom Type',
              style: TextStyle(
                fontSize: 14,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        decoration: InputDecoration(
          hintText: 'Custom Event Type',
          filled: true,
          fillColor: AppColors.gray100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gray100, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gray100, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.purple600, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
