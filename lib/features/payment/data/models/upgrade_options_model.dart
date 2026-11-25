import '../../domain/entities/upgrade_options.dart';

/// Readers for the "increase invitations" answers.
class UpgradeOptionsModel {
  const UpgradeOptionsModel._();

  static UpgradeQuote quote(dynamic json) {
    final map = json is Map ? json : const {};
    return UpgradeQuote(
      currentLimit: _int(map['current_limit']),
      targetLimit: _int(map['target_limit']),
      total: _number(map['total']),
    );
  }

  static UpgradeOptions options(dynamic response) {
    final data = _data(response);
    final custom = data['custom'] is Map ? data['custom'] as Map : const {};
    final packages = data['packages'];
    return UpgradeOptions(
      currentLimit: _int(data['current_limit']),
      hasPendingRequest: data['has_pending_request'] == true,
      customEnabled: custom['enabled'] == true,
      customMax: _int(custom['max_guests']),
      packages: [
        for (final item in packages is List ? packages : const [])
          if (item is Map)
            UpgradePackage(
              id: _int(item['id']),
              nameAr: item['name_ar']?.toString(),
              nameEn: item['name_en']?.toString(),
              invitations: _int(item['invitations_limit']),
              pricePerInvitation: item['price_per_invitation'] == null ? null : _number(item['price_per_invitation']),
              quote: quote(item['quote']),
            ),
      ],
    );
  }

  /// The payload, inside "data" or bare.
  static Map _data(dynamic response) {
    final root = response is Map ? response['data'] ?? response : null;
    return root is Map ? root : const {};
  }

  static Map data(dynamic response) => _data(response);

  static int _int(dynamic value) => value is num ? value.toInt() : int.tryParse('${value ?? ''}') ?? 0;

  /// MySQL sends decimals as text.
  static double _number(dynamic value) => value is num ? value.toDouble() : double.tryParse('${value ?? ''}') ?? 0;
}
