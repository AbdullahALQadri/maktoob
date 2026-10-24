/// How many designs this event can still create (`design_allowance` on the
/// wizard state, generate-prompt, confirm-generate and generation-status
/// responses). Each event has its own; the server already folds in the limit
/// on events that were never paid, so [designsLeft] is the number to trust.
class DesignAllowanceModel {
  final int designsLimit;
  final int designsUsed;
  final int designsLeft;

  /// True when the number reached the limit for unpaid events (paying for one
  /// of them frees new designs).
  final bool poolReached;

  const DesignAllowanceModel({
    required this.designsLimit,
    required this.designsUsed,
    required this.designsLeft,
    this.poolReached = false,
  });

  bool get isUsedUp => designsLeft <= 0;

  /// Null when [json] is not an allowance object (older backends).
  static DesignAllowanceModel? tryParse(dynamic json) {
    if (json is! Map) return null;
    int read(String key) {
      final v = json[key];
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    if (!json.containsKey('designs_left')) return null;
    return DesignAllowanceModel(
      designsLimit: read('designs_limit'),
      designsUsed: read('designs_used'),
      designsLeft: read('designs_left'),
      poolReached: json['pool_reached'] == true,
    );
  }
}
