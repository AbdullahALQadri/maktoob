import 'package:equatable/equatable.dart';

class ScanResultEntity extends Equatable {
  final String qrCode;
  final bool isValid;
  final String? guestId;

  const ScanResultEntity({
    required this.qrCode,
    required this.isValid,
    this.guestId,
  });

  @override
  List<Object?> get props => [qrCode, isValid, guestId];
}
