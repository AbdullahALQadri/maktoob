import 'package:equatable/equatable.dart';

enum EditRequestStatus { pending, approved, rejected }

class EditRequestEntity extends Equatable {
  final String id;
  final String eventId;
  final Map<String, dynamic> changes;
  final EditRequestStatus status;
  final DateTime createdAt;
  final String? adminNote;

  const EditRequestEntity({
    required this.id,
    required this.eventId,
    required this.changes,
    required this.status,
    required this.createdAt,
    this.adminNote,
  });

  @override
  List<Object?> get props => [id, eventId, changes, status, createdAt, adminNote];
}
