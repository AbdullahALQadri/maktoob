import 'package:equatable/equatable.dart';

/// Someone in a group, named the way this client knows them.
class GroupGuest extends Equatable {
  const GroupGuest({required this.name, this.id, this.phone});

  /// Null for someone typed here and not saved yet.
  final int? id;
  final String name;
  final String? phone;

  @override
  List<Object?> get props => [id, name, phone];
}

/// People the client invites again and again (family, colleagues), saved once.
class GuestGroup extends Equatable {
  const GuestGroup({required this.id, required this.name, this.guestsCount = 0, this.guests = const []});

  final int id;
  final String name;
  final int guestsCount;

  /// Filled when the group is opened; empty in the list of groups.
  final List<GroupGuest> guests;

  @override
  List<Object?> get props => [id, name, guestsCount, guests];
}

class GuestGroupsOverview extends Equatable {
  const GuestGroupsOverview({this.groups = const [], this.totalGuests = 0});

  final List<GuestGroup> groups;

  /// Everyone in the client's guest book, in a group or not.
  final int totalGuests;

  @override
  List<Object?> get props => [groups, totalGuests];
}
