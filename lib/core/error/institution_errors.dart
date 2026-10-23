import 'exceptions.dart';

/// Machine code the backend uses for a pending / rejected institution:
/// 403 `code` on `POST /events/{id}/invitations`, and an activation
/// `blockers` entry on `/event-wizard/{id}/activate` and the free save.
const String kInstitutionNotApproved = 'institution_not_approved';

/// Translation key with the clear explanation shown to the user.
const String kInstitutionNotApprovedMessageKey = 'institution_not_approved_message';

/// True for either form of the institution-approval refusal.
bool isInstitutionNotApproved(Object? error) {
  if (error is InstitutionNotApprovedException) return true;
  if (error is ValidationException) {
    return error.blockers.contains(kInstitutionNotApproved);
  }
  return false;
}
