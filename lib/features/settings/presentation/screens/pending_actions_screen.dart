import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../core/offline/pending_actions_queue.dart';
import '../../../../injection_container.dart' as di;
import '../../../scanner/data/door_session_manager.dart';

/// "بانتظار الإرسال": what this phone did with no connection and has not
/// sent yet (door check-ins and queued actions). Everything here is sent by
/// itself when the connection returns; failed items can be retried or
/// removed.
class PendingActionsScreen extends StatefulWidget {
  const PendingActionsScreen({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const PendingActionsScreen());

  @override
  State<PendingActionsScreen> createState() => _PendingActionsScreenState();
}

class _PendingActionsScreenState extends State<PendingActionsScreen> {
  PendingActionsQueue get _queue => di.sl<PendingActionsQueue>();

  List<PendingAction> _actions = const [];
  int _doorPending = 0;
  bool _loading = true;
  StreamSubscription<int>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _queue.countStream.listen((_) => _load());
    _load();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final actions = await _queue.all();
    final door = await di.sl<DoorSessionManager>().pendingEverywhere();
    if (!mounted) return;
    setState(() {
      _actions = actions;
      _doorPending = door;
      _loading = false;
    });
  }

  Future<void> _sendNow() async {
    setState(() => _loading = true);
    await _queue.flush();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('offline_queue_title')),
        actions: [
          IconButton(
            tooltip: t.translate('offline_queue_send_now'),
            onPressed: _loading ? null : _sendNow,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                children: [
                  Text(t.translate('offline_queue_desc'), style: const TextStyle(color: AppColors.gray600, height: 1.5)),
                  AppSpacing.verticalSpace16,
                  if (_doorPending > 0)
                    _Tile(
                      icon: Icons.door_front_door_outlined,
                      title: t.translate('offline_queue_door').replaceAll('{count}', '$_doorPending'),
                    ),
                  if (_actions.isEmpty && _doorPending == 0)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: AppSpacing.xl),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_done_outlined, size: 48, color: AppColors.green600),
                          AppSpacing.verticalSpace12,
                          Text(t.translate('offline_queue_empty'), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  for (final a in _actions)
                    _Tile(
                      icon: a.failed ? Icons.error_outline : Icons.schedule_send_outlined,
                      color: a.failed ? AppColors.red500 : AppColors.gray700,
                      title: t.translate(a.label),
                      subtitle: a.failed
                          ? '${t.translate('offline_queue_failed')}: ${a.lastError ?? ''}'
                          : '${a.createdAt.hour.toString().padLeft(2, '0')}:${a.createdAt.minute.toString().padLeft(2, '0')}',
                      actions: [
                        if (a.failed)
                          IconButton(
                            tooltip: t.translate('offline_queue_retry'),
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _queue.retry(a.id),
                          ),
                        IconButton(
                          tooltip: t.translate('offline_queue_delete'),
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _queue.remove(a.id),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final List<Widget> actions;

  const _Tile({required this.icon, required this.title, this.subtitle, this.color = AppColors.gray700, this.actions = const []});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            AppSpacing.horizontalSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                  if (subtitle != null) Text(subtitle!, style: const TextStyle(color: AppColors.gray500, fontSize: 12.5)),
                ],
              ),
            ),
            ...actions,
          ],
        ),
      );
}
