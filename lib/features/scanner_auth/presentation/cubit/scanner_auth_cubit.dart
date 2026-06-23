import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/utils/storage/secure_storage_service.dart';
import '../../data/scanner_assignment.dart';
import 'scanner_auth_state.dart';

/// Manages the dedicated scanner-staff session: login (separate token),
/// listing the staff member's active venue assignments, and logout.
class ScannerAuthCubit extends Cubit<ScannerAuthState> {
  final ApiConsumer api;
  final SecureStorageService storage;

  ScannerAuthCubit({required this.api, required this.storage})
      : super(const ScannerAuthState());

  /// Restore a previous scanner session if a token is already stored.
  Future<void> checkSession() async {
    final token = await storage.getScannerToken();
    if (token != null && token.isNotEmpty) {
      emit(state.copyWith(isAuthenticated: true));
      await loadAssignments();
    }
  }

  Future<bool> login(String email, String password) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final res = await api.post(
        Endpoints.scannerLogin,
        body: {'email': email.trim(), 'password': password},
      );
      final data = res['data'] ?? res;
      final token = (data is Map ? data['token'] : null) as String?;
      if (token == null || token.isEmpty) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Login failed'));
        return false;
      }
      await storage.saveScannerToken(token);
      emit(state.copyWith(isLoading: false, isAuthenticated: true));
      await loadAssignments();
      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _message(e)));
      return false;
    }
  }

  Future<void> loadAssignments() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final res = await api.get(Endpoints.scannerAssignmentsActive);
      final data = res['data'] ?? res;
      final list = (data is Map ? data['assignments'] : data) as List? ?? [];
      final assignments = list
          .map((a) => ScannerAssignment.fromJson(Map<String, dynamic>.from(a as Map)))
          .toList();
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        assignments: assignments,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _message(e)));
    }
  }

  Future<void> logout() async {
    try {
      await api.post(Endpoints.scannerLogout);
    } catch (_) {
      // Best-effort; clear locally regardless.
    }
    await storage.clearScannerToken();
    emit(const ScannerAuthState());
  }

  String _message(Object e) {
    final s = e.toString();
    return s.replaceFirst('Exception: ', '');
  }
}
