import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/bank_details_entity.dart';

class BankDetailsCardWidget extends StatelessWidget {
  final BankDetailsEntity? bankDetails;
  final bool isLoading;

  const BankDetailsCardWidget({
    super.key,
    this.bankDetails,
    this.isLoading = false,
  });

  void _copyToClipboard(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.emerald500, AppColors.cyan500],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Bank Transfer Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLoading)
            _buildLoadingState()
          else if (bankDetails != null)
            _buildDetailsContent(context)
          else
            _buildDefaultContent(context),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailsContent(BuildContext context) {
    return Column(
      children: [
        _buildBankDetailRow(context, 'Bank Name', bankDetails!.bankName),
        _buildBankDetailRow(context, 'Account Name', bankDetails!.accountName),
        _buildBankDetailRow(context, 'Account Number', bankDetails!.accountNumber),
        _buildBankDetailRow(context, 'IBAN', bankDetails!.iban),
        _buildBankDetailRow(context, 'SWIFT Code', bankDetails!.swiftCode),
      ],
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    return Column(
      children: [
        _buildBankDetailRow(context, 'Bank Name', 'Al Rajhi Bank'),
        _buildBankDetailRow(context, 'Account Name', 'Maktoob Events LLC'),
        _buildBankDetailRow(context, 'Account Number', '1234567890123456'),
        _buildBankDetailRow(context, 'IBAN', 'SA03 8000 0000 1234 5678 9012 3456'),
        _buildBankDetailRow(context, 'SWIFT Code', 'RJHISARI'),
      ],
    );
  }

  Widget _buildBankDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _copyToClipboard(context, label, value),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: AppColors.gray500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
