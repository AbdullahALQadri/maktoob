import 'dart:io';

import 'package:excel/excel.dart';

import '../../../../core/utils/phone_normalizer.dart';
import '../models/invitation_draft_model.dart';

/// Service for parsing Excel files containing guest data
class ExcelParserService {
  /// Parse an Excel file and extract guest information
  /// Expected format: Column A = guest_name, Column B = phone (+972 or +970)
  Future<ExcelParseResult> parseExcelFile(File file) async {
    final guests = <GuestInfoModel>[];
    final errors = <String>[];
    final warnings = <String>[];

    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      for (final tableName in excel.tables.keys) {
        final sheet = excel.tables[tableName]!;

        // Skip if empty
        if (sheet.maxRows <= 1) {
          warnings.add('Sheet "$tableName" is empty or has only headers');
          continue;
        }

        // Process rows (skip header row at index 0)
        for (int i = 1; i < sheet.maxRows; i++) {
          final row = sheet.rows[i];

          // Skip empty rows
          if (row.isEmpty) continue;

          // Get name from first column
          final nameCell = row.isNotEmpty ? row[0] : null;
          final name = nameCell?.value?.toString().trim() ?? '';

          // Get phone from second column
          final phoneCell = row.length > 1 ? row[1] : null;
          final phone = phoneCell?.value?.toString().trim() ?? '';

          // Skip rows with empty name
          if (name.isEmpty) {
            if (phone.isNotEmpty) {
              warnings.add('Row ${i + 1}: Name is empty, skipping');
            }
            continue;
          }

          // Skip rows with empty phone
          if (phone.isEmpty) {
            warnings.add('Row ${i + 1}: Phone is empty for "$name", skipping');
            continue;
          }

          // Validate phone format
          if (!_isValidPhone(phone)) {
            errors.add(
                'Row ${i + 1}: Invalid phone format "$phone" for "$name". Expected +972 or +970 format.');
            continue;
          }

          // Add valid guest
          guests.add(GuestInfoModel(
            name: name,
            phone: _normalizePhone(phone),
            source: GuestSource.excel,
          ));
        }
      }

      return ExcelParseResult(
        guests: guests,
        errors: errors,
        warnings: warnings,
        totalRowsProcessed: guests.length + errors.length,
      );
    } catch (e) {
      return ExcelParseResult(
        guests: [],
        errors: ['Failed to parse Excel file: ${e.toString()}'],
        warnings: [],
        totalRowsProcessed: 0,
      );
    }
  }

  /// Check if phone number is in valid format (+972 or +970)
  bool _isValidPhone(String phone) {
    final normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return normalized.startsWith('+972') ||
        normalized.startsWith('+970') ||
        normalized.startsWith('972') ||
        normalized.startsWith('970') ||
        normalized.startsWith('0'); // Local format
  }

  /// Normalize phone number to international format.
  /// Delegates to [PhoneNormalizer] for canonical form across all guest sources.
  String _normalizePhone(String phone) => PhoneNormalizer.normalize(phone);

  /// Get expected format description for user guidance
  String getExpectedFormatDescription() {
    return '''
Expected Excel format:
- Column A: Guest Name
- Column B: Phone Number (+972 or +970 format)

Example:
| Guest Name    | Phone          |
|---------------|----------------|
| Ahmad Ali     | +970599123456  |
| Sara Mohamed  | +972501234567  |
''';
  }
}

/// Result of parsing an Excel file
class ExcelParseResult {
  final List<GuestInfoModel> guests;
  final List<String> errors;
  final List<String> warnings;
  final int totalRowsProcessed;

  const ExcelParseResult({
    required this.guests,
    required this.errors,
    required this.warnings,
    required this.totalRowsProcessed,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isSuccess => !hasErrors && guests.isNotEmpty;

  int get successCount => guests.length;
  int get errorCount => errors.length;
}
