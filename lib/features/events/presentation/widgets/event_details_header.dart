import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/event_model.dart';
import '../../domain/entities/event_entity.dart';

/// Header widget for event details screen.
class EventDetailsHeader extends StatelessWidget {
  final EventEntity event;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventDetailsHeader({
    super.key,
    required this.event,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  List<Color> get _gradient {
    if (event is EventModel) return (event as EventModel).gradient;
    return [AppColors.primaryColor, AppColors.tertiaryColor];
  }

  IconData get _icon {
    if (event is EventModel) return (event as EventModel).icon;
    return Icons.event;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
            // Content first (determines size)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderActions(
                    onBack: onBack,
                    onEdit: onEdit,
                    onDelete: onDelete,
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isCompleted;
  final AppLocalizations t;

  const _HeaderActions({
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
    this.isCompleted = false,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(icon: Icons.arrow_back_rounded, onTap: onBack),
        const Spacer(),
        _MoreOptionsMenu(onEdit: onEdit, onDelete: onDelete, isCompleted: isCompleted, t: t),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isCompleted;
  final AppLocalizations t;

  const _MoreOptionsMenu({
    required this.onEdit,
    required this.onDelete,
    this.isCompleted = false,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        if (!isCompleted)
          _buildMenuItem('edit', Icons.edit_outlined, t.translate('event_details_edit'), AppColors.primaryColor),
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
      case EventStatus.completed:
        return t.translate('events_completed');
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
