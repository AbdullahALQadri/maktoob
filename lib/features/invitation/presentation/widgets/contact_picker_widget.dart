import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/invitation_draft_model.dart';

class ContactPickerWidget extends StatefulWidget {
  final List<GuestInfoModel> previouslySelected;
  final Function(List<GuestInfoModel>) onContactsSelected;

  const ContactPickerWidget({
    super.key,
    required this.previouslySelected,
    required this.onContactsSelected,
  });

  @override
  State<ContactPickerWidget> createState() => _ContactPickerWidgetState();
}

class _ContactPickerWidgetState extends State<ContactPickerWidget> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  Set<String> _selectedPhones = {};
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize selected phones from previously selected contacts
    for (var guest in widget.previouslySelected) {
      if (guest.source == GuestSource.contacts) {
        _selectedPhones.add(_normalizePhone(guest.phone));
      }
    }
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizePhone(String phone) {
    // Remove all non-digit characters except +
    String normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    // Standardize Palestinian numbers
    if (normalized.startsWith('00972')) {
      normalized = '+972${normalized.substring(5)}';
    } else if (normalized.startsWith('00970')) {
      normalized = '+970${normalized.substring(5)}';
    } else if (normalized.startsWith('972')) {
      normalized = '+$normalized';
    } else if (normalized.startsWith('970')) {
      normalized = '+$normalized';
    } else if (normalized.startsWith('0')) {
      // Assume Palestinian number
      normalized = '+972${normalized.substring(1)}';
    }
    return normalized;
  }

  bool _isValidPalestinianNumber(String phone) {
    final normalized = _normalizePhone(phone);
    return normalized.startsWith('+972') || normalized.startsWith('+970');
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Request permission
      final status = await Permission.contacts.request();

      if (status.isGranted) {
        // Get contacts with phones
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        // Filter contacts with valid Palestinian phone numbers
        final validContacts = contacts.where((contact) {
          return contact.phones.any((phone) =>
            _isValidPalestinianNumber(phone.number));
        }).toList();

        // Sort by name
        validContacts.sort((a, b) =>
          (a.displayName).compareTo(b.displayName));

        setState(() {
          _contacts = validContacts;
          _filteredContacts = validContacts;
          _isLoading = false;
        });
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _errorMessage = 'تم رفض الوصول إلى جهات الاتصال بشكل دائم. يرجى تفعيله من الإعدادات.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'يرجى السماح بالوصول إلى جهات الاتصال';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل جهات الاتصال';
        _isLoading = false;
      });
    }
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _contacts;
      });
    } else {
      setState(() {
        _filteredContacts = _contacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final phones = contact.phones.map((p) => p.number).join(' ');
          return name.contains(query.toLowerCase()) ||
              phones.contains(query);
        }).toList();
      });
    }
  }

  void _toggleContact(Contact contact) {
    final validPhone = contact.phones.firstWhere(
      (phone) => _isValidPalestinianNumber(phone.number),
      orElse: () => contact.phones.first,
    );

    final normalizedPhone = _normalizePhone(validPhone.number);

    setState(() {
      if (_selectedPhones.contains(normalizedPhone)) {
        _selectedPhones.remove(normalizedPhone);
      } else {
        _selectedPhones.add(normalizedPhone);
      }
    });
  }

  bool _isContactSelected(Contact contact) {
    for (var phone in contact.phones) {
      if (_selectedPhones.contains(_normalizePhone(phone.number))) {
        return true;
      }
    }
    return false;
  }

  void _confirmSelection() {
    final selectedGuests = <GuestInfoModel>[];

    for (var contact in _contacts) {
      final validPhone = contact.phones.firstWhere(
        (phone) => _isValidPalestinianNumber(phone.number),
        orElse: () => contact.phones.first,
      );

      final normalizedPhone = _normalizePhone(validPhone.number);

      if (_selectedPhones.contains(normalizedPhone)) {
        selectedGuests.add(GuestInfoModel(
          name: contact.displayName,
          phone: normalizedPhone,
          source: GuestSource.contacts,
        ));
      }
    }

    widget.onContactsSelected(selectedGuests);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر جهات الاتصال'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _selectedPhones.isEmpty ? null : _confirmSelection,
            child: Text(
              'تأكيد (${_selectedPhones.length})',
              style: TextStyle(
                color: _selectedPhones.isEmpty
                    ? Colors.white54
                    : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: AppTextField(
              controller: _searchController,
              hintText: 'بحث عن جهة اتصال...',
              prefixIcon: Icons.search,
              onChanged: _filterContacts,
            ),
          ),

          // Info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يتم عرض جهات الاتصال بأرقام فلسطينية فقط (+972 / +970)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),

          // Bottom confirm button
          if (_selectedPhones.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: AppButton(
                text: 'إضافة ${_selectedPhones.length} مدعو',
                onPressed: _confirmSelection,
                width: double.infinity,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل جهات الاتصال...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.contacts,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage!.contains('الإعدادات'))
                AppButton(
                  text: 'فتح الإعدادات',
                  onPressed: () => openAppSettings(),
                  width: 200,
                )
              else
                AppButton(
                  text: 'إعادة المحاولة',
                  onPressed: _loadContacts,
                  width: 200,
                ),
            ],
          ),
        ),
      );
    }

    if (_filteredContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _contacts.isEmpty
                  ? 'لا توجد جهات اتصال بأرقام فلسطينية'
                  : 'لا توجد نتائج للبحث',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final isSelected = _isContactSelected(contact);
        final validPhone = contact.phones.firstWhere(
          (phone) => _isValidPalestinianNumber(phone.number),
          orElse: () => contact.phones.first,
        );

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? AppColors.primary
                : Colors.grey.shade300,
            child: Text(
              contact.displayName.isNotEmpty
                  ? contact.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            contact.displayName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            validPhone.number,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (_) => _toggleContact(contact),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onTap: () => _toggleContact(contact),
        );
      },
    );
  }
}
