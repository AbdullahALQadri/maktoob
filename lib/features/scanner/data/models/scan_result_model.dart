import '../../domain/entities/scan_result_entity.dart';

class ScanResultModel extends ScanResultEntity {
  const ScanResultModel({
    required super.qrCode,
    required super.isValid,
    super.guestId,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      qrCode: json['qr_code'] as String,
      isValid: json['is_valid'] as bool,
      guestId: json['guest_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_code': qrCode,
      'is_valid': isValid,
      'guest_id': guestId,
    };
  }

  factory ScanResultModel.fromEntity(ScanResultEntity entity) {
    return ScanResultModel(
      qrCode: entity.qrCode,
      isValid: entity.isValid,
      guestId: entity.guestId,
    );
  }
}
