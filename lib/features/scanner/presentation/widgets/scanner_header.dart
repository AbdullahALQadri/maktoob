import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../events/domain/entities/event_entity.dart';

/// Gradient header for scanner screen with event info.
class ScannerHeader extends StatelessWidget {
  final String title;
  final String? description;
  final String? venue;
  final String? when;
  final VoidCallback? onBack;

  /// Door actions (gate, venue hub, management...).
  final Widget? menu;

  const ScannerHeader({
    super.key,
    required this.title,
    this.description,
    this.venue,
    this.when,
    this.onBack,
    this.menu,
  });

  factory ScannerHeader.forEvent(EventEntity event, {Key? key, VoidCallback? onBack, Widget? menu}) => ScannerHeader(
    key: key,
    title: event.name,
    description: event.description,
    venue: event.venue,
    when: '${event.date} | ${event.time}',
    onBack: onBack,
    menu: menu,
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: context.dynamicWidth(0.051),
            offset: Offset(0, context.dynamicHeight(0.012)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackRow(title: t.translate('scanner_guest_scanner'), onBack: onBack, menu: menu),
          SizedBox(height: context.dynamicHeight(0.02)),
          _EventInfoRow(title: title, description: description),
          if (venue != null || when != null) ...[
            SizedBox(height: context.dynamicHeight(0.015)),
            _EventDetailsChip(venue: venue, when: when),
          ],
        ],
      ),
    );
  }
}

class _BackRow extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? menu;

  const _BackRow({required this.title, this.onBack, this.menu});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: context.dynamicWidth(0.101),
            height: context.dynamicWidth(0.101),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: context.dynamicWidth(0.056)),
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.029)),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: context.dynamicWidth(0.045), fontWeight: FontWeight.w600),
          ),
        ),
        if (menu != null) menu!,
      ],
    );
  }
}

class _EventInfoRow extends StatelessWidget {
  final String title;
  final String? description;

  const _EventInfoRow({required this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.024)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          ),
          child: Icon(Icons.event, color: Colors.white, size: context.dynamicWidth(0.069)),
        ),
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.dynamicWidth(0.051),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (description != null) ...[
                SizedBox(height: context.dynamicHeight(0.005)),
                Text(
                  description!,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: context.dynamicWidth(0.032)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EventDetailsChip extends StatelessWidget {
  final String? venue;
  final String? when;

  const _EventDetailsChip({this.venue, this.when});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.029), vertical: context.dynamicHeight(0.01)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
      ),
      child: Wrap(
        spacing: context.dynamicWidth(0.04),
        runSpacing: context.dynamicHeight(0.01),
        children: [
          if (venue != null && venue!.isNotEmpty) _DetailItem(icon: Icons.location_on, text: venue!),
          if (when != null) _DetailItem(icon: Icons.calendar_today, text: when!),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: context.dynamicWidth(0.04)),
        SizedBox(width: context.dynamicWidth(0.016)),
        Text(
          text,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: context.dynamicWidth(0.032)),
        ),
      ],
    );
  }
}
