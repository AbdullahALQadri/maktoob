/// How the host pays for an event. Card gateways do not work in Gaza, so the
/// only options are the ones an admin confirms by hand in the dashboard.
enum PaymentMethod {
  /// Cash handed over in person. No receipt is uploaded.
  cash('cash'),

  /// Bank transfer to the configured IBAN. A receipt is required.
  bankTransfer('bank_transfer'),

  /// Local wallet (Jawwal Pay / PalPay). A receipt is required.
  wallet('wallet');

  /// The value `POST /payment-requests` expects in `payment_method`.
  final String apiValue;

  const PaymentMethod(this.apiValue);

  bool get requiresReceipt => this != PaymentMethod.cash;
}
