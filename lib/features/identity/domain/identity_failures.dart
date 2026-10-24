import '../../../core/error/failures.dart';

/// A 422 from `POST /auth/identity`, with the first message of each field
/// so the form can show it under the right input.
class IdentityValidationFailure extends ValidationFailure {
  final Map<String, String> fieldErrors;

  const IdentityValidationFailure({super.message, super.code, this.fieldErrors = const {}});

  @override
  List<Object?> get props => [message, code, fieldErrors];
}
