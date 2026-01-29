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
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(context.dynamicWidth(0.021)),
          child: GestureDetector(
            onTap: () {
              context.read<InvitationCubit>().previousStep();
              widget.onBack?.call();
            },
            child: Container(
              width: context.dynamicWidth(0.101),
              height: context.dynamicWidth(0.101),
              decoration: BoxDecoration(
                color: context.overlayBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.borderColor,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: context.textPrimary,
                size: context.dynamicWidth(0.056),
              ),
            ),
          ),
        ),
        title: Text(
          'Add Guests',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: context.dynamicWidth(0.045),
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
                  horizontal: context.dynamicWidth(0.04),
                  vertical: context.dynamicWidth(0.021),
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
                  padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.dynamicHeight(0.02)),

                      // Add guest form
                      Text(
                        'Add a Guest',
                        style: TextStyle(
                          fontSize: context.dynamicWidth(0.045),
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.015)),

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
                      SizedBox(height: context.dynamicHeight(0.015)),

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
                      SizedBox(height: context.dynamicHeight(0.015)),

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
                      SizedBox(height: context.dynamicHeight(0.02)),

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
                              vertical: context.dynamicHeight(0.015),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(context.dynamicWidth(0.029)),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: context.dynamicHeight(0.03)),

                      // Guest list header
                      if (state.guests.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Guest List (${state.guests.length})',
                              style: TextStyle(
                                fontSize: context.dynamicWidth(0.045),
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
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

                      SizedBox(height: context.dynamicHeight(0.1)),
                    ],
                  ),
                ),
              ),

              // Bottom button with BackdropFilter
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.all(context.dynamicWidth(0.04)),
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
                              padding: EdgeInsets.only(bottom: context.dynamicHeight(0.01)),
                              child: Text(
                                'You can add guests later',
                                style: TextStyle(
                                  color: context.iconSecondary,
                                  fontSize: context.dynamicWidth(0.035),
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
      margin: EdgeInsets.only(bottom: context.dynamicWidth(0.024)),
      padding: EdgeInsets.all(context.dynamicWidth(0.035)),
      decoration: BoxDecoration(
        color: context.themeSurface,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: context.dynamicWidth(0.101),
            height: context.dynamicWidth(0.101),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.tertiaryColor],
              ),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
            ),
            child: Center(
              child: Text(
                guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: context.dynamicWidth(0.045),
                ),
              ),
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.029)),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: context.dynamicWidth(0.037),
                    color: context.textPrimary,
                  ),
                ),
                if (guest.phone.isNotEmpty)
                  Text(
                    guest.phone,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.032),
                      color: context.iconSecondary,
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
              color: context.iconDefault,
              size: context.dynamicWidth(0.051),
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
        horizontal: context.dynamicWidth(0.024),
        vertical: context.dynamicWidth(0.011),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: context.dynamicWidth(0.029),
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

    // Close keyboard and reset form with new controllers
    FocusScope.of(context).unfocus();
    setState(() {
      _resetForm();
    });
  }
}
