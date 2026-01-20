import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
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
    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // Step Header
                const WizardStepHeader(
                  currentStep: 5,
                  totalSteps: 7,
                  title: 'الخدمات الإضافية',
                ),

                // Paid Services Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.amber.shade100,
                  child: Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber.shade800,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'هذه خدمات مدفوعة ستضاف إلى الفاتورة النهائية',
                          style: TextStyle(
                            fontSize: 13,
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
                  child: _buildContent(context, state),
                ),

                // Selected Services Summary
                if (state.selectedServices.isNotEmpty)
                  _buildSelectedSummary(state),

                // Navigation Buttons
                _buildNavigationButtons(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, InvitationState state) {
    if (state.isLoadingServices) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'جاري تحميل الخدمات...',
              style: TextStyle(
                fontSize: 16,
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ أثناء تحميل الخدمات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.servicesError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'إعادة المحاولة',
                onPressed: () {
                  context.read<InvitationCubit>().loadExtraServices();
                },
                width: 200,
              ),
            ],
          ),
        ),
      );
    }

    if (state.availableServices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.room_service_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد خدمات إضافية متاحة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يمكنك المتابعة للخطوة التالية',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info text
          Text(
            'اختر الخدمات الإضافية التي تريدها لحدثك',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Services Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: state.availableServices.length,
            itemBuilder: (context, index) {
              final service = state.availableServices[index];
              final isSelected = state.selectedServices.contains(service);
              return _buildServiceCard(context, service, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, ExtraServiceModel service, bool isSelected) {
    return GestureDetector(
      onTap: () {
        context.read<InvitationCubit>().toggleService(service);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: service.iconUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              service.iconUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.room_service,
                                size: 28,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade600,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.room_service,
                            size: 28,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade600,
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Name (Arabic)
                  Text(
                    service.nameAr,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade800,
                    ),
                  ),

                  // Name (English) if different
                  if (service.name != service.nameAr) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Price
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${service.price.toStringAsFixed(0)} ₪',
                      style: TextStyle(
                        fontSize: 14,
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
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSummary(InvitationState state) {
    final totalPrice = state.selectedServices.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_cart,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الخدمات المختارة: ${state.selectedServices.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  state.selectedServices.map((s) => s.nameAr).join(' ، '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${totalPrice.toStringAsFixed(0)} ₪',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, InvitationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Back Button
          Expanded(
            child: AppButton(
              text: 'السابق',
              onPressed: () {
                context.read<InvitationCubit>().previousStep();
              },
              backgroundColor: Colors.grey.shade200,
              textColor: Colors.black87,
            ),
          ),

          const SizedBox(width: 12),

          // Next Button (can proceed without selecting any services)
          Expanded(
            flex: 2,
            child: AppButton(
              text: 'التالي',
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
