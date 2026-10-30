import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:maktoob/features/payment/domain/entities/bank_details_entity.dart';
import 'package:maktoob/features/payment/domain/entities/payment_entity.dart';
import 'package:maktoob/features/payment/domain/entities/payment_method.dart';
import 'package:maktoob/features/payment/domain/repositories/payment_repository.dart';
import 'package:maktoob/features/payment/domain/usecases/get_bank_details_usecase.dart';
import 'package:maktoob/features/payment/domain/usecases/upload_invoice_usecase.dart';
import 'package:maktoob/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:maktoob/features/payment/presentation/cubit/payment_state.dart';

import '../../../../helpers/fake_platform_file.dart';

class _Call {
  final List<PlatformFile> files;
  final String eventId;
  final PaymentMethod method;
  final String? walletProvider;

  _Call(this.files, this.eventId, this.method, this.walletProvider);
}

class _RecordingRepository implements PaymentRepository {
  final calls = <_Call>[];

  @override
  Future<Either<Failure, PaymentEntity>> uploadInvoice({
    List<PlatformFile> files = const [],
    required String eventId,
    PaymentMethod method = PaymentMethod.bankTransfer,
    String? walletProvider,
    String? endpoint,
  }) async {
    calls.add(_Call(files, eventId, method, walletProvider));
    return Right(PaymentEntity(
      id: '1',
      fileName: files.isEmpty ? '' : files.first.name,
      fileSize: files.isEmpty ? 0 : files.first.lengthSync() ?? 0,
      fileExtension: '',
      uploadedAt: DateTime(2026),
      status: PaymentStatus.uploaded,
    ));
  }

  @override
  Future<Either<Failure, BankDetailsEntity>> getBankDetails() async => const Right(BankDetailsEntity());

  @override
  Stream<double> getUploadProgress() => const Stream.empty();
}

PlatformFile _img(String name) => FakePlatformFile(name: name, size: name.length, path: '/tmp/$name');

void main() {
  late _RecordingRepository repo;
  late PaymentCubit cubit;

  setUp(() {
    repo = _RecordingRepository();
    cubit = PaymentCubit(
      uploadInvoiceUseCase: UploadInvoiceUseCase(repo),
      getBankDetailsUseCase: GetBankDetailsUseCase(repo),
    );
  });

  tearDown(() => cubit.close());

  group('cubit submission', () {
    test('cash submits without a receipt', () async {
      await cubit.uploadInvoice(eventId: '42', method: PaymentMethod.cash, walletProvider: 'ignored');

      final call = repo.calls.single;
      expect(call.method, PaymentMethod.cash);
      expect(call.files, isEmpty);
      expect(call.walletProvider, isNull);
      expect(cubit.state, isA<UploadSuccess>());
      expect((cubit.state as UploadSuccess).method, PaymentMethod.cash);
    });

    test('wallet without a receipt is refused before any request', () async {
      await cubit.uploadInvoice(eventId: '42', method: PaymentMethod.wallet, walletProvider: 'Wallet A');

      expect(repo.calls, isEmpty);
      expect(cubit.state, isA<UploadError>());
    });

    test('cash ignores any selected receipts', () async {
      cubit.addFiles([_img('a.jpg')]);
      await cubit.uploadInvoice(eventId: '42', method: PaymentMethod.cash);

      expect(repo.calls.single.files, isEmpty);
    });

    test('bank transfer sends every selected receipt', () async {
      cubit.addFiles([_img('a.jpg'), _img('b.png')]);
      cubit.addFiles([_img('c.jpeg')]);
      await cubit.uploadInvoice(eventId: '42', method: PaymentMethod.bankTransfer);

      expect(repo.calls.single.files.map((f) => f.name), ['a.jpg', 'b.png', 'c.jpeg']);
      expect(cubit.state, isA<UploadSuccess>());
    });
  });

  group('multiple receipts', () {
    test('caps the selection at $kMaxReceiptImages and skips duplicates', () {
      cubit.addFiles([_img('a.jpg'), _img('a.jpg'), _img('b.jpg')]);
      expect(cubit.state.selectedFiles.map((f) => f.name), ['a.jpg', 'b.jpg']);
      expect(cubit.state.canAddMoreFiles, isTrue);

      cubit.addFiles([_img('c.jpg'), _img('d.jpg')]);
      expect(cubit.state.selectedFiles.map((f) => f.name), ['a.jpg', 'b.jpg', 'c.jpg']);
      expect(cubit.state.canAddMoreFiles, isFalse);
    });

    test('removes one receipt by index, the last one clears the selection', () {
      cubit.addFiles([_img('a.jpg'), _img('b.jpg')]);

      cubit.removeFile(0);
      expect(cubit.state, isA<FileSelected>());
      expect(cubit.state.selectedFiles.map((f) => f.name), ['b.jpg']);

      cubit.removeFile(0);
      expect(cubit.state, isA<PaymentInitial>());
      expect(cubit.state.selectedFiles, isEmpty);
    });
  });

  group('form fields', () {
    test('cash: method only, no wallet_provider', () {
      expect(
        PaymentRemoteDataSourceImpl.buildPaymentRequestFields(
          eventId: '42',
          method: PaymentMethod.cash,
          walletProvider: 'Wallet A',
        ),
        {'event_id': '42', 'payment_method': 'cash'},
      );
    });

    test('wallet: sends the picked provider', () {
      expect(
        PaymentRemoteDataSourceImpl.buildPaymentRequestFields(
          eventId: '42',
          method: PaymentMethod.wallet,
          walletProvider: ' Wallet A ',
        ),
        {'event_id': '42', 'payment_method': 'wallet', 'wallet_provider': 'Wallet A'},
      );
    });

    test('bank transfer', () {
      expect(
        PaymentRemoteDataSourceImpl.buildPaymentRequestFields(eventId: '7', method: PaymentMethod.bankTransfer),
        {'event_id': '7', 'payment_method': 'bank_transfer'},
      );
    });
  });
}
