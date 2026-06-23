import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../../events/domain/entities/event_entity.dart';
import '../../../scanner/presentation/cubit/scanner_cubit.dart';
import '../../../scanner/presentation/screens/qr_scanner_screen.dart';
import '../../data/scanner_assignment.dart';
import '../cubit/scanner_auth_cubit.dart';
import '../cubit/scanner_auth_state.dart';

/// Dedicated scanner-staff entry: log in with scanner credentials, then pick
/// an assigned venue to start venue-mode check-in.
class ScannerStaffScreen extends StatelessWidget {
  const ScannerStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ScannerAuthCubit>()..checkSession(),
      child: const _ScannerStaffView(),
    );
  }
}

class _ScannerStaffView extends StatefulWidget {
  const _ScannerStaffView();

  @override
  State<_ScannerStaffView> createState() => _ScannerStaffViewState();
}

class _ScannerStaffViewState extends State<_ScannerStaffView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    await context.read<ScannerAuthCubit>().login(
          _emailController.text,
          _passwordController.text,
        );
  }

  void _openVenue(ScannerAssignment a) {
    final event = EventEntity(
      id: '${a.eventId ?? 0}',
      name: (a.eventTitle != null && a.eventTitle!.isNotEmpty)
          ? a.eventTitle!
          : a.venueName,
      type: '',
      date: a.eventDate ?? '',
      time: a.eventTime ?? '',
      venue: a.venueName,
      venueId: a.venueId,
      invitations: 0,
      responses: 0,
      attending: 0,
      status: EventStatus.active,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<ScannerCubit>(),
          child: QRScannerScreen(
            event: event,
            scannerVenueId: a.venueId,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.overlayBg,
      appBar: AppBar(
        title: Text(_isArabic ? 'دخول الماسح (موظف)' : 'Scanner Staff'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<ScannerAuthCubit, ScannerAuthState>(
            builder: (context, state) {
              if (!state.isAuthenticated) return const SizedBox.shrink();
              return IconButton(
                tooltip: _isArabic ? 'تسجيل خروج' : 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: () => context.read<ScannerAuthCubit>().logout(),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ScannerAuthCubit, ScannerAuthState>(
        listenWhen: (p, c) =>
            c.errorMessage != null && c.errorMessage != p.errorMessage,
        listener: (context, state) =>
            AppSnackBar.showError(context, message: state.errorMessage!),
        builder: (context, state) {
          if (state.isLoading && !state.isAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!state.isAuthenticated) {
            return _buildLoginForm(context, state);
          }
          return _buildAssignments(context, state);
        },
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, ScannerAuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Icon(Icons.qr_code_scanner, size: 64, color: AppColors.primaryColor),
          const SizedBox(height: 12),
          Text(
            _isArabic
                ? 'سجّل دخولك بحساب الماسح للوصول لقاعاتك المخصّصة'
                : 'Sign in with your scanner account to access your assigned venues',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: _isArabic ? 'البريد الإلكتروني' : 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(
              labelText: _isArabic ? 'كلمة المرور' : 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_isArabic ? 'دخول' : 'Sign in'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignments(BuildContext context, ScannerAuthState state) {
    if (state.assignments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<ScannerAuthCubit>().loadAssignments(),
        child: ListView(
          children: [
            SizedBox(height: context.dynamicHeight(0.2)),
            Icon(Icons.event_busy,
                size: 56, color: context.iconSecondary),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _isArabic ? 'لا توجد قاعات مخصّصة' : 'No assigned venues',
                style: TextStyle(color: context.textSecondary, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ScannerAuthCubit>().loadAssignments(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.assignments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final a = state.assignments[index];
          return Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                child: Icon(Icons.location_on, color: AppColors.primaryColor),
              ),
              title: Text(
                a.venueName.isNotEmpty
                    ? a.venueName
                    : (_isArabic ? 'قاعة' : 'Venue'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: a.eventTitle != null && a.eventTitle!.isNotEmpty
                  ? Text(a.eventTitle!)
                  : null,
              trailing: const Icon(Icons.qr_code_scanner),
              onTap: () => _openVenue(a),
            ),
          );
        },
      ),
    );
  }
}
