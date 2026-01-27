import '../models/auth_response_model.dart';
import 'auth_remote_data_source.dart';

/// Mock implementation for UI testing without API.
/// Swap this in [injection_container.dart] to test all screens.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  static const _mockToken = 'mock-token-for-ui-testing';

  static const _mockClient = ClientModel(
    id: 1,
    name: 'Test User',
    email: 'test@maktoob.com',
    phone: '07801234567',
    isVerified: true,
    locale: 'ar',
  );

  // ── Client ──

  @override
  Future<AuthResponseModel> clientLogin(String login, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const AuthResponseModel(
      success: true,
      message: 'Login successful',
      token: _mockToken,
      data: {
        'client': {
          'id': 1,
          'name': 'Test User',
          'email': 'test@maktoob.com',
          'phone': '07801234567',
          'is_verified': true,
          'locale': 'ar',
        },
      },
    );
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
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthResponseModel(
      success: true,
      message: 'Registration successful',
      token: _mockToken,
      data: {
        'client': {
          'id': 2,
          'name': name,
          'email': email ?? '',
          'phone': phone,
          'is_verified': false,
          'locale': 'ar',
        },
      },
    );
  }

  @override
  Future<AuthResponseModel> clientVerifyOtp(String login, String otp) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AuthResponseModel(
      success: true,
      message: 'OTP verified',
      token: _mockToken,
    );
  }

  @override
  Future<AuthResponseModel> clientForgotPassword(String login) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AuthResponseModel(
      success: true,
      message: 'Password reset link sent',
    );
  }

  @override
  Future<void> clientLogout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<ClientModel> getClientProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockClient;
  }

  // ── Guest ──

  @override
  Future<AuthResponseModel> guestSendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AuthResponseModel(
      success: true,
      message: 'OTP sent',
    );
  }

  @override
  Future<AuthResponseModel> guestVerifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AuthResponseModel(
      success: true,
      message: 'OTP verified',
      token: _mockToken,
    );
  }

  @override
  Future<void> guestLogout() async {}

  @override
  Future<GuestUserModel> getGuestProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const GuestUserModel(
      id: 1,
      name: 'Guest User',
      phone: '07801234567',
      email: 'guest@maktoob.com',
    );
  }

  // ── Scanner ──

  @override
  Future<AuthResponseModel> scannerLogin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AuthResponseModel(
      success: true,
      message: 'Scanner login successful',
      token: _mockToken,
    );
  }

  @override
  Future<void> scannerLogout() async {}

  @override
  Future<ScannerUserModel> getScannerProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const ScannerUserModel(
      id: 1,
      name: 'Scanner User',
      email: 'scanner@maktoob.com',
      activeAssignmentsCount: 3,
    );
  }

  // ── Admin ──

  @override
  Future<AuthResponseModel> adminLogin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AuthResponseModel(
      success: true,
      message: 'Admin login successful',
      token: _mockToken,
    );
  }

  @override
  Future<void> adminLogout() async {}

  @override
  Future<AdminUserModel> getAdminProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AdminUserModel(
      id: 1,
      name: 'Admin User',
      email: 'admin@maktoob.com',
      isSuperAdmin: true,
      roles: ['admin'],
      permissions: ['all'],
    );
  }
}
