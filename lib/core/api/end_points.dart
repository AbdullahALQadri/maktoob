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
  static const String customPackageCalculate = '/custom-package/calculate';
  static const String publicPackages = '/public/packages';
  static const String publicConfig = '/public/config';
  static String publicInvitation(String qrCode) => '/public/invitation/$qrCode';
  static String publicInvitationRespond(String qrCode) => '/public/invitation/$qrCode/respond';

  // ============================================================
  // EVENT WIZARD ENDPOINTS
  // ============================================================

  // Page 1 - Event Type & Template Selection
  static const String wizardEventTypes = '/event-wizard/event-types';
  static const String wizardCustomEventType = '/event-wizard/event-types/custom';
  static const String wizardInitialize = '/event-wizard/initialize';

  // Page 2 - Event Details
  static String wizardFormFields(int eventId) => '/event-wizard/$eventId/form-fields';
  static String wizardSaveDetails(int eventId) => '/event-wizard/$eventId/details';

  // Page 3 - Invitation Preview
  static String wizardPreview(int eventId) => '/event-wizard/$eventId/preview';

  // AI Template Generation (legacy — kept for backwards compat)
  static String wizardGenerationStatus(int eventId, int imageId) => '/event-wizard/$eventId/generation-status/$imageId';

  // AI Design Studio — two-step generation
  static const String wizardAiImages = '/event-wizard/ai-images';
  static String wizardAiFormFields(int eventTypeId) => '/event-wizard/ai-form-fields/$eventTypeId';
  static String wizardGeneratePrompt(int eventId) => '/event-wizard/$eventId/generate-prompt';
  static String wizardConfirmGenerate(int eventId) => '/event-wizard/$eventId/confirm-generate';
  static String wizardUploadDesign(int eventId) => '/event-wizard/$eventId/upload-design';
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

  /// Extra services on a paid event: GET/POST list + request, DELETE withdraw,
  /// POST pay (multipart, like /payment-requests). Pays only the services.
  static String eventAddOns(int eventId) => '/events/$eventId/add-ons';
  static String eventAddOn(int eventId, int serviceId) => '/events/$eventId/add-ons/$serviceId';
  static String eventAddOnsPay(int eventId) => '/events/$eventId/add-ons/pay';

  // Page 6 - Packages
  static String wizardPackages(int eventId) => '/event-wizard/$eventId/packages';
  static String wizardSelectPackage(int eventId) => '/event-wizard/$eventId/package';

  // Page 7 - Invoice & Save
  static String wizardInvoice(int eventId) => '/event-wizard/$eventId/invoice';
  static String wizardSave(int eventId) => '/event-wizard/$eventId/save';
  static String wizardState(int eventId) => '/event-wizard/$eventId/state';
  static String wizardActivate(int eventId) => '/event-wizard/$eventId/activate';


  // ============================================================
  // CLIENT AUTHENTICATION
  // ============================================================
  static const String clientRegister = '/auth/register';
  static const String clientLogin = '/auth/login';
  static const String clientLogout = '/auth/logout';
  static const String clientProfile = '/auth/profile';
  static const String clientUpdateProfile = '/auth/profile';
  /// POST multipart `avatar` to set, DELETE to remove the profile photo.
  static const String clientProfileAvatar = '/auth/profile/avatar';
  static const String clientForgotPassword = '/auth/forgot-password';
  static const String clientVerifyOtp = '/auth/verify-otp';
  static const String clientResendOtp = '/auth/resend-otp';
  static const String clientResetPassword = '/auth/reset-password';
  static const String clientChangePassword = '/auth/change-password';
  static const String clientFcmToken = '/auth/fcm-token';
  /// POST `{terms_accepted: true}`: accept the Terms / Privacy version in force.
  static const String clientAcceptLegal = '/auth/legal/accept';
  static const String clientDeleteAccount = '/auth/account';
  /// GET: identity verification state + form options; POST multipart: a new
  /// submission (document fields, `front`, `back?`, `declaration`).
  static const String clientIdentity = '/auth/identity';

  // ============================================================
  // CLIENT - HOME (same numbers and events as the portal dashboard)
  // ============================================================
  static const String clientHome = '/client/home';
  static const String clientEvents = '/client/events'; // ?status=&q=&page=
  // Event page follow-up (activity, setup steps, resend failed, fix an unsent guest)
  static String eventActivity(String id) => '/events/$id/activity';
  static String eventProgress(String id) => '/events/$id/progress';
  static String eventResendFailed(String id) => '/events/$id/invitations/resend-failed';
  static String unsentGuest(String eventId, String invitationId) => '/events/$eventId/invitations/$invitationId/guest';

  // ============================================================
  // CLIENT - EVENTS
  // ============================================================
  static const String events = '/events';
  static String event(int id) => '/events/$id';
  static String eventStatistics(int id) => '/events/$id/statistics';
  static String eventSendInvitations(int id) => '/events/$id/send-invitations';
  static String eventEditRequests(int id) => '/events/$id/edit-requests';

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

  // In-app notifications (client inbox)
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(int id) => '/notifications/$id/read';
  static String invitation(int id) => '/invitations/$id';
  static String invitationResend(int id) => '/invitations/$id/resend';
  static String eventGuestsAdd(int eventId) => '/events/$eventId/guests/add';
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

  // Institutions (companies & associations)
  static const String institution = '/institution';
  static const String institutionProfile = '/institution/profile';
  static const String institutionMembers = '/institution/members';
  static String institutionMember(int id) => '/institution/members/$id';
  static String institutionInviteAccept(int id) => '/institution/invites/$id/accept';
  static String institutionInvite(int id) => '/institution/invites/$id';
  static const String institutionCredits = '/institution/credits';
  /// POST multipart {type, file}; DELETE /{id} (only before approval).
  static const String institutionDocuments = '/institution/documents';
  static String institutionDocument(int id) => '/institution/documents/$id';
  /// Read-only manual-payment details (bank / wallet / instructions / contacts).
  static const String paymentBankDetails = '/payments/bank-details';
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

  // ============================================================
  // GUEST - BROWSE (Read-Only)
  // ============================================================

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
  static String scannerAttendance(int venueId) => '/scanner/attendance/$venueId';

  // Host self-scan (client token). `/scanner/*` above needs a scanner account.
  static String eventCheckInScan(int eventId) => '/events/$eventId/check-in/scan';
  static String eventCheckInList(int eventId) => '/events/$eventId/guests/check-in-list';

  // ============================================================
  // OFFLINE DOOR (door pack, sync, gates, staff codes)
  // ============================================================
  // The same door API under three roots, by who holds the phone:
  // the host / institution member (client token), a scanner account, or
  // a staff phone paired by a door code (its own token, `/door`).
  static String doorForEvent(int eventId) => '/events/$eventId/door';
  static String doorForScanner(int eventId) => '/scanner/events/$eventId/door';
  static const String doorPaired = '/door';
  static const String doorPair = '/door/pair';
  static const String doorPairedGate = '/door/gate';
  static const String doorPairedLogout = '/door/logout';

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
