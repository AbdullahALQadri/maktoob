/// API Endpoints for Maktoob Application.
///
/// The base URL is supplied at build time via `--dart-define`:
///
///   flutter run --dart-define=API_BASE_URL=http://172.31.176.1:8000/api/v1   # emulator
///   flutter run --dart-define=API_BASE_URL=http://10.5.50.129:8000/api/v1 # device on LAN
///   flutter build apk --release   # uses the production default below
///
/// Release builds default to HTTPS production. Hardcoding a LAN IP
/// here used to crash release startup (see DioConsumer's HTTPS guard)
/// and shipped a plaintext-HTTP base URL through QA. Don't go back.
class Endpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://maktoob.social/api/v1',
  );

  // ============================================================
  // PUBLIC ENDPOINTS (No Authentication Required)
  // ============================================================
  static const String publicEvents = '/public/events';
  static String publicEvent(int id) => '/public/events/$id';
  static const String publicVenues = '/public/venues';
  static const String publicEventTypes = '/public/event-types';
  static const String publicTemplates = '/public/templates';
  static const String publicPackages = '/public/packages';
  static const String publicConfig = '/public/config';
  static String publicInvitation(String qrCode) => '/public/invitation/$qrCode';
  static String publicInvitationRespond(String qrCode) => '/public/invitation/$qrCode/respond';

  // ============================================================
  // EVENT WIZARD ENDPOINTS
  // ============================================================

  // Page 1 - Event Type & Template Selection
  static const String wizardEventTypes = '/event-wizard/event-types';
  static String wizardEventTypeTemplates(int typeId) => '/event-wizard/event-types/$typeId/templates';
  static const String wizardCustomEventType = '/event-wizard/event-types/custom';
  static const String wizardInitialize = '/event-wizard/initialize';
  static String wizardCustomTemplate(int eventId) => '/event-wizard/$eventId/custom-template';

  // Page 2 - Event Details
  static String wizardFormFields(int eventId) => '/event-wizard/$eventId/form-fields';
  static String wizardSaveDetails(int eventId) => '/event-wizard/$eventId/details';

  // Page 3 - Invitation Preview
  static String wizardPreview(int eventId) => '/event-wizard/$eventId/preview';

  // AI Template Generation (legacy — kept for backwards compat)
  static String wizardGenerateTemplate(int eventId) => '/event-wizard/$eventId/generate-template';
  static String wizardGenerationStatus(int eventId, int imageId) => '/event-wizard/$eventId/generation-status/$imageId';

  // AI Design Studio — two-step generation
  static const String wizardAiImages = '/event-wizard/ai-images';
  static String wizardAiFormFields(int eventTypeId) => '/event-wizard/ai-form-fields/$eventTypeId';
  static String wizardGeneratePrompt(int eventId) => '/event-wizard/$eventId/generate-prompt';
  static String wizardConfirmGenerate(int eventId) => '/event-wizard/$eventId/confirm-generate';
  static String wizardSaveAiImage(int eventId) => '/event-wizard/$eventId/details';

  // Page 4 - Guest Management
  static String wizardGuests(int eventId) => '/event-wizard/$eventId/guests';
  static String wizardGuestsContacts(int eventId) => '/event-wizard/$eventId/guests/import-contacts';
  static String wizardGuestsExcel(int eventId) => '/event-wizard/$eventId/guests/import-excel';
  static String wizardGuestsManual(int eventId) => '/event-wizard/$eventId/guests/manual';
  static String wizardGuestsContactsSelected(int eventId) => '/event-wizard/$eventId/guests/contacts-selected';
  static String wizardGuestDelete(int eventId, int guestId) => '/event-wizard/$eventId/guests/$guestId';
  static String wizardGuestsBulkRemove(int eventId) => '/event-wizard/$eventId/guests/bulk-remove';
  static String wizardGuestsClear(int eventId) => '/event-wizard/$eventId/guests/clear';
  static String wizardGuestsRemoveDuplicates(int eventId) => '/event-wizard/$eventId/guests/remove-duplicates';
  static const String wizardExcelFormat = '/event-wizard/excel-format';

  // Page 4.5 - Invitation Configuration
  static String wizardInvitationConfig(int eventId) => '/event-wizard/$eventId/invitation-config';

  // Page 5 - Extra Services
  static String wizardServices(int eventId) => '/event-wizard/$eventId/services';

  // Page 6 - Packages
  static String wizardPackages(int eventId) => '/event-wizard/$eventId/packages';
  static String wizardSelectPackage(int eventId) => '/event-wizard/$eventId/package';

  // Page 7 - Invoice & Save
  static String wizardInvoice(int eventId) => '/event-wizard/$eventId/invoice';
  static String wizardSave(int eventId) => '/event-wizard/$eventId/save';
  static String wizardState(int eventId) => '/event-wizard/$eventId/state';
  static String wizardActivate(int eventId) => '/event-wizard/$eventId/activate';

  // WhatsApp Configuration
  static const String whatsappConfig = '/config/whatsapp';

  // ============================================================
  // CLIENT AUTHENTICATION
  // ============================================================
  static const String clientRegister = '/auth/register';
  static const String clientLogin = '/auth/login';
  static const String clientLogout = '/auth/logout';
  static const String clientProfile = '/auth/profile';
  static const String clientUpdateProfile = '/auth/profile';
  static const String clientChangeUserType = '/auth/change-user-type';
  static const String clientForgotPassword = '/auth/forgot-password';
  static const String clientVerifyOtp = '/auth/verify-otp';
  static const String clientResendOtp = '/auth/resend-otp';
  static const String clientResetPassword = '/auth/reset-password';
  static const String clientChangePassword = '/auth/change-password';
  static const String clientFcmToken = '/auth/fcm-token';
  static const String clientDeleteAccount = '/auth/account';
  static const String clientRefreshToken = '/auth/refresh-token';

  // ============================================================
  // CLIENT - DASHBOARD
  // ============================================================
  static const String clientDashboardStats = '/client/dashboard/stats';
  static const String clientDashboardRecentEvents =
      '/client/dashboard/recent-events';

  // ============================================================
  // CLIENT - EVENTS
  // ============================================================
  static const String events = '/events';
  static String event(int id) => '/events/$id';
  static String eventStatistics(int id) => '/events/$id/statistics';
  static String eventSendInvitations(int id) => '/events/$id/send-invitations';
  static String eventDuplicate(int id) => '/events/$id/duplicate';
  static String eventEditRequests(int id) => '/events/$id/edit-requests';
  static String editRequest(int id) => '/edit-requests/$id';

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
  static String scannerAssignment(int id) => '/scanner/assignments/$id';

  // ============================================================
  // SCANNER - VENUES & EVENTS
  // ============================================================
  static const String scannerVenues = '/scanner/venues';
  static String scannerVenue(int id) => '/scanner/venues/$id';
  static String scannerVenueEvents(int venueId) => '/scanner/venues/$venueId/events';

  // ============================================================
  // SCANNER - CHECK-IN
  // ============================================================
  static const String scannerScan = '/scanner/check-in/scan';
  static String scannerCheckInVerify(int id) => '/scanner/check-in/$id/verify';
  static const String scannerCheckInHistory = '/scanner/check-in/history';
  static String scannerAttendance(int venueId) => '/scanner/attendance/$venueId';

  // ============================================================
  // ADMIN AUTHENTICATION
  // ============================================================
  static const String adminLogin = '/admin/auth/login';
  static const String adminLogout = '/admin/auth/logout';
  static const String adminProfile = '/admin/auth/profile';
  static const String adminUpdateProfile = '/admin/auth/profile';
  static const String adminChangePassword = '/admin/auth/change-password';

  // Admin management endpoints: add when admin panel feature is implemented.
}
