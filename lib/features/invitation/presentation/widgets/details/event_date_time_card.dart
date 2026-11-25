import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/locale/app_localizations.dart';
import '../../../../../core/core.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';
import '../../widgets/widgets.dart';


class EventDateTimeCard extends StatelessWidget {
  final InvitationState state;
  const EventDateTimeCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l?.translate('wizard_event_datetime_label') ?? 'التاريخ والوقت',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          EventDateTimeField(
            label: l?.translate('wizard_event_start_label') ?? 'بداية الفعالية',
            hint: l?.translate('wizard_event_start_hint') ??
                'اختر تاريخ ووقت البداية',
            icon: Icons.event_repeat_rounded,
            iconActive: true,
            date: state.eventDate,
            time: state.eventTime,
            onPick: (d, t) {
              final cubit = context.read<InvitationCubit>();
              cubit.updateDate(d);
              cubit.updateTime(t);
            },
          ),
          // Business types only: an end time, maybe several days. Weddings and
          // family occasions have no end (the QR is valid all day).
          if (state.selectedEventType?.hasEndTime == true) ...[
            const SizedBox(height: AppSpacing.smd),
            EventEndFields(state: state),
          ],
        ],
      ),
    );
  }
}


class EventDateTimeField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool iconActive;
  final DateTime? date;
  final TimeOfDay? time;
  final void Function(DateTime, TimeOfDay) onPick;

  const EventDateTimeField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconActive,
    required this.date,
    required this.time,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode != 'en';
    final filled = date != null && time != null;
    final display = filled ? _format(date!, time!, isAr) : hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray500,
            ),
          ),
        ),
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: iconActive
                        ? AppColors.primaryColor
                        : AppColors.gray500,
                    size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    display,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
                      color:
                          filled ? context.textPrimary : AppColors.gray400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final initial =
        date ?? DateTime.now().add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateUtils.dateOnly(DateTime.now()), // backend: event_date after:today
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked == null || !context.mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: time ?? const TimeOfDay(hour: 20, minute: 0),
    );
    if (pickedTime == null) return;
    onPick(picked, pickedTime);
  }

  String _format(DateTime d, TimeOfDay t, bool isAr) {
    const monthsAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const monthsEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = (isAr ? monthsAr : monthsEn)[d.month - 1];
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final am = t.period == DayPeriod.am;
    final ampm = isAr ? (am ? 'ص' : 'م') : (am ? 'AM' : 'PM');
    final mm = t.minute.toString().padLeft(2, '0');
    return isAr
        ? '${d.day} $month ${d.year}، ${hour12.toString().padLeft(2, '0')}:$mm $ampm'
        : '${d.day} $month ${d.year}, ${hour12.toString().padLeft(2, '0')}:$mm $ampm';
  }
}
