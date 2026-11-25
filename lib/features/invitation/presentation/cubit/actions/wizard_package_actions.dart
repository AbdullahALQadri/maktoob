import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/wizard_results.dart';
import '../invitation_state.dart';
import 'wizard_deps.dart';

/// Step 5: packages, the custom package and its price.
mixin WizardPackageActions on Cubit<InvitationState>, WizardDeps {
  /// The "name your own number" package, always offered last.
  static const _customPackage = PackageModel(
    id: -1,
    name: 'invitation_custom_package',
    nameAr: 'invitation_custom_package',
    price: 0,
    isCustom: true,
    features: _customFeatures,
    featuresAr: _customFeatures,
  );
  static const _customFeatures = [
    'invitation_custom_package_feature1',
    'invitation_custom_package_feature2',
    'invitation_custom_package_feature3',
  ];

  /// Picks a package; tapping the picked one again clears it. The choice
  /// stays changeable until payment.
  void selectPackage(PackageModel package) {
    if (!package.isAvailable) return;
    if (state.selectedPackage?.id == package.id) {
      clearPackage();
      return;
    }
    emit(state.copyWith(selectedPackage: package, packageValidationError: false));
  }

  /// Drops the choice here and on the draft. Best effort there: the final
  /// save sends the chosen package again anyway.
  Future<void> clearPackage() async {
    emit(state.copyWith(clearSelectedPackage: true, packageValidationError: false));
    final eventId = state.draftEventId;
    if (repository != null && eventId != null) await repository!.selectPackage(eventId);
  }

  void setCustomPackageLimit(int limit) {
    emit(state.copyWith(customPackageLimit: limit));
    calculateCustomPackagePrice(limit);
  }

  Future<void> loadPackages() async {
    emit(state.copyWith(isLoadingPackages: true, packagesError: null));
    final eventId = state.draftEventId;
    final result = repository == null || eventId == null ? null : await repository!.packages(eventId);
    if (isClosed) return;
    final failure = result?.fold((f) => f, (_) => null);
    if (failure != null) return emit(state.copyWith(isLoadingPackages: false, packagesError: failure.toString()));

    final offer = result?.getOrElse(() => const WizardPackages()) ?? const WizardPackages();
    final packages = [...offer.packages, if (!offer.packages.any((p) => p.isCustom)) _customPackage];
    // A package no longer offered (the free trial once used) must not stay
    // silently chosen.
    final chosen = state.selectedPackage;
    final stillOffered = chosen == null || chosen.isCustom || packages.any((p) => p.id == chosen.id && p.isAvailable);

    emit(state.copyWith(
      isLoadingPackages: false,
      availablePackages: packages,
      freeTrialAvailable: offer.freeTrialAvailable,
      suggestedPackageId: offer.suggestedPackageId,
      clearSelectedPackage: !stillOffered,
    ));
  }

  /// The server's price for a custom package of [limit] invitations.
  Future<void> calculateCustomPackagePrice(int limit) async {
    if (repository == null) return;
    emit(state.copyWith(isLoadingCustomPrice: true));
    final result = await repository!.customPackagePrice(limit);
    // A newer number may have been typed while this one was on its way.
    if (isClosed || state.customPackageLimit != limit) return;
    emit(result.fold(
      (failure) => state.copyWith(isLoadingCustomPrice: false, errorMessage: failure.toString()),
      (price) => state.copyWith(isLoadingCustomPrice: false, customPackagePrice: price),
    ));
  }
}
