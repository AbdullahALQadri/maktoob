import 'package:equatable/equatable.dart';

import '../../../identity/domain/entities/identity_entities.dart';
import '../../../institution/domain/entities/institution_entity.dart';

/// User type enum for distinguishing between individual users and institutions
enum UserType {
  user,
  institution;

  String get displayName {
    switch (this) {
      case UserType.user:
        return 'Individual';
      case UserType.institution:
        return 'Institution';
    }
  }

  String get displayNameAr {
    switch (this) {
      case UserType.user:
        return 'فرد';
      case UserType.institution:
        return 'مؤسسة';
    }
  }

  String get apiValue {
    switch (this) {
      case UserType.user:
        return 'user';
      case UserType.institution:
        return 'institution';
    }
  }

  static UserType fromString(String? value) {
    if (value == 'institution' || value == 'organization') {
      return UserType.institution;
    }
    return UserType.user;
  }
}

/// Base user entity for authentication
class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? companyName;
  final bool isVerified;
  final String? locale;
  final UserType userType;

  /// Approval status when [userType] is institution (`institution_status`).
  final InstitutionStatus? institutionStatus;

  /// The institution this client owns (`client.institution`).
  final InstitutionEntity? institution;

  /// Accepted memberships in other institutions (`institution_memberships`).
  final List<InstitutionMembershipEntity> memberships;

  /// The Maktoob team opened this account with a temporary password
  /// (`must_change_password`): the app asks for a new one before anything else.
  final bool mustChangePassword;

  /// The team published a Terms / Privacy version this client has not
  /// accepted yet (`legal.acceptance_required`): the app asks for it first.
  final bool mustAcceptTerms;

  /// Identity verification (KYC, `client.identity`). Not the mobile check
  /// ([isVerified]). Null on older backends.
  final IdentityStateEntity? identity;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.companyName,
    this.isVerified = false,
    this.locale,
    this.userType = UserType.user,
    this.institutionStatus,
    this.institution,
    this.memberships = const [],
    this.mustChangePassword = false,
    this.mustAcceptTerms = false,
    this.identity,
  });

  /// The identity is verified by the Maktoob team (not just the mobile number).
  bool get isIdentityVerified => identity?.isVerified ?? false;

  /// The team asked for identity verification before events can be activated.
  bool get identityRequired => (identity?.required ?? false) && !isIdentityVerified;

  /// An institution account that an admin has not approved (yet): the app
  /// shows the approval-waiting screen instead of the normal shell.
  bool get needsInstitutionApproval =>
      userType == UserType.institution &&
      (institutionStatus ?? institution?.status) != InstitutionStatus.approved;

  bool get isApprovedInstitutionOwner =>
      userType == UserType.institution &&
      (institutionStatus ?? institution?.status) == InstitutionStatus.approved;

  /// Institutions this client may create events for (owner of an approved
  /// institution, or manager in one) — the wizard's "for whom?" choices.
  List<EventOwnerChoice> get eventOwnerChoices => [
        if (isApprovedInstitutionOwner && institution != null)
          EventOwnerChoice(
            institutionId: institution!.id,
            name: institution!.nameAr,
            credits: institution!.invitationCredits,
          ),
        for (final m in memberships)
          if (m.isApproved && m.role == 'manager')
            EventOwnerChoice(institutionId: m.institutionId, name: m.institutionName),
      ];

  /// Institution account per the backend's `account_type`. An individual may
  /// still fill in a workplace (`companyName`); that does not make them one.
  bool get isInstitution => userType == UserType.institution;

  /// Up to two initials for the avatar placeholder (first + last word).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    String first(String w) => String.fromCharCode(w.runes.first);
    if (parts.length == 1) return first(parts.first).toUpperCase();
    return '${first(parts.first)}${first(parts.last)}'.toUpperCase();
  }

  /// Copy with method for updating fields
  UserEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? companyName,
    bool? isVerified,
    String? locale,
    UserType? userType,
    InstitutionStatus? institutionStatus,
    InstitutionEntity? institution,
    List<InstitutionMembershipEntity>? memberships,
    bool? mustChangePassword,
    bool? mustAcceptTerms,
    IdentityStateEntity? identity,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      companyName: companyName ?? this.companyName,
      isVerified: isVerified ?? this.isVerified,
      locale: locale ?? this.locale,
      userType: userType ?? this.userType,
      institutionStatus: institutionStatus ?? this.institutionStatus,
      institution: institution ?? this.institution,
      memberships: memberships ?? this.memberships,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      mustAcceptTerms: mustAcceptTerms ?? this.mustAcceptTerms,
      identity: identity ?? this.identity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatar,
        companyName,
        isVerified,
        locale,
        userType,
        institutionStatus,
        institution,
        memberships,
        mustChangePassword,
        mustAcceptTerms,
        identity,
      ];
}

/// One "for whom is this event?" option in the wizard.
class EventOwnerChoice extends Equatable {
  final int institutionId;
  final String name;

  /// Prepaid balance when known (owner only).
  final int? credits;

  const EventOwnerChoice({required this.institutionId, required this.name, this.credits});

  @override
  List<Object?> get props => [institutionId, name, credits];
}
