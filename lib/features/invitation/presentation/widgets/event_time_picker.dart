import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';

/// Time picker widget for event details.
class EventTimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;

  const EventTimePicker({super.key, this.selectedTime});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.018),
        ),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time,
                color: AppColors.gray500, size: context.dynamicWidth(0.051)),
            SizedBox(width: context.dynamicWidth(0.029)),
            Expanded(
              child: Text(
                selectedTime != null
                    ? _formatTime(selectedTime!)
                    : l?.translate('invitation_select_time') ?? 'Select time',
                style: TextStyle(
                  color:
                      selectedTime != null ? AppColors.gray800 : AppColors.gray400,
                  fontSize: context.dynamicWidth(0.037),
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray800,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: context.dynamicWidth(0.04),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && context.mounted) {
      context.read<InvitationCubit>().updateTime(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
