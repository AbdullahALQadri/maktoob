import 'package:equatable/equatable.dart';

import '../../domain/entities/guest_group.dart';

/// The list of groups. [message] is a one-off note (a refusal, a problem).
class GuestGroupsState extends Equatable {
  const GuestGroupsState({this.overview, this.loading = true, this.busy = false, this.message});

  /// Null until loaded, and when loading failed with nothing to show.
  final GuestGroupsOverview? overview;
  final bool loading;

  /// A group is being created or deleted.
  final bool busy;
  final String? message;

  List<GuestGroup> get groups => overview?.groups ?? const [];

  GuestGroupsState copyWith({GuestGroupsOverview? overview, bool? loading, bool? busy, String? message}) =>
      GuestGroupsState(
        overview: overview ?? this.overview,
        loading: loading ?? this.loading,
        busy: busy ?? this.busy,
        message: message,
      );

  @override
  List<Object?> get props => [overview, loading, busy, message];
}

/// One open group.
class GuestGroupState extends Equatable {
  const GuestGroupState({this.group, this.loading = true, this.busy = false, this.message, this.deleted = false});

  final GuestGroup? group;
  final bool loading;
  final bool busy;
  final String? message;
  final bool deleted;

  GuestGroupState copyWith({GuestGroup? group, bool? loading, bool? busy, String? message, bool? deleted}) =>
      GuestGroupState(
        group: group ?? this.group,
        loading: loading ?? this.loading,
        busy: busy ?? this.busy,
        message: message,
        deleted: deleted ?? this.deleted,
      );

  @override
  List<Object?> get props => [group, loading, busy, message, deleted];
}
