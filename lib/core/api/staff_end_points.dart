/// Admin API paths of the staff mode (the Maktoob team): Today, the review
/// queues, and the lists staff look things up in.
class StaffEndpoints {
  StaffEndpoints._();

  static const String adminToday = '/admin/dashboard/today';
  static const String adminPaymentRequests = '/admin/payment-requests';
  static String adminPaymentRequest(int id) => '/admin/payment-requests/$id';
  static String adminPaymentRequestApprove(int id) => '/admin/payment-requests/$id/approve';
  static String adminPaymentRequestReject(int id) => '/admin/payment-requests/$id/reject';
  static const String adminIdentities = '/admin/identity-verifications';
  static String adminIdentity(int id) => '/admin/identity-verifications/$id';
  static String adminIdentityDocument(int id, String side) => '/admin/identity-verifications/$id/document/$side';
  static String adminIdentityApprove(int id) => '/admin/identity-verifications/$id/approve';
  static String adminIdentityReject(int id) => '/admin/identity-verifications/$id/reject';
  static const String adminInstitutions = '/admin/institutions';
  static String adminInstitution(int id) => '/admin/institutions/$id';
  static String adminInstitutionDocument(int id, int documentId) => '/admin/institutions/$id/documents/$documentId';
  static String adminInstitutionApprove(int id) => '/admin/institutions/$id/approve';
  static String adminInstitutionReject(int id) => '/admin/institutions/$id/reject';
  static const String adminClients = '/admin/clients';
  static const String adminEvents = '/admin/events';
}
