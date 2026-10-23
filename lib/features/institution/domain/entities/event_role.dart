/// The caller's role on one event (backend `my_role`, see
/// `App\Services\Institutions\EventAccess`).
///
///   ability  | owner | manager | door_staff | viewer
///   view     |  yes  |   yes   |     -      |  yes
///   manage   |  yes  |   yes   |     -      |   -
///   scan     |  yes  |   yes   |    yes     |   -
///   own      |  yes  |    -    |     -      |   -   (delete, payments, team)
enum EventRole {
  owner,
  manager,
  doorStaff,
  viewer;

  /// Unknown / missing values mean the event is the caller's own.
  static EventRole fromString(String? value) {
    switch (value) {
      case 'manager':
        return EventRole.manager;
      case 'door_staff':
        return EventRole.doorStaff;
      case 'viewer':
        return EventRole.viewer;
      default:
        return EventRole.owner;
    }
  }

  String get apiValue => switch (this) {
        EventRole.owner => 'owner',
        EventRole.manager => 'manager',
        EventRole.doorStaff => 'door_staff',
        EventRole.viewer => 'viewer',
      };

  bool get canView => this != EventRole.doorStaff;
  bool get canManage => this == EventRole.owner || this == EventRole.manager;
  bool get canScan => this != EventRole.viewer;

  /// Delete the event, pay for it, manage the team.
  bool get canOwn => this == EventRole.owner;

  /// Door staff see only the scanner.
  bool get isScannerOnly => this == EventRole.doorStaff;

  bool get isReadOnly => this == EventRole.viewer;

  /// Translation key for the role label.
  String get labelKey => 'institution_role_$apiValue';
}
