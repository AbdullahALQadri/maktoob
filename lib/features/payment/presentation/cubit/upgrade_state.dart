import 'package:equatable/equatable.dart';

import '../../domain/entities/upgrade_options.dart';

/// "Increase invitations": what is offered and what the host picked.
class UpgradeState extends Equatable {
  const UpgradeState({
    this.options,
    this.loading = true,
    this.error,
    this.packageId,
    this.customInvitations,
    this.customQuote,
    this.calculating = false,
    this.customError,
  });

  final UpgradeOptions? options;
  final bool loading;
  final String? error;

  /// The bigger package picked, or null.
  final int? packageId;

  /// The number the host typed, once it has a price ([customQuote]).
  final int? customInvitations;
  final UpgradeQuote? customQuote;
  final bool calculating;
  final String? customError;

  UpgradePackage? get package {
    for (final p in options?.packages ?? const <UpgradePackage>[]) {
      if (p.id == packageId) return p;
    }
    return null;
  }

  /// What the choice costs; null until something is chosen.
  UpgradeQuote? get quote => package?.quote ?? customQuote;

  bool get usesCustom => package == null && customQuote != null;

  UpgradeState copyWith({
    UpgradeOptions? options,
    bool? loading,
    String? error,
    int? packageId,
    int? customInvitations,
    UpgradeQuote? customQuote,
    bool? calculating,
    String? customError,
    bool clearChoice = false,
  }) {
    return UpgradeState(
      options: options ?? this.options,
      loading: loading ?? this.loading,
      error: error,
      packageId: clearChoice ? null : packageId ?? this.packageId,
      customInvitations: clearChoice ? null : customInvitations ?? this.customInvitations,
      customQuote: clearChoice ? null : customQuote ?? this.customQuote,
      calculating: calculating ?? this.calculating,
      customError: customError,
    );
  }

  @override
  List<Object?> get props =>
      [options, loading, error, packageId, customInvitations, customQuote, calculating, customError];
}
