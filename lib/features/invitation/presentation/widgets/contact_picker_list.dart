import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';

/// The body of the contact picker: loading, a problem, nothing found, or the
/// contacts with a tick box each.
class ContactPickerList extends StatelessWidget {
  const ContactPickerList({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.contacts,
    required this.hasAnyContact,
    required this.isSelected,
    required this.isValidNumber,
    required this.onToggle,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;

  /// The contacts after the search.
  final List<Contact> contacts;

  /// False when the phone holds no usable contact at all.
  final bool hasAnyContact;
  final bool Function(Contact contact) isSelected;
  final bool Function(String phone) isValidNumber;
  final ValueChanged<Contact> onToggle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _Notice(leading: const MkSpinner(), text: context.tr('contacts_loading'));
    }
    if (errorMessage != null) {
      return _Notice(
        leading: Icon(Icons.contacts, size: 64, color: context.iconDefault),
        text: errorMessage!,
        action: PrimaryButton(text: context.tr('contacts_retry'), onPressed: onRetry, width: 200),
      );
    }
    if (contacts.isEmpty) {
      return _Notice(
        leading: Icon(Icons.search_off, size: 64, color: context.iconDefault),
        text: context.tr(hasAnyContact ? 'contacts_no_results' : 'contacts_no_palestinian'),
      );
    }
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final selected = isSelected(contact);
        final name = contact.displayName ?? '';
        final phone = contact.phones.firstWhere(
          (phone) => isValidNumber(phone.number),
          orElse: () => contact.phones.first,
        );
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: selected ? AppColors.primary : context.borderColor,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: selected ? AppColors.white : context.textTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            phone.number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            style: TextStyle(color: context.textSecondary, fontSize: 13),
          ),
          trailing: Checkbox(
            value: selected,
            onChanged: (_) => onToggle(contact),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onTap: () => onToggle(contact),
        );
      },
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.leading, required this.text, this.action});

  final Widget leading;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: context.textSecondary)),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
