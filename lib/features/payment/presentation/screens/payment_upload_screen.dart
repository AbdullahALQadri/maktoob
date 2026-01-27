import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/bank_details_card_widget.dart';
import '../widgets/upload_area_widget.dart';

class PaymentUploadScreen extends StatefulWidget {
  final String? eventId;
  final VoidCallback? onComplete;

  const PaymentUploadScreen({
    super.key,
    this.eventId,
    this.onComplete,
  });

  @override
  State<PaymentUploadScreen> createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Load bank details when screen initializes
    context.read<PaymentCubit>().loadBankDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubmit(PaymentState state) {
    if (state is UploadSuccess) {
      widget.onComplete?.call();
    } else {
      context.read<PaymentCubit>().uploadInvoice(
            eventId: widget.eventId ?? '',
          );
    }
  }

  void _handleSkip() {
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is UploadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red500,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                _buildGradientHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(23.w),
                    child: BlocBuilder<PaymentCubit, PaymentState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            _buildInfoCard(),
                            SizedBox(height: 24.h),
                            _buildUploadArea(state),
                            SizedBox(height: 24.h),
                            // Show skeleton when bank details are loading
                            state.bankDetails == null
                                ? const BankDetailsCardSkeleton()
                                : BankDetailsCardWidget(
                                    bankDetails: state.bankDetails,
                                  ),
                            SizedBox(height: 24.h),
                            if (state.selectedFile != null) ...[
                              _buildSubmitButton(state),
                              SizedBox(height: 16.h),
                            ],
                            _buildSkipLink(),
                            SizedBox(height: 32.h),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: context.topPadding + 24.h,
        left: 15.w,
        right: 15.w,
        bottom: 32.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blue600,
            AppColors.primaryColor,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38.w),
          bottomRight: Radius.circular(38.w),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(11.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(11.w),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 26.w,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Invoice',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Submit your payment receipt',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(19.w),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(19.w),
        border: Border.all(
          color: AppColors.blue500.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: AppColors.blue500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11.w),
            ),
            child: Icon(
              Icons.info_outline,
              color: AppColors.blue600,
              size: 23.w,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Instructions',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please transfer the payment amount to the bank account below and upload your transfer receipt or invoice as proof of payment.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.gray600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea(PaymentState state) {
    final bool isUploading = state is Uploading;
    final bool uploadSuccess = state is UploadSuccess;
    final double uploadProgress = state is Uploading ? state.progress : 0.0;

    return UploadAreaWidget(
      selectedFile: state.selectedFile,
      isUploading: isUploading,
      uploadSuccess: uploadSuccess,
      uploadProgress: uploadProgress,
      onPickFile: () => context.read<PaymentCubit>().pickFile(),
      onRemoveFile: () => context.read<PaymentCubit>().removeFile(),
    );
  }

  Widget _buildSubmitButton(PaymentState state) {
    final bool isUploading = state is Uploading;
    final bool uploadSuccess = state is UploadSuccess;
    final bool canSubmit = state.selectedFile != null && !isUploading;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.w),
        onTap: canSubmit ? () => _handleSubmit(state) : null,
        child: Container(
          width: double.infinity,
          height: 57.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.w),
            gradient: canSubmit
                ? LinearGradient(
                    colors: uploadSuccess
                        ? [AppColors.green600, AppColors.emerald500]
                        : [AppColors.primaryColor, AppColors.tertiaryColor],
                  )
                : null,
            color: canSubmit ? null : AppColors.gray300,
            boxShadow: canSubmit
                ? [
                    BoxShadow(
                      color: uploadSuccess
                          ? AppColors.green600.withValues(alpha: 0.3)
                          : AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUploading)
                SizedBox(
                  width: 19.w,
                  height: 19.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(
                  uploadSuccess ? Icons.check : Icons.upload,
                  color: Colors.white,
                  size: 19.w,
                ),
              SizedBox(width: 11.w),
              Text(
                uploadSuccess ? 'Continue' : 'Submit Payment',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipLink() {
    return TextButton(
      onPressed: _handleSkip,
      child: Text(
        'Skip for now',
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.gray500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
