import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/phone_normalizer.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
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
  final Set<String> _selectedPhones = {};
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
    // Defer loading contacts until after the first frame when context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizePhone(String phone) => PhoneNormalizer.normalize(phone);

  bool _isValidPalestinianNumber(String phone) {
    final normalized = _normalizePhone(phone);
    return normalized.startsWith('+972') || normalized.startsWith('+970');
  }

  Future<void> _loadContacts() async {
    final t = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Request permission using flutter_contacts built-in method
      final hasPermission = await FlutterContacts.requestPermission();

      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          _errorMessage = t.translate('contacts_permission_required');
          _isLoading = false;
        });
        return;
      }

      // Permission granted - fetch contacts with full access
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

      if (!mounted) return;
      setState(() {
        _contacts = validContacts;
        _filteredContacts = validContacts;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error loading contacts: $e');
      debugPrint('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _errorMessage = '${t.translate('contacts_error_loading')}\n$e';
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
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('contacts_select_title')),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _selectedPhones.isEmpty ? null : _confirmSelection,
            child: Text(
              '${t.translate('common_confirm')} (${_selectedPhones.length})',
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
              hintText: t.translate('contacts_search_hint'),
              prefixIcon: Icons.search,
              onChanged: _filterContacts,
            ),
          ),

          // Info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withValues(alpha: 0.1),
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
                    t.translate('contacts_palestinian_only'),
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
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: '${t.translate('guest_add_button')} (${_selectedPhones.length})',
                onPressed: _confirmSelection,
                width: double.infinity,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final t = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(t.translate('contacts_loading')),
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
                color: context.iconDefault,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: t.translate('contacts_retry'),
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
              color: context.iconDefault,
            ),
            const SizedBox(height: 16),
            Text(
              _contacts.isEmpty
                  ? t.translate('contacts_no_palestinian')
                  : t.translate('contacts_no_results'),
              style: TextStyle(
                fontSize: 16,
                color: context.textSecondary,
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
                : context.borderColor,
            child: Text(
              contact.displayName.isNotEmpty
                  ? contact.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: isSelected ? Colors.white : context.textTertiary,
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
              color: context.textSecondary,
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
