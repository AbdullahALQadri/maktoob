import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/upgrade_options.dart';
import '../models/upgrade_options_model.dart';

abstract class BillingRemoteDataSource {
  Future<UpgradeOptions> upgradeOptions(String eventId);
  Future<UpgradeQuote> customUpgradeQuote(String eventId, int invitations);
  Future<String> proformaUrl(String eventId, {String? funder, String? reference});
}

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  BillingRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<UpgradeOptions> upgradeOptions(String eventId) async {
    final response = await apiConsumer.get(Endpoints.upgradeOptions, queryParameters: {'event_id': eventId});
    return UpgradeOptionsModel.options(response);
  }

  @override
  Future<UpgradeQuote> customUpgradeQuote(String eventId, int invitations) async {
    final response = await apiConsumer.get(
      Endpoints.upgradeQuote,
      queryParameters: {'event_id': eventId, 'custom_invitations': invitations},
    );
    return UpgradeOptionsModel.quote(UpgradeOptionsModel.data(response));
  }

  @override
  Future<String> proformaUrl(String eventId, {String? funder, String? reference}) async {
    final response = await apiConsumer.get(
      Endpoints.eventProformaUrl(eventId),
      queryParameters: {
        if (funder != null && funder.isNotEmpty) 'funder': funder,
        if (reference != null && reference.isNotEmpty) 'reference': reference,
      },
    );
    final url = UpgradeOptionsModel.data(response)['url']?.toString() ?? '';
    if (url.isEmpty) throw const ServerException(message: 'proforma_failed');
    return url;
  }
}
