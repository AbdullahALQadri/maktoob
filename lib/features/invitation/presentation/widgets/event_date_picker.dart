import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';

/// Date picker widget for event details.
class EventDatePicker extends StatelessWidget {
  final DateTime? selectedDate;

  const EventDatePicker({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => _selectDate(context),
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
            Icon(Icons.calendar_today,
                color: AppColors.gray500, size: context.dynamicWidth(0.051)),
            SizedBox(width: context.dynamicWidth(0.029)),
            Expanded(
              child: Text(
                selectedDate != null
                    ? _formatDate(selectedDate!)
                    : l?.translate('invitation_select_date') ?? 'Select date',
                style: TextStyle(
                  color:
                      selectedDate != null ? AppColors.gray800 : AppColors.gray400,
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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray800,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.primaryColor,
              headerForegroundColor: Colors.white,
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
      context.read<InvitationCubit>().updateDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
