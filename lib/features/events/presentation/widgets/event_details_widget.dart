import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
import '../screens/create_event_screen.dart';

class EventDetailsWidget extends StatefulWidget {
  final MutableEventDetails eventDetails;
  final Function(MutableEventDetails) onDetailsChanged;

  const EventDetailsWidget({
    super.key,
    required this.eventDetails,
    required this.onDetailsChanged,
  });

  @override
  State<EventDetailsWidget> createState() => _EventDetailsWidgetState();
}

class _EventDetailsWidgetState extends State<EventDetailsWidget> {
  late TextEditingController _nameController;
  late TextEditingController _maxCompanionsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.eventDetails.name);
    _maxCompanionsController = TextEditingController(
      text: widget.eventDetails.maxCompanions.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxCompanionsController.dispose();
    super.dispose();
  }

  void _updateDetails(MutableEventDetails Function(MutableEventDetails) update) {
    widget.onDetailsChanged(update(widget.eventDetails));
  }

  Future<void> _selectDate(BuildContext context, bool isDeadline) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
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
    if (picked != null) {
      _updateDetails((d) {
        if (isDeadline) {
          return MutableEventDetails(
            name: d.name,
            date: d.date,
            time: d.time,
            responseDeadline: picked,
            maxCompanions: d.maxCompanions,
            allowCompanions: d.allowCompanions,
          );
        } else {
          return MutableEventDetails(
            name: d.name,
            date: picked,
            time: d.time,
            responseDeadline: d.responseDeadline,
            maxCompanions: d.maxCompanions,
            allowCompanions: d.allowCompanions,
          );
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.eventDetails.time ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
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
    if (picked != null) {
      _updateDetails((d) => MutableEventDetails(
        name: d.name,
        date: d.date,
        time: picked,
        responseDeadline: d.responseDeadline,
        maxCompanions: d.maxCompanions,
        allowCompanions: d.allowCompanions,
      ));
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Details',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.05),
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.02)),
        Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.05)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Name
              _buildLabel(context, 'Event Name'),
              SizedBox(height: context.dynamicHeight(0.01)),
              _buildTextField(
                context: context,
                controller: _nameController,
                hint: 'Enter event name',
                onChanged: (v) => _updateDetails((d) => MutableEventDetails(
                  name: v,
                  date: d.date,
                  time: d.time,
                  responseDeadline: d.responseDeadline,
                  maxCompanions: d.maxCompanions,
                  allowCompanions: d.allowCompanions,
                )),
              ),
              SizedBox(height: context.dynamicHeight(0.02)),

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, 'Date'),
                        SizedBox(height: context.dynamicHeight(0.01)),
                        _buildDateButton(
                          context,
                          _formatDate(widget.eventDetails.date),
                          () => _selectDate(context, false),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.dynamicWidth(0.03)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, 'Time'),
                        SizedBox(height: context.dynamicHeight(0.01)),
                        _buildDateButton(
                          context,
                          _formatTime(widget.eventDetails.time),
                          () => _selectTime(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.dynamicHeight(0.02)),

              // Response Deadline
              _buildLabel(context, 'Response Deadline'),
              SizedBox(height: context.dynamicHeight(0.01)),
              _buildDateButton(
                context,
                _formatDate(widget.eventDetails.responseDeadline),
                () => _selectDate(context, true),
              ),
              SizedBox(height: context.dynamicHeight(0.02)),

              // Companions Toggle
              Container(
                padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                decoration: BoxDecoration(
                  color: AppColors.purple50,
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Allow Companions',
                              style: TextStyle(
                                fontSize: context.dynamicWidth(0.035),
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                            ),
                            SizedBox(height: context.dynamicHeight(0.003)),
                            Text(
                              'Guests can bring +1',
                              style: TextStyle(
                                fontSize: context.dynamicWidth(0.03),
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _updateDetails((d) => MutableEventDetails(
                            name: d.name,
                            date: d.date,
                            time: d.time,
                            responseDeadline: d.responseDeadline,
                            maxCompanions: d.maxCompanions,
                            allowCompanions: !d.allowCompanions,
                          )),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: context.dynamicWidth(0.14),
                            height: context.dynamicWidth(0.08),
                            decoration: BoxDecoration(
                              color: widget.eventDetails.allowCompanions
                                  ? AppColors.primaryColor
                                  : AppColors.gray300,
                              borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: widget.eventDetails.allowCompanions
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: context.dynamicWidth(0.06),
                                height: context.dynamicWidth(0.06),
                                margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.01)),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.eventDetails.allowCompanions) ...[
                      SizedBox(height: context.dynamicHeight(0.015)),
                      _buildTextField(
                        context: context,
                        controller: _maxCompanionsController,
                        hint: 'Max companions',
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final value = int.tryParse(v) ?? 2;
                          _updateDetails((d) => MutableEventDetails(
                            name: d.name,
                            date: d.date,
                            time: d.time,
                            responseDeadline: d.responseDeadline,
                            maxCompanions: value,
                            allowCompanions: d.allowCompanions,
                          ));
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.035),
        fontWeight: FontWeight.w600,
        color: AppColors.gray700,
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontSize: context.dynamicWidth(0.035)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: context.dynamicWidth(0.035)),
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
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.018),
        ),
      ),
    );
  }

  Widget _buildDateButton(BuildContext context, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.018),
        ),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          border: Border.all(color: AppColors.gray100, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.035),
            color: text.startsWith('Select') ? AppColors.gray400 : AppColors.gray900,
          ),
        ),
      ),
    );
  }
}
