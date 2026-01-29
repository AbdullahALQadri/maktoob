import '../../domain/entities/edit_request_entity.dart';

class EditRequestModel extends EditRequestEntity {
  const EditRequestModel({
    required super.id,
    required super.eventId,
    required super.changes,
    required super.status,
    required super.createdAt,
    super.adminNote,
  });

  factory EditRequestModel.fromJson(Map<String, dynamic> json) {
    return EditRequestModel(
      id: json['id'].toString(),
      eventId: json['event_id'].toString(),
      changes: Map<String, dynamic>.from(json['changes'] ?? {}),
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      adminNote: json['admin_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'changes': changes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      if (adminNote != null) 'admin_note': adminNote,
    };
  }

  static EditRequestStatus _parseStatus(String status) {
    switch (status) {
      case 'approved':
        return EditRequestStatus.approved;
      case 'rejected':
        return EditRequestStatus.rejected;
      default:
        return EditRequestStatus.pending;
    }
  }

  EditRequestEntity toEntity() {
    return EditRequestEntity(
      id: id,
      eventId: eventId,
      changes: changes,
      status: status,
      createdAt: createdAt,
      adminNote: adminNote,
    );
  }
}
