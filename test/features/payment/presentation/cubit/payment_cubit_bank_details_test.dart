import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/payment/domain/entities/bank_details_entity.dart';
import 'package:maktoob/features/payment/domain/entities/payment_entity.dart';
import 'package:maktoob/features/payment/domain/entities/payment_method.dart';
import 'package:maktoob/features/payment/domain/repositories/payment_repository.dart';
import 'package:maktoob/features/payment/domain/usecases/get_bank_details_usecase.dart';
import 'package:maktoob/features/payment/domain/usecases/upload_invoice_usecase.dart';
import 'package:maktoob/features/payment/presentation/cubit/payment_cubit.dart';

/// Loading payment details must always end in a state the screen can render:
/// a failed request used to emit nothing, leaving the loading skeleton up
/// forever.
class _FakeRepository implements PaymentRepository {
  Either<Failure, BankDetailsEntity> next;
  int calls = 0;

  _FakeRepository(this.next);

  @override
  Future<Either<Failure, BankDetailsEntity>> getBankDetails() async {
    calls++;
    return next;
  }

  @override
  Future<Either<Failure, PaymentEntity>> uploadInvoice({
    List<PlatformFile> files = const [],
    required String eventId,
    PaymentMethod method = PaymentMethod.bankTransfer,
    String? walletProvider,
    String? endpoint,
  }) =>
      throw UnimplementedError();

  @override
  Stream<double> getUploadProgress() => const Stream.empty();
}

void main() {
  PaymentCubit cubitFor(_FakeRepository repo) => PaymentCubit(
        uploadInvoiceUseCase: UploadInvoiceUseCase(repo),
        getBankDetailsUseCase: GetBankDetailsUseCase(repo),
      );

  test('starts in the loading state (no details yet)', () {
    expect(cubitFor(_FakeRepository(const Right(BankDetailsEntity()))).state.bankDetails, isNull);
  });

  test('success exposes the details', () async {
    final cubit = cubitFor(_FakeRepository(const Right(BankDetailsEntity(iban: 'TEST-IBAN-001'))));

    await cubit.loadBankDetails();

    expect(cubit.state.bankDetails?.iban, 'TEST-IBAN-001');
    expect(cubit.state.bankDetails?.loadFailed, isFalse);
  });

  test('failure leaves the loading state with an explicit failed result', () async {
    final cubit = cubitFor(_FakeRepository(const Left(ServerFailure(message: 'boom'))));

    await cubit.loadBankDetails();

    expect(cubit.state.bankDetails, isNotNull, reason: 'null would keep the skeleton up forever');
    expect(cubit.state.bankDetails!.loadFailed, isTrue);
  });

  test('retry after a failure goes back to loading, then shows the result', () async {
    final repo = _FakeRepository(const Left(ServerFailure(message: 'boom')));
    final cubit = cubitFor(repo);
    await cubit.loadBankDetails();

    repo.next = const Right(BankDetailsEntity(iban: 'TEST-IBAN-001'));
    final seen = <BankDetailsEntity?>[];
    final sub = cubit.stream.listen((s) => seen.add(s.bankDetails));
    await cubit.loadBankDetails();
    await sub.cancel();

    expect(seen.first, isNull, reason: 'retry shows the loading state first');
    expect(cubit.state.bankDetails?.iban, 'TEST-IBAN-001');
    expect(repo.calls, 2);
  });
}
