import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/api/api_consumer.dart';
import 'package:maktoob/core/api/event_wizard_api_service.dart';
import 'package:maktoob/features/invitation/data/models/invoice_model.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_cubit.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_state.dart';
import 'package:maktoob/features/invitation/presentation/screens/page3_review_submit_screen.dart';

class _FakeApi implements ApiConsumer {
  final calls = <String>[];
  final bodies = <Map<String, dynamic>?>[];
  final bool freeTrialAvailable;
  _FakeApi({this.freeTrialAvailable = true});

  dynamic _answer(String path) {
    if (path.endsWith('/packages')) {
      return {
        'success': true,
        'data': {
          'guest_count': 3,
          'free_trial_available': freeTrialAvailable,
          'suggested_package_id': 2,
          'packages': [
            {'id': 1, 'name_ar': 'تجربة', 'name_en': 'Trial', 'price': 0, 'invitations_limit': 1, 'is_free': true, 'is_available': freeTrialAvailable},
            {'id': 2, 'name_ar': 'أساسية', 'name_en': 'Basic', 'price': '50.00', 'invitations_limit': 50, 'is_available': true},
          ],
        },
      };
    }
    return {'success': true, 'data': {'event_types': []}};
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    calls.add('GET $path');
    return _answer(path);
  }

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async {
    calls.add('POST $path');
    bodies.add(body);
    return _answer(path);
  }

  @override
  Future<dynamic> put(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async => _answer(path);
  @override
  Future<dynamic> delete(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async => _answer(path);
  @override
  Future<dynamic> postWithImage(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async => _answer(path);
  @override
  Future<dynamic> postCreateService(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async => _answer(path);
  @override
  Future<dynamic> postRegister(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async => _answer(path);
}

Future<InvitationCubit> _ready(_FakeApi api) async {
  final cubit = InvitationCubit(apiService: EventWizardApiService(apiConsumer: api));
  await cubit.initializeWizard(draftEventId: 7);
  await cubit.loadPackages();
  return cubit;
}

void main() {
  test('packages carry the backend limit and free-trial availability', () async {
    final cubit = await _ready(_FakeApi());
    final trial = cubit.state.availablePackages.firstWhere((p) => p.id == 1);
    expect(trial.invitationLimit, 1);
    expect(trial.isFree, isTrue);
    expect(cubit.state.freeTrialAvailable, isTrue);
    expect(cubit.state.suggestedPackageId, 2);
  });

  test('used free trial is not selectable', () async {
    final cubit = await _ready(_FakeApi(freeTrialAvailable: false));
    expect(cubit.state.freeTrialAvailable, isFalse);
    cubit.selectPackage(cubit.state.availablePackages.firstWhere((p) => p.id == 1));
    expect(cubit.state.selectedPackage, isNull);
  });

  test('package can be switched, deselected and cleared on the backend', () async {
    final api = _FakeApi();
    final cubit = await _ready(api);
    final trial = cubit.state.availablePackages.firstWhere((p) => p.id == 1);
    final basic = cubit.state.availablePackages.firstWhere((p) => p.id == 2);

    cubit.selectPackage(trial);
    cubit.selectPackage(basic);
    expect(cubit.state.selectedPackage?.id, 2);

    // Tapping the selected package again deselects it.
    cubit.selectPackage(basic);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.selectedPackage, isNull);
    expect(api.calls.last, 'POST /event-wizard/7/package');
    expect(api.bodies.last?.containsKey('package_id'), isFalse);

    cubit.selectPackage(basic);
    await cubit.clearPackage();
    expect(cubit.state.selectedPackage, isNull);
  });

  test('payment amount uses the backend invoice total, no local tax', () {
    const basic = PackageModel(id: 2, name: 'Basic', nameAr: 'أساسية', price: 50);
    const withoutInvoice = InvitationState(selectedPackage: basic);
    expect(wizardInvoiceTotal(withoutInvoice), 50);

    const withInvoice = InvitationState(
      selectedPackage: basic,
      invoiceSummary: InvoiceSummaryModel(
        basePrice: 50, servicesTotal: 0, totalPrice: 57.5, taxRate: 15, taxAmount: 7.5, lineItems: [],
      ),
    );
    expect(wizardInvoiceTotal(withInvoice), 57.5);
  });
}
