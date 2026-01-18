import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.gray800),
          onPressed: () {
            context.read<InvitationCubit>().previousStep();
            widget.onBack?.call();
          },
        ),
        title: Text(
          'Add Guests',
          style: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
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
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.02,
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
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.02),

                      // Add guest form
                      Text(
                        'Add a Guest',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray800,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),

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
                      SizedBox(height: screenHeight * 0.015),

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
                      SizedBox(height: screenHeight * 0.015),

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
                      SizedBox(height: screenHeight * 0.02),

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
                            foregroundColor: AppColors.purple600,
                            side: BorderSide(color: AppColors.purple600),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Guest list header
                      if (state.guests.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Guest List (${state.guests.length})',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
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
                        return _buildGuestTile(guest, index, screenWidth);
                      }),

                      SizedBox(height: screenHeight * 0.1),
                    ],
                  ),
                ),
              ),

              // Bottom button
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Skip option
                      if (state.guests.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                          child: Text(
                            'You can add guests later',
                            style: TextStyle(
                              color: AppColors.gray500,
                              fontSize: screenWidth * 0.035,
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildGuestTile(
      GuestInfoModel guest, int index, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.025),
      padding: EdgeInsets.all(screenWidth * 0.035),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purple600, AppColors.pink600],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.025),
            ),
            child: Center(
              child: Text(
                guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.038,
                    color: AppColors.gray800,
                  ),
                ),
                if (guest.phone.isNotEmpty)
                  Text(
                    guest.phone,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      color: AppColors.gray500,
                    ),
                  ),
              ],
            ),
          ),

          // Status badge
          _buildStatusBadge(guest.status, screenWidth),

          // Delete button
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.gray400,
              size: screenWidth * 0.05,
            ),
            onPressed: () {
              context.read<InvitationCubit>().removeGuest(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(GuestStatus status, double screenWidth) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case GuestStatus.confirmed:
        bgColor = AppColors.green600.withOpacity(0.1);
        textColor = AppColors.green600;
        text = 'Confirmed';
        break;
      case GuestStatus.declined:
        bgColor = AppColors.red500.withOpacity(0.1);
        textColor = AppColors.red500;
        text = 'Declined';
        break;
      case GuestStatus.pending:
        bgColor = AppColors.amber500.withOpacity(0.1);
        textColor = AppColors.amber600;
        text = 'Pending';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: screenWidth * 0.028,
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
