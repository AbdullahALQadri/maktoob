import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/payment_entity.dart';

abstract class PaymentState extends Equatable {
  final BankDetailsEntity? bankDetails;
  final PlatformFile? selectedFile;

  const PaymentState({
    this.bankDetails,
    this.selectedFile,
  });

  @override
  List<Object?> get props => [bankDetails, selectedFile];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial({
    super.bankDetails,
    super.selectedFile,
  });

  PaymentInitial copyWith({
    BankDetailsEntity? bankDetails,
    PlatformFile? selectedFile,
  }) {
    return PaymentInitial(
      bankDetails: bankDetails ?? this.bankDetails,
      selectedFile: selectedFile ?? this.selectedFile,
    );
  }
}

class FileSelected extends PaymentState {
  const FileSelected({
    required PlatformFile file,
    super.bankDetails,
  }) : super(selectedFile: file);

  @override
  List<Object?> get props => [selectedFile, bankDetails];

  FileSelected copyWith({
    PlatformFile? file,
    BankDetailsEntity? bankDetails,
  }) {
    return FileSelected(
      file: file ?? selectedFile!,
      bankDetails: bankDetails ?? this.bankDetails,
    );
  }
}

class Uploading extends PaymentState {
  final double progress;

  const Uploading({
    required this.progress,
    required PlatformFile file,
    super.bankDetails,
  }) : super(selectedFile: file);

  @override
  List<Object?> get props => [progress, selectedFile, bankDetails];

  Uploading copyWith({
    double? progress,
    PlatformFile? file,
    BankDetailsEntity? bankDetails,
  }) {
    return Uploading(
      progress: progress ?? this.progress,
      file: file ?? selectedFile!,
      bankDetails: bankDetails ?? this.bankDetails,
    );
  }
}

class UploadSuccess extends PaymentState {
  final PaymentEntity payment;

  const UploadSuccess({
    required this.payment,
    required PlatformFile file,
    super.bankDetails,
  }) : super(selectedFile: file);

  @override
  List<Object?> get props => [payment, selectedFile, bankDetails];
}

class UploadError extends PaymentState {
  final String message;

  const UploadError({
    required this.message,
    super.selectedFile,
    super.bankDetails,
  });

  @override
  List<Object?> get props => [message, selectedFile, bankDetails];
}
