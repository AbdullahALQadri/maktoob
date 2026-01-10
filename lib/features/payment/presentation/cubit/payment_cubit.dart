import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/bank_details_entity.dart';
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
  Future<void> loadBankDetails() async {
    final result = await getBankDetailsUseCase(const NoParams());
    result.fold(
      (failure) {
        // Even if bank details fail to load, we don't emit an error state
        // The user can still upload files
      },
      (bankDetails) {
        _bankDetails = bankDetails;
        emit(PaymentInitial(
          bankDetails: bankDetails,
          selectedFile: state.selectedFile,
        ));
      },
    );
  }

  /// Picks a file using the file picker
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        emit(FileSelected(
          file: file,
          bankDetails: _bankDetails,
        ));
      }
    } catch (e) {
      emit(UploadError(
        message: 'Error picking file: $e',
        selectedFile: state.selectedFile,
        bankDetails: _bankDetails,
      ));
    }
  }

  /// Removes the currently selected file
  void removeFile() {
    emit(PaymentInitial(
      bankDetails: _bankDetails,
    ));
  }

  /// Uploads the selected invoice file
  Future<void> uploadInvoice({required String eventId}) async {
    final currentFile = state.selectedFile;
    if (currentFile == null) {
      emit(UploadError(
        message: 'No file selected',
        bankDetails: _bankDetails,
      ));
      return;
    }

    // Start with 0 progress
    emit(Uploading(
      progress: 0.0,
      file: currentFile,
      bankDetails: _bankDetails,
    ));

    // Listen to progress updates
    _progressSubscription?.cancel();
    _progressSubscription = uploadInvoiceUseCase.getUploadProgress().listen(
      (progress) {
        if (state is Uploading) {
          emit(Uploading(
            progress: progress,
            file: currentFile,
            bankDetails: _bankDetails,
          ));
        }
      },
    );

    // Perform the upload
    final result = await uploadInvoiceUseCase(
      UploadInvoiceParams(
        file: currentFile,
        eventId: eventId,
      ),
    );

    _progressSubscription?.cancel();

    result.fold(
      (failure) {
        emit(UploadError(
          message: failure.message ?? 'Upload failed',
          selectedFile: currentFile,
          bankDetails: _bankDetails,
        ));
      },
      (payment) {
        emit(UploadSuccess(
          payment: payment,
          file: currentFile,
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
