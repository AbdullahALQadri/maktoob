import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../data/datasources/door_remote_data_source.dart';
import '../../data/door_session_manager.dart';
import '../../data/lan/lan_protocol.dart';
import '../../domain/entities/door_entities.dart';
import 'qr_camera_screen.dart';

/// Door staff sign in, with no Maktoob account:
///  - the door code the host shared (needs internet once, then works offline);
///  - a scanner account assigned to the venue;
///  - joining the venue hub phone (no internet at all).
class DoorStaffEntryScreen extends StatefulWidget {
  /// The phone is now a door for [session].
  final ValueChanged<DoorSession> onSession;

  const DoorStaffEntryScreen({super.key, required this.onSession});

  @override
  State<DoorStaffEntryScreen> createState() => _DoorStaffEntryScreenState();
}

class _DoorStaffEntryScreenState extends State<DoorStaffEntryScreen> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _scannerToken;
  List<DoorEventInfo> _scannerEvents = const [];

  DoorSessionManager get _manager => di.sl<DoorSessionManager>();

  @override
  void initState() {
    super.initState();
    _manager.defaultDeviceName().then((n) {
      if (mounted && _name.text.isEmpty) _name.text = n;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String get _deviceName => _name.text.trim().isEmpty ? 'Door' : _name.text.trim();

  Future<void> _run(Future<DoorSession?> Function() action) async {
    final t = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final session = await action();
      if (session != null && mounted) widget.onSession(session);
    } on DoorHttpException catch (e) {
      if (!mounted) return;
      final key = switch (e.kind) {
        DoorErrorKind.network => 'door_staff_error_network',
        DoorErrorKind.auth => 'door_staff_error_login',
        _ => 'door_staff_error_${e.code ?? 'refused'}',
      };
      final text = t.translate(key);
      AppSnackBar.showError(context, message: text == key ? (e.message ?? t.translate('door_reason_refused')) : text);
    } catch (_) {
      if (mounted) AppSnackBar.showError(context, message: t.translate('door_reason_refused'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _pair() {
    if (_code.text.trim().length < 6) return;
    _run(() => _manager.pairWithCode(_code.text.trim(), _deviceName));
  }

  void _scanCode() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QRCameraScreen(onQRCodeScanned: (raw) {
        final join = LanJoinInfo.decode(raw);
        if (join != null) {
          _run(() => _manager.joinHub(join, _deviceName));
        } else {
          _code.text = raw.trim();
          _pair();
        }
      }),
    ));
  }

  void _scannerLogin() {
    _run(() async {
      final (token, events) = await _manager.scannerLogin(_email.text.trim(), _password.text);
      setState(() {
        _scannerToken = token;
        _scannerEvents = events;
      });
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('door_staff_title'))),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          children: [
            if (_busy) const LinearProgressIndicator(minHeight: 2),
            Text(t.translate('door_staff_desc'), style: const TextStyle(color: AppColors.gray700, height: 1.5)),
            AppSpacing.verticalSpace16,
            TextField(
              key: const Key('door_staff_name'),
              controller: _name,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: t.translate('door_staff_device_name'),
                hintText: t.translate('door_staff_device_name_hint'),
              ),
            ),
            AppSpacing.verticalSpace8,
            _Section(
              icon: Icons.key_outlined,
              title: t.translate('door_staff_code_title'),
              desc: t.translate('door_staff_code_desc'),
              children: [
                TextField(
                  key: const Key('door_staff_code'),
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(labelText: t.translate('door_staff_code_field'), hintText: 'ABCDE-12345'),
                  onSubmitted: (_) => _pair(),
                ),
                AppSpacing.verticalSpace12,
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('door_staff_pair'),
                        onPressed: _pair,
                        child: Text(t.translate('door_staff_pair')),
                      ),
                    ),
                    AppSpacing.horizontalSpace8,
                    IconButton.outlined(
                      tooltip: t.translate('door_staff_scan_code'),
                      onPressed: _scanCode,
                      icon: const Icon(Icons.qr_code_scanner),
                    ),
                  ],
                ),
              ],
            ),
            _Section(
              icon: Icons.router_outlined,
              title: t.translate('door_staff_join_title'),
              desc: t.translate('door_staff_join_desc'),
              children: [
                OutlinedButton.icon(
                  key: const Key('door_staff_join'),
                  onPressed: _scanCode,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(t.translate('door_join_scan_title')),
                ),
              ],
            ),
            _Section(
              icon: Icons.badge_outlined,
              title: t.translate('door_staff_scanner_title'),
              desc: t.translate('door_staff_scanner_desc'),
              children: [
                if (_scannerToken == null) ...[
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(labelText: t.translate('door_staff_email')),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(labelText: t.translate('door_staff_password')),
                  ),
                  AppSpacing.verticalSpace12,
                  OutlinedButton(onPressed: _scannerLogin, child: Text(t.translate('door_staff_scanner_login'))),
                ] else if (_scannerEvents.isEmpty)
                  Text(t.translate('door_staff_no_events'), style: const TextStyle(color: AppColors.gray600))
                else ...[
                  Text(t.translate('door_staff_choose_event'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  for (final e in _scannerEvents)
                    ListTile(
                      contentPadding: EdgeInsetsDirectional.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: Text(e.title),
                      subtitle: e.eventDate == null ? null : Text(e.eventDate!.toLocal().toString().substring(0, 16)),
                      onTap: () => _run(() => _manager.scannerSession(_scannerToken!, e, _deviceName)),
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final List<Widget> children;

  const _Section({required this.icon, required this.title, required this.desc, required this.children});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryDark),
                AppSpacing.horizontalSpace8,
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
              ],
            ),
            AppSpacing.verticalSpace4,
            Text(desc, style: const TextStyle(color: AppColors.gray600, height: 1.4)),
            AppSpacing.verticalSpace12,
            ...children,
          ],
        ),
      );
}
