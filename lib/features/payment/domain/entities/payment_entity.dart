import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String fileName;
  final int fileSize;
  final String fileExtension;
  final String? filePath;
  final DateTime uploadedAt;
  final PaymentStatus status;

  const PaymentEntity({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.fileExtension,
    this.filePath,
    required this.uploadedAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        fileName,
        fileSize,
        fileExtension,
        filePath,
        uploadedAt,
        status,
      ];
}

enum PaymentStatus {
  pending,
  uploaded,
  verified,
  rejected,
}
