import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/guest_stats_card.dart';

/// Add Guests Screen with Smart Stats
class AddGuestsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const AddGuestsScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  State<AddGuestsScreen> createState() => _AddGuestsScreenState();
}

class _AddGuestsScreenState extends State<AddGuestsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: GestureDetector(
            onTap: () {
              context.read<InvitationCubit>().previousStep();
              widget.onBack?.call();
            },
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gray200,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.gray800,
                size: 21.w,
              ),
            ),
          ),
        ),
        title: Text(
          'Add Guests',
          style: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
            fontSize: 17.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<InvitationCubit, InvitationState>(
        builder: (context, state) {
          return Column(
            children: [
              // Smart Stats Dashboard
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                  vertical: 8.w,
                ),
                child: GuestStatsCard(
                  total: state.totalGuests,
                  confirmed: state.confirmedGuests,
                  declined: state.declinedGuests,
                  pending: state.pendingGuests,
                ),
              ),

              // Form and Guest List
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 23.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),

                      // Add guest form
                      Text(
                        'Add a Guest',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray800,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Name field
                      AppTextField(
                        controller: _nameController,
                        hintText: 'Guest name *',
                        prefixIcon: Icons.person_outline,
                        onChanged: (value) {
                          context
                              .read<InvitationCubit>()
                              .updateCurrentGuestName(value);
                        },
                      ),
                      SizedBox(height: 12.h),

                      // Phone field
                      AppTextField(
                        controller: _phoneController,
                        hintText: 'Phone number (optional)',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          context
                              .read<InvitationCubit>()
                              .updateCurrentGuestPhone(value);
                        },
                      ),
                      SizedBox(height: 12.h),

                      // Email field
                      AppTextField(
                        controller: _emailController,
                        hintText: 'Email (optional)',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          context
                              .read<InvitationCubit>()
                              .updateCurrentGuestEmail(value);
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Add button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _nameController.text.isNotEmpty
                              ? _addGuest
                              : null,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Guest'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            side: BorderSide(color: AppColors.primaryColor),
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(11.w),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Guest list header
                      if (state.guests.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Guest List (${state.guests.length})',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray800,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<InvitationCubit>().clearGuests();
                              },
                              child: Text(
                                'Clear All',
                                style: TextStyle(color: AppColors.red500),
                              ),
                            ),
                          ],
                        ),

                      // Guest list
                      ...state.guests.asMap().entries.map((entry) {
                        final index = entry.key;
                        final guest = entry.value;
                        return _buildGuestTile(context, guest, index);
                      }),

                      SizedBox(height: 81.h),
                    ],
                  ),
                ),
              ),

              // Bottom button with BackdropFilter
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.gray200.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Skip option
                          if (state.guests.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text(
                                'You can add guests later',
                                style: TextStyle(
                                  color: AppColors.gray500,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              text: state.guests.isEmpty
                                  ? 'Skip for Now'
                                  : 'Continue to Share',
                              onPressed: () {
                                context.read<InvitationCubit>().nextStep();
                                widget.onContinue?.call();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGuestTile(BuildContext context, GuestInfoModel guest, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 9.w),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(11.w),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.tertiaryColor],
              ),
              borderRadius: BorderRadius.circular(9.w),
            ),
            child: Center(
              child: Text(
                guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 11.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.gray800,
                  ),
                ),
                if (guest.phone.isNotEmpty)
                  Text(
                    guest.phone,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.gray500,
                    ),
                  ),
              ],
            ),
          ),

          // Status badge
          _buildStatusBadge(context, guest.status),

          // Delete button
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.gray400,
              size: 19.w,
            ),
            onPressed: () {
              context.read<InvitationCubit>().removeGuest(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, GuestStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case GuestStatus.confirmed:
        bgColor = AppColors.green600.withValues(alpha: 0.1);
        textColor = AppColors.green600;
        text = 'Confirmed';
        break;
      case GuestStatus.declined:
        bgColor = AppColors.red500.withValues(alpha: 0.1);
        textColor = AppColors.red500;
        text = 'Declined';
        break;
      case GuestStatus.pending:
        bgColor = AppColors.amber500.withValues(alpha: 0.1);
        textColor = AppColors.amber600;
        text = 'Pending';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 4.w,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _addGuest() {
    if (_nameController.text.isEmpty) return;

    final guest = GuestInfoModel(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
    );

    context.read<InvitationCubit>().addGuestDirect(guest);

    // Clear fields
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
  }
}
