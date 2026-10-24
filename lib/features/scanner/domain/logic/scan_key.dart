import 'dart:convert';

/// What a scanned QR carries: the lookup key (short_url or the 8-char
/// qr_code) and, on QRs made since the offline door, the signed door token
/// (`?k=`).
///
/// Mirrors `Invitation::extractScanKey()` in the backend: a JSON payload
/// gives `code` (else `url`), a URL gives its last path segment, anything
/// else is the trimmed value.
class ScanKey {
  final String key;
  final String? token;

  const ScanKey(this.key, {this.token});

  bool get isEmpty => key.isEmpty;

  static ScanKey extract(String raw) {
    var value = raw.trim();
    if (value.isEmpty) return const ScanKey('');

    if (value.startsWith('{')) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          final code = decoded['code']?.toString() ?? '';
          if (code.isNotEmpty) return ScanKey(code);
          final url = decoded['url']?.toString() ?? '';
          if (url.isNotEmpty) value = url;
        }
      } catch (_) {
        // Not JSON after all: treat as text.
      }
    }

    if (value.contains('/')) {
      final uri = Uri.tryParse(value);
      final path = uri?.path ?? value.split('?').first;
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      final token = uri?.queryParameters['k'];
      if (segments.isNotEmpty) {
        return ScanKey(segments.last, token: (token == null || token.isEmpty) ? null : token);
      }
    }

    return ScanKey(value);
  }
}
