import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_method.dart';

/// The app lets the user attach up to this many receipt images
/// (the backend accepts 1–5 `invoice_images[]`).
const int kMaxReceiptImages = 3;

abstract class PaymentState extends Equatable {
  final BankDetailsEntity? bankDetails;
  final List<PlatformFile> selectedFiles;

  const PaymentState({
    this.bankDetails,
    this.selectedFiles = const [],
  });

  /// First selected receipt, or null.
  PlatformFile? get selectedFile => selectedFiles.isEmpty ? null : selectedFiles.first;

  bool get canAddMoreFiles => selectedFiles.length < kMaxReceiptImages;

  @override
  List<Object?> get props => [bankDetails, selectedFiles];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial({
    super.bankDetails,
    super.selectedFiles,
  });
}

class FileSelected extends PaymentState {
  const FileSelected({
    required List<PlatformFile> files,
    super.bankDetails,
  }) : super(selectedFiles: files);
}

class Uploading extends PaymentState {
  final double progress;

  const Uploading({
    required this.progress,
    List<PlatformFile> files = const [],
    super.bankDetails,
  }) : super(selectedFiles: files);

  @override
  List<Object?> get props => [progress, selectedFiles, bankDetails];
}

class UploadSuccess extends PaymentState {
  final PaymentEntity payment;
  final PaymentMethod method;

  const UploadSuccess({
    required this.payment,
    List<PlatformFile> files = const [],
    this.method = PaymentMethod.bankTransfer,
    super.bankDetails,
  }) : super(selectedFiles: files);

  @override
  List<Object?> get props => [payment, method, selectedFiles, bankDetails];
}

class UploadError extends PaymentState {
  final String message;

  const UploadError({
    required this.message,
    super.selectedFiles,
    super.bankDetails,
  });

  @override
  List<Object?> get props => [message, selectedFiles, bankDetails];
}
