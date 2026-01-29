import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/event_type_card.dart';

/// Event Type Selection Screen
/// "What's the occasion?"
class EventTypeScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const EventTypeScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.height;
    final screenWidth = context.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              context.read<InvitationCubit>().previousStep();
              onBack?.call();
            },
            child: Container(
              width: 40,
              height: 40,
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
                size: 22,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "What's the occasion?",
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Choose the type of event you want to create',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: context.iconSecondary,
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Event type grid
              Expanded(
                child: BlocBuilder<InvitationCubit, InvitationState>(
                  builder: (context, state) {
                    return GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: screenWidth * 0.04,
                      crossAxisSpacing: screenWidth * 0.04,
                      childAspectRatio: 1.1,
                      children: GoldenEventType.values.map((type) {
                        return EventTypeCard(
                          eventType: type,
                          isSelected: state.eventType == type,
                          onTap: () {
                            context.read<InvitationCubit>().selectEventTypeFromGolden(type);
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              // Continue button
              BlocBuilder<InvitationCubit, InvitationState>(
                builder: (context, state) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                    child: SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Continue',
                        onPressed: state.canProceedFromEventType
                            ? () {
                                context.read<InvitationCubit>().nextStep();
                                onContinue?.call();
                              }
                            : null,
                        isDisabled: !state.canProceedFromEventType,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
