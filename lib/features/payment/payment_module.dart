import 'package:get_it/get_it.dart';

import 'data/datasources/billing_remote_data_source.dart';
import 'data/datasources/pay_currency_remote_data_source.dart';
import 'data/datasources/payment_remote_data_source.dart';
import 'data/repositories/billing_repository_impl.dart';
import 'data/repositories/pay_currency_repository_impl.dart';
import 'data/repositories/payment_repository_impl.dart';
import 'domain/repositories/billing_repository.dart';
import 'domain/repositories/pay_currency_repository.dart';
import 'domain/repositories/payment_repository.dart';
import 'domain/usecases/billing_usecases.dart';
import 'domain/usecases/get_bank_details_usecase.dart';
import 'domain/usecases/get_pay_currencies_usecase.dart';
import 'domain/usecases/upload_invoice_usecase.dart';
import 'presentation/cubit/pay_currency_cubit.dart';
import 'presentation/cubit/payment_cubit.dart';

/// Paying for an event: the payment request (cash, transfer, wallet), the
/// currency it is paid in, more invitations and the pro-forma invoice.
void registerPaymentModule(GetIt sl) {
  sl
    ..registerLazySingleton<PaymentRemoteDataSource>(() => PaymentRemoteDataSourceImpl(apiConsumer: sl(), dio: sl()))
    ..registerLazySingleton<PaymentRepository>(() => PaymentRepositoryImpl(remoteDataSource: sl()))
    ..registerLazySingleton(() => UploadInvoiceUseCase(sl()))
    ..registerLazySingleton(() => GetBankDetailsUseCase(sl()))
    ..registerFactory(() => PaymentCubit(uploadInvoiceUseCase: sl(), getBankDetailsUseCase: sl()))
    ..registerLazySingleton<PayCurrencyRemoteDataSource>(() => PayCurrencyRemoteDataSourceImpl(apiConsumer: sl()))
    ..registerLazySingleton<PayCurrencyRepository>(() => PayCurrencyRepositoryImpl(remoteDataSource: sl()))
    ..registerLazySingleton(() => GetPayCurrenciesUseCase(sl()))
    ..registerFactory(() => PayCurrencyCubit(getPayCurrencies: sl()))
    ..registerLazySingleton<BillingRemoteDataSource>(() => BillingRemoteDataSourceImpl(apiConsumer: sl()))
    ..registerLazySingleton<BillingRepository>(() => BillingRepositoryImpl(remoteDataSource: sl()))
    ..registerLazySingleton(() => GetUpgradeOptionsUseCase(sl()))
    ..registerLazySingleton(() => GetCustomUpgradeQuoteUseCase(sl()))
    ..registerLazySingleton(() => GetProformaUrlUseCase(sl()));
}
