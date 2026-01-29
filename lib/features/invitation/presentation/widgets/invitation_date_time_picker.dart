import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Combined date and time picker row for invitation creation.
class InvitationDateTimePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const InvitationDateTimePicker({
    super.key,
    this.selectedDate,
    this.selectedTime,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DatePickerField(
            selectedDate: selectedDate,
            onTap: onDateTap,
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: _TimePickerField(
            selectedTime: selectedTime,
            onTap: onTimeTap,
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DatePickerField({
    this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate != null
        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
        : 'Select date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: context.dynamicWidth(0.021)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicWidth(0.035),
            ),
            decoration: BoxDecoration(
              color: context.overlayBg,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: context.iconSecondary,
                  size: context.dynamicWidth(0.051),
                ),
                SizedBox(width: context.dynamicWidth(0.029)),
                Expanded(
                  child: Text(
                    dateText,
                    style: TextStyle(
                      color: selectedDate != null
                          ? context.textPrimary
                          : context.iconDefault,
                      fontSize: context.dynamicWidth(0.037),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final VoidCallback onTap;

  const _TimePickerField({
    this.selectedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = selectedTime != null
        ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
        : 'Select time';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: context.dynamicWidth(0.021)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicWidth(0.035),
            ),
            decoration: BoxDecoration(
              color: context.overlayBg,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  color: context.iconSecondary,
                  size: context.dynamicWidth(0.051),
                ),
                SizedBox(width: context.dynamicWidth(0.029)),
                Expanded(
                  child: Text(
                    timeText,
                    style: TextStyle(
                      color: selectedTime != null
                          ? context.textPrimary
                          : context.iconDefault,
                      fontSize: context.dynamicWidth(0.037),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper class for themed date/time picker dialogs.
class InvitationPickerDialogs {
  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: context.textPrimary,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.primaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ctx.dynamicWidth(0.04)),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: ctx.dynamicWidth(0.04),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(ctx).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
        );
      },
    );
  }

  static Future<TimeOfDay?> pickTime(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: context.textPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ctx.dynamicWidth(0.029)),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ctx.dynamicWidth(0.029)),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ctx.dynamicWidth(0.04)),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: ctx.dynamicWidth(0.04),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(ctx).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
