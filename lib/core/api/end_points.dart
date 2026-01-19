/// API Endpoints for Maktoob Application
/// Base URL should be updated based on environment
class Endpoints {
  // Base URL - Update this based on your environment
  // For local development: http://10.5.50.103:8000/api/v1
  // For production: https://your-domain.com/api/v1
  static String baseUrl = "https://maktoob.owqy.tech/api/v1";

  // ============================================================
  // PUBLIC ENDPOINTS (No Authentication Required)
  // ============================================================
  static const String publicEventTypes = '/public/event-types';
  static const String publicTemplates = '/public/templates';
  static const String publicPackages = '/public/packages';
  static const String publicConfig = '/public/config';
  static String publicInvitation(String qrCode) => '/public/invitation/$qrCode';
  static String publicInvitationRespond(String qrCode) => '/public/invitation/$qrCode/respond';

  // ============================================================
  // CLIENT AUTHENTICATION
  // ============================================================
  static const String clientRegister = '/auth/register';
  static const String clientLogin = '/auth/login';
  static const String clientLogout = '/auth/logout';
  static const String clientProfile = '/auth/profile';
  static const String clientForgotPassword = '/auth/forgot-password';
  static const String clientVerifyOtp = '/auth/verify-otp';
  static const String clientResetPassword = '/auth/reset-password';
  static const String clientChangePassword = '/auth/change-password';
  static const String clientFcmToken = '/auth/fcm-token';
  static const String clientDeleteAccount = '/auth/account';

  // ============================================================
  // CLIENT - EVENTS
  // ============================================================
  static const String events = '/events';
  static String event(int id) => '/events/$id';
  static String eventStatistics(int id) => '/events/$id/statistics';
  static String eventSendInvitations(int id) => '/events/$id/send-invitations';
  static String eventDuplicate(int id) => '/events/$id/duplicate';

  // ============================================================
  // CLIENT - GUESTS
  // ============================================================
  static const String guests = '/guests';
  static String guest(int id) => '/guests/$id';
  static const String guestsImport = '/guests/import';

  // ============================================================
  // CLIENT - INVITATIONS
  // ============================================================
  static String eventInvitations(int eventId) => '/events/$eventId/invitations';
  static String invitation(int id) => '/invitations/$id';
  static String invitationResend(int id) => '/invitations/$id/resend';
  static String invitationCheckIn(int id) => '/invitations/$id/check-in';

  // ============================================================
  // CLIENT - VENUES
  // ============================================================
  static const String venues = '/venues';
  static String venue(int id) => '/venues/$id';
  static const String venuesSystem = '/venues-system';

  // ============================================================
  // CLIENT - PAYMENTS
  // ============================================================
  static const String payments = '/payments';
  static String payment(int id) => '/payments/$id';
  static const String paymentsInitiate = '/payments/initiate';
  static const String couponsValidate = '/coupons/validate';

  // ============================================================
  // CLIENT - PAYMENT REQUESTS
  // ============================================================
  static const String paymentRequests = '/payment-requests';
  static String paymentRequest(int id) => '/payment-requests/$id';
  static String paymentRequestResubmit(int id) => '/payment-requests/$id/resubmit';

  // ============================================================
  // CLIENT - SCANNER REQUESTS
  // ============================================================
  static const String scannerRequests = '/scanner-requests';
  static String scannerRequest(int id) => '/scanner-requests/$id';

  // ============================================================
  // GUEST AUTHENTICATION (OTP Based)
  // ============================================================
  static const String guestSendOtp = '/guest/auth/send-otp';
  static const String guestVerifyOtp = '/guest/auth/verify-otp';
  static const String guestLogout = '/guest/auth/logout';
  static const String guestProfile = '/guest/profile';
  static const String guestUpdateProfile = '/guest/profile';
  static const String guestFcmToken = '/guest/fcm-token';

  // ============================================================
  // GUEST - BROWSE (Read-Only)
  // ============================================================
  static const String guestVenues = '/guest/venues';
  static String guestVenue(int id) => '/guest/venues/$id';
  static const String guestEvents = '/guest/events';
  static String guestEvent(int id) => '/guest/events/$id';
  static const String guestScanQr = '/guest/scan-qr';

  // ============================================================
  // SCANNER AUTHENTICATION
  // ============================================================
  static const String scannerLogin = '/scanner/auth/login';
  static const String scannerLogout = '/scanner/auth/logout';
  static const String scannerProfile = '/scanner/auth/profile';
  static const String scannerFcmToken = '/scanner/auth/fcm-token';

  // ============================================================
  // SCANNER - ASSIGNMENTS
  // ============================================================
  static const String scannerAssignments = '/scanner/assignments';
  static const String scannerAssignmentsActive = '/scanner/assignments/active';

  // ============================================================
  // SCANNER - VENUES & EVENTS
  // ============================================================
  static const String scannerVenues = '/scanner/venues';
  static String scannerVenue(int id) => '/scanner/venues/$id';
  static String scannerVenueEvents(int venueId) => '/scanner/venues/$venueId/events';

  // ============================================================
  // SCANNER - CHECK-IN
  // ============================================================
  static const String scannerScan = '/scanner/scan';
  static const String scannerCheckIn = '/scanner/check-in';
  static String scannerAttendance(int venueId) => '/scanner/attendance/$venueId';
  static const String scannerHistory = '/scanner/history';

  // ============================================================
  // ADMIN AUTHENTICATION
  // ============================================================
  static const String adminLogin = '/admin/auth/login';
  static const String adminLogout = '/admin/auth/logout';
  static const String adminProfile = '/admin/auth/profile';
  static const String adminUpdateProfile = '/admin/auth/profile';
  static const String adminChangePassword = '/admin/auth/change-password';

  // ============================================================
  // ADMIN - DASHBOARD
  // ============================================================
  static const String adminDashboardStats = '/admin/dashboard/statistics';
  static const String adminDashboardActivity = '/admin/dashboard/recent-activity';

  // ============================================================
  // ADMIN - CLIENTS
  // ============================================================
  static const String adminClients = '/admin/clients';
  static String adminClient(int id) => '/admin/clients/$id';
  static String adminClientToggleStatus(int id) => '/admin/clients/$id/toggle-status';
  static String adminClientVerify(int id) => '/admin/clients/$id/verify';

  // ============================================================
  // ADMIN - EVENTS
  // ============================================================
  static const String adminEvents = '/admin/events';
  static String adminEvent(int id) => '/admin/events/$id';
  static String adminEventStatistics(int id) => '/admin/events/$id/statistics';

  // ============================================================
  // ADMIN - VENUES
  // ============================================================
  static const String adminVenues = '/admin/venues';
  static String adminVenue(int id) => '/admin/venues/$id';
  static String adminVenueToggleStatus(int id) => '/admin/venues/$id/toggle-status';

  // ============================================================
  // ADMIN - USERS
  // ============================================================
  static const String adminUsers = '/admin/users';
  static const String adminUsersRoles = '/admin/users/roles';
  static String adminUser(int id) => '/admin/users/$id';
  static String adminUserToggleStatus(int id) => '/admin/users/$id/toggle-status';

  // ============================================================
  // ADMIN - PAYMENTS
  // ============================================================
  static const String adminPayments = '/admin/payments';
  static const String adminPaymentsReport = '/admin/payments/report';
  static String adminPayment(int id) => '/admin/payments/$id';
  static String adminPaymentStatus(int id) => '/admin/payments/$id/status';

  // ============================================================
  // ADMIN - PAYMENT REQUESTS
  // ============================================================
  static const String adminPaymentRequests = '/admin/payment-requests';
  static String adminPaymentRequest(int id) => '/admin/payment-requests/$id';
  static String adminPaymentRequestApprove(int id) => '/admin/payment-requests/$id/approve';
  static String adminPaymentRequestReject(int id) => '/admin/payment-requests/$id/reject';

  // ============================================================
  // LEGACY ENDPOINTS (For backward compatibility)
  // ============================================================
  static const String stripeSetupEndpoint = '/stripe/setup';
  static const String stripeConfirmEndpoint = '/stripe/confirm';
}
