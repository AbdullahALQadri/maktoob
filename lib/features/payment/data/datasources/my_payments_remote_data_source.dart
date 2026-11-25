import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../models/my_payments_model.dart';

abstract class MyPaymentsRemoteDataSource {
  Future<MyPaymentsModel> getMyPayments();
}

class MyPaymentsRemoteDataSourceImpl implements MyPaymentsRemoteDataSource {
  final ApiConsumer apiConsumer;

  MyPaymentsRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<MyPaymentsModel> getMyPayments() async {
    final response = await apiConsumer.get(Endpoints.paymentsOverview);
    return MyPaymentsModel.fromJson(Map<String, dynamic>.from(response as Map));
  }
}
