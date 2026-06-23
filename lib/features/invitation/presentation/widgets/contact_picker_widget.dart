import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/phone_normalizer.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../data/models/invitation_draft_model.dart';

/// Common dialing country codes offered in the per-contact selector.
/// Palestine (970) is the default for the primary user base.
const List<(String code, String label)> _kCountryCodes = [
  ('970', '🇵🇸 +970'),
  ('972', '+972'),
  ('962', '🇯🇴 +962'),
  ('20', '🇪🇬 +20'),
  ('966', '🇸🇦 +966'),
  ('971', '🇦🇪 +971'),
  ('965', '🇰🇼 +965'),
  ('973', '🇧🇭 +973'),
  ('974', '🇶🇦 +974'),
  ('968', '🇴🇲 +968'),
  ('961', '🇱🇧 +961'),
  ('963', '🇸🇾 +963'),
  ('964', '🇮🇶 +964'),
  ('90', '🇹🇷 +90'),
  ('1', '🇺🇸 +1'),
  ('44', '🇬🇧 +44'),
  ('49', '🇩🇪 +49'),
  ('33', '🇫🇷 +33'),
];

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

  /// Selection + per-contact dialing code, keyed by the contact id.
  final Set<String> _selectedContactIds = {};
  final Map<String, String> _countryCodeByContact = {};

  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _ccFor(Contact c) =>
      _countryCodeByContact[c.id] ?? PhoneNormalizer.defaultCountryCode;

  String _rawPhoneFor(Contact c) =>
      c.phones.isNotEmpty ? c.phones.first.number : '';

  /// Final canonical phone for a contact using its chosen country code.
  String _finalPhoneFor(Contact c) =>
      PhoneNormalizer.normalize(_rawPhoneFor(c), countryCode: _ccFor(c));

  Future<void> _loadContacts() async {
    final t = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hasPermission = await FlutterContacts.requestPermission();

      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          _errorMessage = t.translate('contacts_permission_required');
          _isLoading = false;
        });
        return;
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Show ALL contacts that have at least one phone number — no longer
      // restricted to +970/+972. Country code is chosen per contact below.
      final withPhones = contacts.where((c) => c.phones.isNotEmpty).toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));

      // Pre-select contacts that match a previously selected number. Try the
      // default plus every known country code so a contact saved under a
      // non-970 code is still re-checked (and its chosen code restored).
      final previousPhones = widget.previouslySelected
          .where((g) => g.source == GuestSource.contacts)
          .map((g) => PhoneNormalizer.normalize(g.phone, countryCode: g.countryCode))
          .toSet();

      if (previousPhones.isNotEmpty) {
        final candidateCodes = <String>{
          PhoneNormalizer.defaultCountryCode,
          ..._kCountryCodes.map((e) => e.$1),
        };
        for (final c in withPhones) {
          final raw = _rawPhoneFor(c);
          for (final code in candidateCodes) {
            if (previousPhones.contains(
              PhoneNormalizer.normalize(raw, countryCode: code),
            )) {
              _selectedContactIds.add(c.id);
              _countryCodeByContact[c.id] = code;
              break;
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _contacts = withPhones;
        _filteredContacts = withPhones;
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
      setState(() => _filteredContacts = _contacts);
    } else {
      setState(() {
        _filteredContacts = _contacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final phones = contact.phones.map((p) => p.number).join(' ');
          return name.contains(query.toLowerCase()) || phones.contains(query);
        }).toList();
      });
    }
  }

  void _toggleContact(Contact contact) {
    setState(() {
      if (_selectedContactIds.contains(contact.id)) {
        _selectedContactIds.remove(contact.id);
      } else {
        _selectedContactIds.add(contact.id);
      }
    });
  }

  void _setCountryCode(Contact contact, String code) {
    setState(() => _countryCodeByContact[contact.id] = code);
  }

  void _confirmSelection() {
    final selectedGuests = <GuestInfoModel>[];

    for (final contact in _contacts) {
      if (!_selectedContactIds.contains(contact.id)) continue;
      final cc = _ccFor(contact);
      selectedGuests.add(GuestInfoModel(
        name: contact.displayName,
        phone: _finalPhoneFor(contact),
        countryCode: cc,
        source: GuestSource.contacts,
      ));
    }

    widget.onContactsSelected(selectedGuests);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final count = _selectedContactIds.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('contacts_select_title')),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: count == 0 ? null : _confirmSelection,
            child: Text(
              '${t.translate('common_confirm')} ($count)',
              style: TextStyle(
                color: count == 0 ? Colors.white54 : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
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

          // Hint: pick a country code per contact (default +970).
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'اختر كود الدولة لكل رقم (الافتراضي 970+)'
                        : 'Pick a country code per contact (default +970)',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: _buildContent()),

          if (count > 0)
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
                text: '${t.translate('guest_add_button')} ($count)',
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
              Icon(Icons.contacts, size: 64, color: context.iconDefault),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: context.textSecondary),
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
            Icon(Icons.search_off, size: 64, color: context.iconDefault),
            const SizedBox(height: 16),
            Text(
              t.translate('contacts_no_results'),
              style: TextStyle(fontSize: 16, color: context.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final isSelected = _selectedContactIds.contains(contact.id);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                isSelected ? AppColors.primary : context.borderColor,
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
            _rawPhoneFor(contact),
            style: TextStyle(color: context.textSecondary, fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Per-contact country-code selector (default +970).
              _CountryCodeDropdown(
                value: _ccFor(contact),
                onChanged: (code) => _setCountryCode(contact, code),
              ),
              const SizedBox(width: 4),
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleContact(contact),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          onTap: () => _toggleContact(contact),
        );
      },
    );
  }
}

class _CountryCodeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _CountryCodeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Ensure the current value exists in the list, even if uncommon.
    final codes = List<(String, String)>.from(_kCountryCodes);
    if (!codes.any((c) => c.$1 == value)) {
      codes.insert(0, (value, '+$value'));
    }

    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      isDense: true,
      borderRadius: BorderRadius.circular(12),
      items: codes
          .map((c) => DropdownMenuItem<String>(
                value: c.$1,
                child: Text(c.$2, style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
