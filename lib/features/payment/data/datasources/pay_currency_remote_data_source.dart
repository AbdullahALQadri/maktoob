import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../domain/entities/pay_currency.dart';
import '../models/pay_currency_model.dart';

abstract class PayCurrencyRemoteDataSource {
  Future<PayCurrencies> currenciesFor(String eventId);
}

class PayCurrencyRemoteDataSourceImpl implements PayCurrencyRemoteDataSource {
  PayCurrencyRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<PayCurrencies> currenciesFor(String eventId) async {
    final response = await apiConsumer.get(
      Endpoints.paymentRequestCurrencies,
      queryParameters: {'event_id': eventId},
    );
    return PayCurrencyModel.listFromJson(response);
  }
}
