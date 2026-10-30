import 'package:dio/dio.dart' show MultipartFile;
import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../models/auth_response_model.dart';

/// Abstract interface for authentication data source
abstract class AuthRemoteDataSource {
  // Client Authentication
  Future<AuthResponseModel> clientLogin(String login, String password);
  Future<AuthResponseModel> clientRegister({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? companyName,
    String? userType,
    String? governorate,
    String? location,
    Map<String, dynamic>? institutionFields,
    String? logoPath,
  });
  Future<AuthResponseModel> clientVerifyOtp(String login, String otp);
  Future<AuthResponseModel> clientForgotPassword(String login);
  Future<void> clientLogout();
  Future<ClientModel> getClientProfile();

  // Client — Additional Operations
  Future<AuthResponseModel> clientResendOtp(String login, {String? purpose});
  Future<AuthResponseModel> clientResetPassword(
      String login, String code, String password);
  Future<void> clientChangePassword(
      String currentPassword, String newPassword);
  Future<void> clientAcceptLegal();
  Future<AuthResponseModel> updateClientProfile({
    String? name,
    String? email,
    String? phone,
    String? companyName,
  });
  Future<AuthResponseModel> uploadClientAvatar(String filePath);
  Future<AuthResponseModel> deleteClientAvatar();
  Future<void> updateFcmToken(String fcmToken);
  Future<void> deleteAccount();

  // Guest Authentication (OTP-based)
  Future<AuthResponseModel> guestSendOtp(String phone);
  Future<AuthResponseModel> guestVerifyOtp(String phone, String otp);
  Future<void> guestLogout();
  Future<GuestUserModel> getGuestProfile();

  // Scanner Authentication
  Future<AuthResponseModel> scannerLogin(String email, String password);
  Future<void> scannerLogout();
  Future<ScannerUserModel> getScannerProfile();

  // Admin Authentication
  Future<AuthResponseModel> adminLogin(String email, String password);
  Future<void> adminLogout();
  Future<AdminUserModel> getAdminProfile();
}

/// Implementation of authentication data source using API consumer
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer apiConsumer;

  AuthRemoteDataSourceImpl({required this.apiConsumer});

  // ============================================================
  // CLIENT AUTHENTICATION
  // ============================================================

  @override
  Future<AuthResponseModel> clientLogin(String login, String password) async {
    final response = await apiConsumer.post(
      Endpoints.clientLogin,
      body: {
        'login': login,
        'password': password,
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<AuthResponseModel> clientRegister({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? companyName,
    String? userType,
    String? governorate,
    String? location,
    Map<String, dynamic>? institutionFields,
    String? logoPath,
  }) async {
    final response = await apiConsumer.post(
      Endpoints.clientRegister,
      body: {
        'name': name,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        // The register screen only submits once "I agree" is ticked.
        'terms_accepted': true,
        if (email != null && email.isNotEmpty) 'email': email,
        'company_name': ?companyName,
        'user_type': ?userType,
        if (governorate != null && governorate.isNotEmpty) 'governorate': governorate,
        if (location != null && location.isNotEmpty) 'location': location,
        // Institution sign-up: organization_name_ar, sector, contact_person...
        ...?institutionFields,
        // A MultipartFile makes DioConsumer send multipart/form-data.
        if (logoPath != null && logoPath.isNotEmpty)
          'logo': await MultipartFile.fromFile(logoPath, filename: logoPath.split('/').last),
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<AuthResponseModel> clientVerifyOtp(String login, String otp) async {
    final response = await apiConsumer.post(
      Endpoints.clientVerifyOtp,
      body: {
        'login': login,
        'code': otp,
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<AuthResponseModel> clientForgotPassword(String login) async {
    final response = await apiConsumer.post(
      Endpoints.clientForgotPassword,
      body: {'login': login},
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<void> clientLogout() async {
    await apiConsumer.post(Endpoints.clientLogout);
  }

  @override
  Future<ClientModel> getClientProfile() async {
    final response = await apiConsumer.get(Endpoints.clientProfile);
    return ClientModel.fromJson(response['client'] ?? response['data']?['client'] ?? response);
  }

  // ============================================================
  // CLIENT — ADDITIONAL OPERATIONS
  // ============================================================

  @override
  Future<AuthResponseModel> clientResendOtp(String login,
      {String? purpose}) async {
    final response = await apiConsumer.post(
      Endpoints.clientResendOtp,
      body: {
        'login': login,
        'purpose': ?purpose,
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<AuthResponseModel> clientResetPassword(
      String login, String code, String password) async {
    final response = await apiConsumer.post(
      Endpoints.clientResetPassword,
      body: {
        'login': login,
        'code': code,
        'password': password,
        'password_confirmation': password,
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<void> clientChangePassword(
      String currentPassword, String newPassword) async {
    await apiConsumer.post(
      Endpoints.clientChangePassword,
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
  }

  @override
  Future<void> clientAcceptLegal() async {
    await apiConsumer.post(
      Endpoints.clientAcceptLegal,
      body: {'terms_accepted': true, 'channel': 'app'},
    );
  }

  @override
  Future<AuthResponseModel> updateClientProfile({
    String? name,
    String? email,
    String? phone,
    String? companyName,
  }) async {
    final response = await apiConsumer.put(
      Endpoints.clientUpdateProfile,
      body: {
        'name': ?name,
        'email': ?email,
        'phone': ?phone,
        'company_name': ?companyName,
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    await apiConsumer.post(
      Endpoints.clientFcmToken,
      body: {'fcm_token': fcmToken},
    );
  }

  @override
  Future<AuthResponseModel> uploadClientAvatar(String filePath) async {
    final response = await apiConsumer.post(
      Endpoints.clientProfileAvatar,
      body: {
        'avatar': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(RegExp(r'[\\/]')).last,
        ),
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<AuthResponseModel> deleteClientAvatar() async {
    final response = await apiConsumer.delete(Endpoints.clientProfileAvatar);
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<void> deleteAccount() async {
    await apiConsumer.delete(Endpoints.clientDeleteAccount);
  }

  // ============================================================
  // GUEST AUTHENTICATION (OTP-based)
  // ============================================================

  @override
  Future<AuthResponseModel> guestSendOtp(String phone) async {
    final response = await apiConsumer.post(
      Endpoints.guestSendOtp,
      body: {'phone': phone},
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<AuthResponseModel> guestVerifyOtp(String phone, String otp) async {
    final response = await apiConsumer.post(
      Endpoints.guestVerifyOtp,
      body: {
        'phone': phone,
        'otp': otp,
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<void> guestLogout() async {
    await apiConsumer.post(Endpoints.guestLogout);
  }

  @override
  Future<GuestUserModel> getGuestProfile() async {
    final response = await apiConsumer.get(Endpoints.guestProfile);
    return GuestUserModel.fromJson(response['guest'] ?? response['data']?['guest'] ?? response);
  }

  // ============================================================
  // SCANNER AUTHENTICATION
  // ============================================================

  @override
  Future<AuthResponseModel> scannerLogin(String email, String password) async {
    final response = await apiConsumer.post(
      Endpoints.scannerLogin,
      body: {
        'email': email,
        'password': password,
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<void> scannerLogout() async {
    await apiConsumer.post(Endpoints.scannerLogout);
  }

  @override
  Future<ScannerUserModel> getScannerProfile() async {
    final response = await apiConsumer.get(Endpoints.scannerProfile);
    final data = response['data'] ?? response;
    return ScannerUserModel.fromJson(data['user'] ?? data);
  }

  // ============================================================
  // ADMIN AUTHENTICATION
  // ============================================================

  @override
  Future<AuthResponseModel> adminLogin(String email, String password) async {
    final response = await apiConsumer.post(
      Endpoints.adminLogin,
      body: {
        'email': email,
        'password': password,
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<void> adminLogout() async {
    await apiConsumer.post(Endpoints.adminLogout);
  }

  @override
  Future<AdminUserModel> getAdminProfile() async {
    final response = await apiConsumer.get(Endpoints.adminProfile);
    final data = response['data'] ?? response;
    return AdminUserModel.fromJson(data['user'] ?? data);
  }
}
