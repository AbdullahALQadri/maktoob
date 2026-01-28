import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/invitation_draft_model.dart';

class ManualGuestForm extends StatefulWidget {
  final Function(GuestInfoModel) onGuestAdded;

  const ManualGuestForm({
    super.key,
    required this.onGuestAdded,
  });

  @override
  State<ManualGuestForm> createState() => _ManualGuestFormState();
}

class _ManualGuestFormState extends State<ManualGuestForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  String _normalizePhone(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (normalized.startsWith('00972')) {
      normalized = '+972${normalized.substring(5)}';
    } else if (normalized.startsWith('00970')) {
      normalized = '+970${normalized.substring(5)}';
    } else if (normalized.startsWith('972')) {
      normalized = '+$normalized';
    } else if (normalized.startsWith('970')) {
      normalized = '+$normalized';
    } else if (normalized.startsWith('0')) {
      normalized = '+972${normalized.substring(1)}';
    } else if (!normalized.startsWith('+')) {
      normalized = '+972$normalized';
    }
    return normalized;
  }

  bool _isValidPalestinianNumber(String phone) {
    final normalized = _normalizePhone(phone);
    final pattern = RegExp(r'^\+97[02]\d{8,9}$');
    return pattern.hasMatch(normalized);
  }

  void _resetForm() {
    // Dispose old controllers
    _nameController.dispose();
    _phoneController.dispose();

    // Create new controllers and form key
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  void _addGuest() {
    final t = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      final normalizedPhone = _normalizePhone(_phoneController.text.trim());
      final guestName = _nameController.text.trim();

      final guest = GuestInfoModel(
        name: guestName,
        phone: normalizedPhone,
        source: GuestSource.manual,
      );

      widget.onGuestAdded(guest);

      // Close keyboard
      FocusScope.of(context).unfocus();

      // Reset form with new controllers
      setState(() {
        _resetForm();
      });

      // Show success feedback
      AppSnackBar.showSuccess(
        context,
        message: '${t.translate('guest_added_success')} $guestName',
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  t.translate('guest_add_manual'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name Field
            AppTextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              labelText: t.translate('guest_name_label'),
              hintText: t.translate('guest_name_hint'),
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                _phoneFocusNode.requestFocus();
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.translate('guest_name_required');
                }
                if (value.trim().length < 2) {
                  return t.translate('guest_name_short');
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Phone Field
            AppTextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              labelText: t.translate('guest_phone_label'),
              hintText: '+972 / +970',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
              ],
              onSubmitted: (_) => _addGuest(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.translate('guest_phone_required');
                }
                if (!_isValidPalestinianNumber(value)) {
                  return t.translate('guest_phone_invalid');
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Phone format hint
            Text(
              t.translate('guest_phone_format'),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Add Button
            AppButton(
              text: t.translate('guest_add_button'),
              onPressed: _addGuest,
              width: double.infinity,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}
