import 'exceptions.dart';

/// The backend's "free trial already used" texts
/// (`messages.activation_free_trial_used` in ar / en).
const List<String> kFreeTrialRefusalMessages = [
  'استخدمت تجربتك المجانية من قبل على هذا الرقم. اختر باقة للمتابعة.',
  'This phone number has already used its free trial. Choose a package to continue.',
];

/// True only for the backend's free-trial refusal: a 422 whose `blockers`
/// include `free_trial_used`, or whose `errors.status` carries the
/// free-trial message. Network errors, invalid transitions and other
/// validation failures return false.
bool isFreeTrialRefusal(Object? error) {
  if (error is! ValidationException) return false;
  if (error.blockers.contains('free_trial_used')) return true;
  final status = error.errors['status'] ?? const <String>[];
  return status.any((m) => kFreeTrialRefusalMessages.contains(m.trim()));
}

/// The message to show for a free-trial refusal (the server's own text).
String? freeTrialRefusalMessage(Object? error) {
  if (error is! ValidationException) return null;
  final status = error.errors['status'] ?? const <String>[];
  for (final m in status) {
    if (kFreeTrialRefusalMessages.contains(m.trim())) return m.trim();
  }
  return status.isNotEmpty ? status.first : error.message;
}
