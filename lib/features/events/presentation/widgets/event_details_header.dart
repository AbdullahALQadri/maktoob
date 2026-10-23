import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/event_model.dart';
import '../../domain/entities/event_entity.dart';

/// Header widget for event details screen.
class EventDetailsHeader extends StatelessWidget {
  final EventEntity event;
  final VoidCallback onBack;
  /// Null hides the action (role without that permission).
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  const EventDetailsHeader({
    super.key,
    required this.event,
    required this.onBack,
    this.onEdit,
    this.onDelete,
    this.onCancel,
  });

  List<Color> get _gradient {
    if (event is EventModel) return (event as EventModel).gradient;
    return [AppColors.primaryColor, AppColors.tertiaryColor];
  }

  IconData get _icon {
    if (event is EventModel) return (event as EventModel).icon;
    return Icons.event;
  }

  // imageUrl lives on EventEntity, so read it directly — the cubit passes an
  // EventEntity (not EventModel), which is why the image wasn't showing.
  String? get _imageUrl => event.imageUrl;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final imageUrl = _imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Event image fills the header behind the content (the gradient on
            // the parent shows through as a fallback / during load / on error).
            if (hasImage) ...[
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox.shrink(),
                  errorWidget: (_, __, error) {
                    debugPrint('EventDetailsHeader image FAILED to load: '
                        '$imageUrl  error=$error');
                    return const SizedBox.shrink();
                  },
                ),
              ),
              // Scrim so the white actions / title / badges stay legible.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            // Content first (determines size)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderActions(
                    onBack: onBack,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onCancel: onCancel,
                    isCompleted: event.status == EventStatus.completed,
                    t: t,
                  ),
                  const SizedBox(height: 20),
                  _EventInfo(event: event, icon: _icon, t: t),
                ],
              ),
            ),
            // Decorative circles (positioned after content for proper sizing)
            Positioned(
              top: -30,
              right: -30,
              child: IgnorePointer(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: IgnorePointer(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final VoidCallback onBack;
  /// Null hides the action (role without that permission).
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;
  final bool isCompleted;
  final AppLocalizations t;

  const _HeaderActions({
    required this.onBack,
    this.onEdit,
    this.onDelete,
    this.onCancel,
    this.isCompleted = false,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(icon: Icons.arrow_back_rounded, onTap: onBack),
        const Spacer(),
        if (onEdit != null || onDelete != null || onCancel != null)
          _MoreOptionsMenu(
            onEdit: onEdit,
            onDelete: onDelete,
            onCancel: onCancel,
            isCompleted: isCompleted,
            t: t,
          ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _MoreOptionsMenu extends StatelessWidget {
  /// Null hides the action (role without that permission).
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;
  final bool isCompleted;
  final AppLocalizations t;

  const _MoreOptionsMenu({
    this.onEdit,
    this.onDelete,
    this.onCancel,
    this.isCompleted = false,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
        if (value == 'cancel') onCancel?.call();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        if (!isCompleted && onEdit != null)
          _buildMenuItem('edit', Icons.edit_outlined, t.translate('event_details_edit'), AppColors.primaryColor),
        if (onCancel != null)
          _buildMenuItem('cancel', Icons.event_busy_outlined, t.translate('event_cancel_action'), AppColors.orange500),
        if (onDelete != null)
          _buildMenuItem('delete', Icons.delete_outline, t.translate('event_details_delete'), AppColors.red500),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 22),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _EventInfo extends StatelessWidget {
  final EventEntity event;
  final IconData icon;
  final AppLocalizations t;

  const _EventInfo({required this.event, required this.icon, required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: AppTextStyles.headlineMedium.white,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Badge(text: event.type, isStatus: false),
                  const SizedBox(width: 8),
                  _Badge(
                    text: _getStatusLabel(event.status),
                    isStatus: true,
                    isActive: event.status == EventStatus.active,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(EventStatus status) {
    switch (status) {
      case EventStatus.active:
        return t.translate('events_active');
      case EventStatus.draft:
        return t.translate('events_draft');
      case EventStatus.pendingPayment:
        return t.translate('event_status_pending_payment');
      case EventStatus.completed:
        return t.translate('events_completed');
      case EventStatus.cancelled:
        return t.translate('event_status_cancelled');
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final bool isStatus;
  final bool isActive;

  const _Badge({
    required this.text,
    this.isStatus = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isStatus
        ? (isActive ? AppColors.green600 : AppColors.amber500)
        : Colors.white.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.white.semiBold,
      ),
    );
  }
}
