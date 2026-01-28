import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/widgets.dart';

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
    _setupAnimations();
    context.read<PaymentCubit>().loadBankDetails();
  }

  void _setupAnimations() {
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
      context.read<PaymentCubit>().uploadInvoice(eventId: widget.eventId ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is UploadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.red500),
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
                const PaymentHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(context.dynamicWidth(0.061)),
                    child: BlocBuilder<PaymentCubit, PaymentState>(
                      builder: (context, state) {
                        return _PaymentContent(
                          state: state,
                          onSubmit: () => _handleSubmit(state),
                          onSkip: widget.onComplete,
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
}

class _PaymentContent extends StatelessWidget {
  final PaymentState state;
  final VoidCallback onSubmit;
  final VoidCallback? onSkip;

  const _PaymentContent({
    required this.state,
    required this.onSubmit,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUploading = state is Uploading;
    final bool uploadSuccess = state is UploadSuccess;
    final double uploadProgress = isUploading ? (state as Uploading).progress : 0.0;
    final bool canSubmit = state.selectedFile != null && !isUploading;

    return Column(
      children: [
        const PaymentInfoCard(),
        SizedBox(height: context.dynamicHeight(0.03)),
        UploadAreaWidget(
          selectedFile: state.selectedFile,
          isUploading: isUploading,
          uploadSuccess: uploadSuccess,
          uploadProgress: uploadProgress,
          onPickFile: () => context.read<PaymentCubit>().pickFile(),
          onRemoveFile: () => context.read<PaymentCubit>().removeFile(),
        ),
        SizedBox(height: context.dynamicHeight(0.03)),
        state.bankDetails == null
            ? const BankDetailsCardSkeleton()
            : BankDetailsCardWidget(bankDetails: state.bankDetails),
        SizedBox(height: context.dynamicHeight(0.03)),
        if (state.selectedFile != null) ...[
          PaymentSubmitButton(
            isUploading: isUploading,
            uploadSuccess: uploadSuccess,
            canSubmit: canSubmit,
            onPressed: onSubmit,
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
        ],
        TextButton(
          onPressed: onSkip,
          child: Text(
            'Skip for now',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.035),
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.039)),
      ],
    );
  }
}
