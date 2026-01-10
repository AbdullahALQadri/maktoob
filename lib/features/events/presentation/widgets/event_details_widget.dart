import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/models/event_models.dart';

class EventDetailsWidget extends StatefulWidget {
  final EventDetails eventDetails;
  final Function(EventDetails) onDetailsChanged;

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

  void _updateDetails(EventDetails Function(EventDetails) update) {
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
              primary: AppColors.purple600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _updateDetails((d) {
        if (isDeadline) {
          return EventDetails(
            name: d.name,
            date: d.date,
            time: d.time,
            responseDeadline: picked,
            maxCompanions: d.maxCompanions,
            allowCompanions: d.allowCompanions,
          );
        } else {
          return EventDetails(
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
              primary: AppColors.purple600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _updateDetails((d) => EventDetails(
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Name
              _buildLabel('Event Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'Enter event name',
                onChanged: (v) => _updateDetails((d) => EventDetails(
                  name: v,
                  date: d.date,
                  time: d.time,
                  responseDeadline: d.responseDeadline,
                  maxCompanions: d.maxCompanions,
                  allowCompanions: d.allowCompanions,
                )),
              ),
              const SizedBox(height: 16),

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Date'),
                        const SizedBox(height: 8),
                        _buildDateButton(
                          _formatDate(widget.eventDetails.date),
                          () => _selectDate(context, false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Time'),
                        const SizedBox(height: 8),
                        _buildDateButton(
                          _formatTime(widget.eventDetails.time),
                          () => _selectTime(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Response Deadline
              _buildLabel('Response Deadline'),
              const SizedBox(height: 8),
              _buildDateButton(
                _formatDate(widget.eventDetails.responseDeadline),
                () => _selectDate(context, true),
              ),
              const SizedBox(height: 16),

              // Companions Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.purple50,
                  borderRadius: BorderRadius.circular(12),
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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Guests can bring +1',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _updateDetails((d) => EventDetails(
                            name: d.name,
                            date: d.date,
                            time: d.time,
                            responseDeadline: d.responseDeadline,
                            maxCompanions: d.maxCompanions,
                            allowCompanions: !d.allowCompanions,
                          )),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            height: 32,
                            decoration: BoxDecoration(
                              color: widget.eventDetails.allowCompanions
                                  ? AppColors.purple600
                                  : AppColors.gray300,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: widget.eventDetails.allowCompanions
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
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
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _maxCompanionsController,
                        hint: 'Max companions',
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final value = int.tryParse(v) ?? 2;
                          _updateDetails((d) => EventDetails(
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.gray700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }

  Widget _buildDateButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray100, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: text.startsWith('Select') ? AppColors.gray400 : AppColors.gray900,
          ),
        ),
      ),
    );
  }
}
