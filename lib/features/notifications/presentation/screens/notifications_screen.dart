import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

/// The host's notification inbox (payment confirmed/rejected, RSVPs,
/// design ready...). Tapping an entry marks it read and, when it belongs to
/// an event, opens that event via [onOpenEvent].
class NotificationsScreen extends StatelessWidget {
  final void Function(String eventId)? onOpenEvent;

  const NotificationsScreen({super.key, this.onOpenEvent});

  /// Pass [cubit] to share it with the caller (the bell's unread badge
  /// follows what is read here); otherwise the screen owns a fresh one.
  static Future<void> open(
    BuildContext context, {
    void Function(String eventId)? onOpenEvent,
    NotificationsCubit? cubit,
  }) {
    final screen = NotificationsScreen(onOpenEvent: onOpenEvent);
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => cubit != null
            ? BlocProvider.value(value: cubit..load(), child: screen)
            : BlocProvider(
                create: (_) => di.sl<NotificationsCubit>()..load(),
                child: screen,
              ),
      ),
    );
  }

  static IconData iconFor(String type) {
    if (type == 'event.activated') return Icons.celebration_outlined;
    if (type.startsWith('payment.approved')) return Icons.verified_outlined;
    if (type.startsWith('payment.')) return Icons.receipt_long_outlined;
    if (type.startsWith('guest.')) return Icons.how_to_reg_outlined;
    if (type.startsWith('image.') || type.startsWith('concepts.')) {
      return Icons.palette_outlined;
    }
    return Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(t.translate('notifications_title')),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) =>
                state is NotificationsLoaded && state.unreadCount > 0
                ? TextButton(
                    onPressed: () =>
                        context.read<NotificationsCubit>().markAllRead(),
                    child: Text(t.translate('notifications_mark_all_read')),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsError) {
            return _Message(
              icon: Icons.cloud_off_outlined,
              text: t.translate('notifications_error'),
              action: TextButton(
                onPressed: () => context.read<NotificationsCubit>().load(),
                child: Text(t.translate('common_retry')),
              ),
            );
          }
          if (state is! NotificationsLoaded) {
            return const Center(child: MkSpinner());
          }
          if (state.items.isEmpty) {
            return _Message(
              icon: Icons.notifications_none_outlined,
              text: t.translate('notifications_empty'),
            );
          }
          final showFooter =
              state.hasMore || state.isLoadingMore || state.loadMoreFailed;
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationsCubit>().load(),
            child: NotificationListener<ScrollNotification>(
              // Load the next page when the end of the list comes near.
              onNotification: (n) {
                if (n.metrics.extentAfter < 300 &&
                    state.hasMore &&
                    !state.isLoadingMore &&
                    !state.loadMoreFailed) {
                  context.read<NotificationsCubit>().loadMore();
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                itemCount: state.items.length + (showFooter ? 1 : 0),
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) => i == state.items.length
                    ? _LoadMoreFooter(
                        failed: state.loadMoreFailed,
                        onRetry: () =>
                            context.read<NotificationsCubit>().loadMore(),
                      )
                    : _NotificationTile(
                        n: state.items[i],
                        onTap: () {
                          final n = state.items[i];
                          context.read<NotificationsCubit>().markRead(n.id);
                          final eventId = n.eventId;
                          if (eventId != null && onOpenEvent != null) {
                            Navigator.of(context).pop();
                            onOpenEvent!(eventId);
                          }
                        },
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The end of the list while more pages exist: a spinner while the next
/// page loads, a retry when it failed.
class _LoadMoreFooter extends StatelessWidget {
  final bool failed;
  final VoidCallback onRetry;

  const _LoadMoreFooter({required this.failed, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: failed
            ? TextButton(
                onPressed: onRetry,
                child: Text(t.translate('common_retry')),
              )
            : const SizedBox(
                width: 24,
                height: 24,
                child: MkSpinner(strokeWidth: 2),
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification n;
  final VoidCallback onTap;

  const _NotificationTile({required this.n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final time = n.createdAt;
    String two(int v) => v.toString().padLeft(2, '0');
    final sender = n.senderName.isNotEmpty
        ? n.senderName
        : t.translate('app_name');
    return Material(
      color: context.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: n.isRead ? context.borderColor : AppColors.primary,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SenderAvatar(icon: NotificationsScreen.iconFor(n.type)),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sender,
                            style: AppTextStyles.caption.copyWith(
                              color: context.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (time != null)
                          Text(
                            '${time.year}/${two(time.month)}/${two(time.day)} ${two(time.hour)}:${two(time.minute)}',
                            textDirection: TextDirection.ltr,
                            style: AppTextStyles.caption.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      n.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: context.textPrimary,
                        fontWeight: n.isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                      ),
                    ),
                    if (n.body.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        n.body,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The platform's mark as the sender's picture, with a small badge that
/// says what the notification is about (payment, RSVP, design...).
class _SenderAvatar extends StatelessWidget {
  final IconData icon;

  const _SenderAvatar({required this.icon});

  static const double _size = 44;
  static const double _badge = 20;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Image.asset(
              'assets/images/logo.png',
              width: _size,
              height: _size,
              fit: BoxFit.cover,
              cacheWidth: 132,
            ),
          ),
          PositionedDirectional(
            end: -4,
            bottom: -4,
            child: Container(
              width: _badge,
              height: _badge,
              decoration: BoxDecoration(
                color: context.cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderColor),
              ),
              child: Icon(icon, size: 12, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;

  const _Message({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.iconSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: context.textSecondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.sm),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
