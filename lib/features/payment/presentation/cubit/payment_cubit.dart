import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/usecases/get_bank_details_usecase.dart';
import '../../domain/usecases/upload_invoice_usecase.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final UploadInvoiceUseCase uploadInvoiceUseCase;
  final GetBankDetailsUseCase getBankDetailsUseCase;

  StreamSubscription<double>? _progressSubscription;
  BankDetailsEntity? _bankDetails;

  PaymentCubit({
    required this.uploadInvoiceUseCase,
    required this.getBankDetailsUseCase,
  }) : super(const PaymentInitial());

  /// Loads the bank details for display
  ///
  /// `bankDetails == null` means "still loading". A failed request used to
  /// emit nothing, so the screen showed its loading skeleton forever; it now
  /// emits [BankDetailsEntity.loadFailed] so the card can say so and offer a
  /// retry. Receipt upload is unaffected either way.
  Future<void> loadBankDetails() async {
    if (_bankDetails != null) {
      _bankDetails = null; // retry: back to the loading state
      emit(PaymentInitial(selectedFiles: state.selectedFiles));
    }

    final result = await getBankDetailsUseCase(const NoParams());
    result.fold(
      (failure) {
        _bankDetails = const BankDetailsEntity.loadFailed();
        emit(PaymentInitial(
          bankDetails: _bankDetails,
          selectedFiles: state.selectedFiles,
        ));
      },
      (bankDetails) {
        _bankDetails = bankDetails;
        emit(PaymentInitial(
          bankDetails: bankDetails,
          selectedFiles: state.selectedFiles,
        ));
      },
    );
  }

  /// Opens the picker and appends the chosen images (up to
  /// [kMaxReceiptImages] in total).
  Future<void> pickFile() async {
    if (!state.canAddMoreFiles) return;
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        // The backend accepts images only (`invoice_images[]`).
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (files.isNotEmpty) addFiles(files);
    } catch (e) {
      emit(UploadError(
        message: 'Error picking file: $e',
        selectedFiles: state.selectedFiles,
        bankDetails: _bankDetails,
      ));
    }
  }

  /// Appends [files] to the selection, skipping duplicates and capping the
  /// total at [kMaxReceiptImages].
  void addFiles(List<PlatformFile> files) {
    final merged = [...state.selectedFiles];
    for (final f in files) {
      if (merged.length >= kMaxReceiptImages) break;
      final dup = merged.any((m) => m.name == f.name && m.lengthSync() == f.lengthSync() && m.path == f.path);
      if (!dup) merged.add(f);
    }
    emit(FileSelected(files: List.unmodifiable(merged), bankDetails: _bankDetails));
  }

  /// Removes the receipt at [index] (or all receipts when null).
  void removeFile([int? index]) {
    final current = state.selectedFiles;
    if (index == null || current.length <= 1) {
      emit(PaymentInitial(bankDetails: _bankDetails));
      return;
    }
    if (index < 0 || index >= current.length) return;
    final next = [...current]..removeAt(index);
    emit(FileSelected(files: List.unmodifiable(next), bankDetails: _bankDetails));
  }

  /// Submits the payment request for [eventId].
  ///
  /// Cash sends no receipt; bank transfer / wallet need the selected file.
  /// [walletProvider] is the `provider_name` of the wallet the user picked.
  Future<void> uploadInvoice({
    required String eventId,
    PaymentMethod method = PaymentMethod.bankTransfer,
    String? walletProvider,
    String? endpoint,
  }) async {
    final currentFiles =
        method.requiresReceipt ? state.selectedFiles : const <PlatformFile>[];
    if (method.requiresReceipt && currentFiles.isEmpty) {
      emit(UploadError(
        message: 'No file selected',
        bankDetails: _bankDetails,
      ));
      return;
    }

    // Start with 0 progress
    emit(Uploading(
      progress: 0.0,
      files: currentFiles,
      bankDetails: _bankDetails,
    ));

    // Listen to progress updates
    _progressSubscription?.cancel();
    _progressSubscription = uploadInvoiceUseCase.getUploadProgress().listen(
      (progress) {
        if (state is Uploading) {
          emit(Uploading(
            progress: progress,
            files: currentFiles,
            bankDetails: _bankDetails,
          ));
        }
      },
    );

    // Perform the upload
    final result = await uploadInvoiceUseCase(
      UploadInvoiceParams(
        files: currentFiles,
        eventId: eventId,
        method: method,
        walletProvider: method == PaymentMethod.wallet ? walletProvider : null,
        endpoint: endpoint,
      ),
    );

    _progressSubscription?.cancel();

    result.fold(
      (failure) {
        emit(UploadError(
          message: failure.message ?? 'Upload failed',
          selectedFiles: state.selectedFiles,
          bankDetails: _bankDetails,
        ));
      },
      (payment) {
        emit(UploadSuccess(
          payment: payment,
          files: currentFiles,
          method: method,
          bankDetails: _bankDetails,
        ));
      },
    );
  }

  /// Resets the state to initial
  void reset() {
    emit(PaymentInitial(
      bankDetails: _bankDetails,
    ));
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}
