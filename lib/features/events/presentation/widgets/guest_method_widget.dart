import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/event_models.dart' hide GuestInfo;
import '../screens/create_event_screen.dart';

class GuestMethodWidget extends StatelessWidget {
  final int packageLimit;
  final GuestMethod? guestMethod;
  final List<MutableGuestInfo> manualGuests;
  final MutableGuestInfo currentGuest;
  final File? excelFile;
  final Function(GuestMethod) onGuestMethodSelected;
  final VoidCallback onAddGuest;
  final Function(int) onRemoveGuest;
  final Function(MutableGuestInfo) onCurrentGuestChanged;
  final Function(File?) onExcelFileSelected;

  const GuestMethodWidget({
    super.key,
    required this.packageLimit,
    required this.guestMethod,
    required this.manualGuests,
    required this.currentGuest,
    required this.excelFile,
    required this.onGuestMethodSelected,
    required this.onAddGuest,
    required this.onRemoveGuest,
    required this.onCurrentGuestChanged,
    required this.onExcelFileSelected,
  });

  int get _currentGuestCount => manualGuests.length;
  int get _remainingSlots => packageLimit == -1 ? -1 : packageLimit - _currentGuestCount;
  bool get _isUnlimited => packageLimit == -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Guests',
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Package Limit',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.gray500,
                  ),
                ),
                Text(
                  '$_currentGuestCount / ${_isUnlimited ? '∞' : packageLimit}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Progress bar for package limit
        if (!_isUnlimited)
          Container(
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Guest Capacity',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray600,
                      ),
                    ),
                    Text(
                      '${_remainingSlots < 0 ? 0 : _remainingSlots} slots remaining',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.w),
                  child: LinearProgressIndicator(
                    value: (_currentGuestCount / packageLimit).clamp(0.0, 1.0),
                    backgroundColor: AppColors.gray200,
                    valueColor: AlwaysStoppedAnimation(
                      _currentGuestCount >= packageLimit
                          ? AppColors.red500
                          : AppColors.primaryColor,
                    ),
                    minHeight: 8.h,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 16.h),

        // Guest method label
        Text(
          'How would you like to add guests?',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: 12.h),

        // Method cards
        _GuestMethodCard(
          icon: Icons.message_outlined,
          title: 'Reach Them Directly',
          subtitle: 'Send invites via WhatsApp, Email & SMS',
          gradientColors: [AppColors.blue600, AppColors.cyan600],
          isSelected: guestMethod == GuestMethod.invite,
          onTap: () => onGuestMethodSelected(GuestMethod.invite),
        ),
        SizedBox(height: 12.h),
        _GuestMethodCard(
          icon: Icons.table_chart_outlined,
          title: 'Upload Excel File',
          subtitle: 'Import guest list from spreadsheet',
          gradientColors: [AppColors.green600, AppColors.emerald600],
          isSelected: guestMethod == GuestMethod.excel,
          onTap: () => onGuestMethodSelected(GuestMethod.excel),
        ),
        SizedBox(height: 12.h),
        _GuestMethodCard(
          icon: Icons.person_add_outlined,
          title: 'Add One by One',
          subtitle: "Manually enter each guest's details",
          gradientColors: [AppColors.primaryColor, AppColors.tertiaryColor],
          isSelected: guestMethod == GuestMethod.manual,
          onTap: () => onGuestMethodSelected(GuestMethod.manual),
        ),
        SizedBox(height: 16.h),

        // Method-specific content
        if (guestMethod == GuestMethod.invite)
          _InviteMethodContent(),
        if (guestMethod == GuestMethod.excel)
          _ExcelMethodContent(
            excelFile: excelFile,
            onFileSelected: onExcelFileSelected,
          ),
        if (guestMethod == GuestMethod.manual)
          _ManualMethodContent(
            manualGuests: manualGuests,
            currentGuest: currentGuest,
            onAddGuest: onAddGuest,
            onRemoveGuest: onRemoveGuest,
            onCurrentGuestChanged: onCurrentGuestChanged,
          ),
      ],
    );
  }
}

class _GuestMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final bool isSelected;
  final VoidCallback onTap;

  const _GuestMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(19.w),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? gradientColors.first.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : gradientColors.first.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11.w),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : gradientColors.first,
                size: 23.w,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 23.w,
                height: 23.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 13.w,
                  color: gradientColors.first,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InviteMethodContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(19.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue50, AppColors.cyan50],
        ),
        borderRadius: BorderRadius.circular(15.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.message_outlined,
            size: 45.w,
            color: AppColors.blue600,
          ),
          SizedBox(height: 12.h),
          Text(
            'Invite Guests Directly',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "We'll help you reach out to your guests through multiple channels after event creation.",
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExcelMethodContent extends StatelessWidget {
  final File? excelFile;
  final Function(File?) onFileSelected;

  const _ExcelMethodContent({
    required this.excelFile,
    required this.onFileSelected,
  });

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result != null && result.files.single.path != null) {
      onFileSelected(File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(19.w),
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
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.upload_file,
                size: 15.w,
                color: AppColors.gray700,
              ),
              SizedBox(width: 8.w),
              Text(
                'Upload Guest List',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(23.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.gray300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(11.w),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.table_chart_outlined,
                    size: 38.w,
                    color: AppColors.gray400,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    excelFile != null
                        ? excelFile!.path.split('/').last
                        : 'Click to upload Excel file',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '.xlsx or .xls format',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (excelFile != null) ...[
            SizedBox(height: 12.h),
            Text(
              '✓ File uploaded successfully',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.green600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ManualMethodContent extends StatefulWidget {
  final List<MutableGuestInfo> manualGuests;
  final MutableGuestInfo currentGuest;
  final VoidCallback onAddGuest;
  final Function(int) onRemoveGuest;
  final Function(MutableGuestInfo) onCurrentGuestChanged;

  const _ManualMethodContent({
    required this.manualGuests,
    required this.currentGuest,
    required this.onAddGuest,
    required this.onRemoveGuest,
    required this.onCurrentGuestChanged,
  });

  @override
  State<_ManualMethodContent> createState() => _ManualMethodContentState();
}

class _ManualMethodContentState extends State<_ManualMethodContent> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentGuest.name);
    _emailController = TextEditingController(text: widget.currentGuest.email);
    _phoneController = TextEditingController(text: widget.currentGuest.phone);
  }

  @override
  void didUpdateWidget(_ManualMethodContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentGuest.name != _nameController.text) {
      _nameController.text = widget.currentGuest.name;
    }
    if (widget.currentGuest.email != _emailController.text) {
      _emailController.text = widget.currentGuest.email;
    }
    if (widget.currentGuest.phone != _phoneController.text) {
      _phoneController.text = widget.currentGuest.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateGuest() {
    widget.onCurrentGuestChanged(MutableGuestInfo(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = widget.currentGuest.isValid;

    return Container(
      padding: EdgeInsets.all(19.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_add_outlined,
                size: 15.w,
                color: AppColors.gray700,
              ),
              SizedBox(width: 8.w),
              Text(
                'Add Guest Details',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            context: context,
            controller: _nameController,
            hint: 'Full Name',
            onChanged: (_) => _updateGuest(),
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            context: context,
            controller: _emailController,
            hint: 'Email Address',
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _updateGuest(),
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            context: context,
            controller: _phoneController,
            hint: 'Phone Number',
            keyboardType: TextInputType.phone,
            onChanged: (_) => _updateGuest(),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: canAdd
                ? () {
                    widget.onAddGuest();
                    _nameController.clear();
                    _emailController.clear();
                    _phoneController.clear();
                  }
                : null,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              decoration: BoxDecoration(
                gradient: canAdd
                    ? LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                      )
                    : null,
                color: canAdd ? null : AppColors.gray200,
                borderRadius: BorderRadius.circular(15.w),
                boxShadow: canAdd
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: canAdd ? Colors.white : AppColors.gray400,
                    size: 19.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Add Guest',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: canAdd ? Colors.white : AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Guest List
          if (widget.manualGuests.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Divider(color: AppColors.gray100),
            SizedBox(height: 16.h),
            Text(
              'Added Guests (${widget.manualGuests.length})',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            SizedBox(height: 12.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 203.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.manualGuests.length,
                itemBuilder: (context, index) {
                  final guest = widget.manualGuests[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(11.w),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(11.w),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guest.name,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray900,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                guest.email,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.gray600,
                                ),
                              ),
                              Text(
                                guest.phone,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => widget.onRemoveGuest(index),
                          child: Container(
                            width: 23.w,
                            height: 23.w,
                            decoration: BoxDecoration(
                              color: AppColors.red500.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 11.w,
                              color: AppColors.red500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
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
      style: TextStyle(fontSize: 13.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp),
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
    );
  }
}
