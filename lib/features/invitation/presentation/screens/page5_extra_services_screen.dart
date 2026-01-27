import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/extra_service_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/wizard_step_header.dart';

class Page5ExtraServicesScreen extends StatefulWidget {
  const Page5ExtraServicesScreen({super.key});

  @override
  State<Page5ExtraServicesScreen> createState() =>
      _Page5ExtraServicesScreenState();
}

class _Page5ExtraServicesScreenState extends State<Page5ExtraServicesScreen> {
  @override
  void initState() {
    super.initState();
    // Load services when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationCubit>().loadExtraServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Step Header
                WizardStepHeader(
                  currentStep: 5,
                  totalSteps: 7,
                  title: l?.translate('invitation_step5_title') ?? 'Extra Services',
                ),

                // Paid Services Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 10.h,
                  ),
                  color: Colors.amber.shade100,
                  child: Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber.shade800,
                        size: 19.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          l?.translate('invitation_paid_services_notice') ?? 'These are paid services that will be added to the final invoice',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _buildContent(context, state, l, isEnglish),
                ),

                // Selected Services Summary
                if (state.selectedServices.isNotEmpty)
                  _buildSelectedSummary(context, state, l, isEnglish),

                // Navigation Buttons
                _buildNavigationButtons(context, state, l),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, InvitationState state, AppLocalizations? l, bool isEnglish) {
    if (state.isLoadingServices) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              l?.translate('invitation_loading_services') ?? 'Loading services...',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (state.servicesError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(23.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60.w,
                color: Colors.red.shade300,
              ),
              SizedBox(height: 16.h),
              Text(
                l?.translate('invitation_services_error') ?? 'Error loading services',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                state.servicesError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 24.h),
              AppButton(
                text: l?.translate('common_retry') ?? 'Retry',
                onPressed: () {
                  context.read<InvitationCubit>().loadExtraServices();
                },
                width: 188.w,
              ),
            ],
          ),
        ),
      );
    }

    if (state.availableServices.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(23.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.room_service_outlined,
                size: 75.w,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                l?.translate('invitation_no_services') ?? 'No extra services available',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l?.translate('invitation_continue_next_step') ?? 'You can continue to the next step',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info text
          Text(
            l?.translate('invitation_select_services') ?? 'Select the extra services you want for your event',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 16.h),

          // Services Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 11.w,
              mainAxisSpacing: 11.w,
              childAspectRatio: 0.85,
            ),
            itemCount: state.availableServices.length,
            itemBuilder: (context, index) {
              final service = state.availableServices[index];
              final isSelected = state.selectedServices.contains(service);
              return _buildServiceCard(context, service, isSelected, isEnglish);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, ExtraServiceModel service, bool isSelected, bool isEnglish) {
    return GestureDetector(
      onTap: () {
        context.read<InvitationCubit>().toggleService(service);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 9.w,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: EdgeInsets.all(15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 53.w,
                    height: 53.w,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(11.w),
                    ),
                    child: service.iconUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(11.w),
                            child: Image.network(
                              service.iconUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.room_service,
                                size: 26.w,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade600,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.room_service,
                            size: 26.w,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade600,
                          ),
                  ),
                  SizedBox(height: 12.h),

                  // Primary Name (based on language)
                  Text(
                    isEnglish ? service.name : service.nameAr,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade800,
                    ),
                  ),

                  // Secondary Name if different
                  if (service.name != service.nameAr) ...[
                    SizedBox(height: 4.h),
                    Text(
                      isEnglish ? service.nameAr : service.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Price
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 11.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(19.w),
                    ),
                    child: Text(
                      '${service.price.toStringAsFixed(0)} ₪',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8.w,
                right: 8.w,
                child: Container(
                  width: 23.w,
                  height: 23.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 15.w,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSummary(BuildContext context, InvitationState state, AppLocalizations? l, bool isEnglish) {
    final totalPrice = state.selectedServices.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_cart,
            color: AppColors.primary,
            size: 23.w,
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l?.translate('invitation_selected_services') ?? 'Selected services'}: ${state.selectedServices.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  state.selectedServices.map((s) => isEnglish ? s.name : s.nameAr).join(isEnglish ? ', ' : ' ، '),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 11.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Text(
              '${totalPrice.toStringAsFixed(0)} ₪',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, InvitationState state, AppLocalizations? l) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Expanded(
            child: AppButton(
              text: l?.translate('common_back') ?? 'Back',
              onPressed: () {
                context.read<InvitationCubit>().previousStep();
              },
              backgroundColor: Colors.grey.shade200,
              textColor: Colors.black87,
            ),
          ),

          SizedBox(width: 11.w),

          // Next Button (can proceed without selecting any services)
          Expanded(
            flex: 2,
            child: AppButton(
              text: l?.translate('common_next') ?? 'Next',
              onPressed: state.isLoadingServices
                  ? null
                  : () {
                      context.read<InvitationCubit>().nextStep();
                    },
            ),
          ),
        ],
      ),
    );
  }
}
