import 'package:equatable/equatable.dart';

/// What moving to more invitations costs: only the difference is paid.
class UpgradeQuote extends Equatable {
  const UpgradeQuote({required this.currentLimit, required this.targetLimit, required this.total});

  final int currentLimit;
  final int targetLimit;

  /// What is left to pay, in shekels.
  final double total;

  @override
  List<Object?> get props => [currentLimit, targetLimit, total];
}

/// A bigger package an active event can move to.
class UpgradePackage extends Equatable {
  const UpgradePackage({
    required this.id,
    required this.invitations,
    required this.quote,
    this.nameAr,
    this.nameEn,
    this.pricePerInvitation,
  });

  final int id;
  final int invitations;
  final UpgradeQuote quote;
  final String? nameAr;
  final String? nameEn;
  final double? pricePerInvitation;

  String name({required bool arabic}) => (arabic ? nameAr ?? nameEn : nameEn ?? nameAr) ?? '';

  @override
  List<Object?> get props => [id, invitations, quote, nameAr, nameEn, pricePerInvitation];
}

/// "Increase invitations" for one event.
class UpgradeOptions extends Equatable {
  const UpgradeOptions({
    required this.currentLimit,
    this.packages = const [],
    this.hasPendingRequest = false,
    this.customEnabled = false,
    this.customMax = 0,
  });

  final int currentLimit;
  final List<UpgradePackage> packages;

  /// A payment is already waiting for review: nothing new until it is.
  final bool hasPendingRequest;

  /// The host may name their own number of invitations.
  final bool customEnabled;
  final int customMax;

  bool get isEmpty => packages.isEmpty && !customEnabled;

  @override
  List<Object?> get props => [currentLimit, packages, hasPendingRequest, customEnabled, customMax];
}
