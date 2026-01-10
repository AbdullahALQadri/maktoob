import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.fileName,
    required super.fileSize,
    required super.fileExtension,
    super.filePath,
    required super.uploadedAt,
    required super.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as int,
      fileExtension: json['file_extension'] as String,
      filePath: json['file_path'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      status: _parseStatus(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_size': fileSize,
      'file_extension': fileExtension,
      'file_path': filePath,
      'uploaded_at': uploadedAt.toIso8601String(),
      'status': status.name,
    };
  }

  static PaymentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'uploaded':
        return PaymentStatus.uploaded;
      case 'verified':
        return PaymentStatus.verified;
      case 'rejected':
        return PaymentStatus.rejected;
      default:
        return PaymentStatus.pending;
    }
  }

  PaymentModel copyWith({
    String? id,
    String? fileName,
    int? fileSize,
    String? fileExtension,
    String? filePath,
    DateTime? uploadedAt,
    PaymentStatus? status,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileExtension: fileExtension ?? this.fileExtension,
      filePath: filePath ?? this.filePath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      status: status ?? this.status,
    );
  }
}
