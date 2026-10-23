import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// The event texts laid over a ready-made template background.
class InvitationTexts {
  final String title;
  final String names;
  final String dateTime;
  final String venue;

  const InvitationTexts({
    this.title = '',
    this.names = '',
    this.dateTime = '',
    this.venue = '',
  });

  InvitationTexts copyWith({
    String? title,
    String? names,
    String? dateTime,
    String? venue,
  }) => InvitationTexts(
    title: title ?? this.title,
    names: names ?? this.names,
    dateTime: dateTime ?? this.dateTime,
    venue: venue ?? this.venue,
  );

  bool get isEmpty =>
      title.trim().isEmpty &&
      names.trim().isEmpty &&
      dateTime.trim().isEmpty &&
      venue.trim().isEmpty;
}

/// A 9:16 invitation: the text-free template background with the event's
/// texts typeset over it (Tajawal, centred, RTL). Laid out on a fixed
/// [canvasWidth] × [canvasHeight] logical canvas so the exported PNG
/// (captured at pixelRatio 3 → 1080×1920) looks the same as the preview.
class TemplateInvitationCanvas extends StatelessWidget {
  static const double canvasWidth = 360;
  static const double canvasHeight = 640;

  final ImageProvider background;
  final InvitationTexts texts;

  const TemplateInvitationCanvas({
    super.key,
    required this.background,
    required this.texts,
  });

  static final _shadow = [
    Shadow(
      color: AppColors.black.withValues(alpha: 0.6),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: canvasWidth,
      height: canvasHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: background, fit: BoxFit.cover),
          // Soft vignette so light backgrounds still keep the text legible.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.9,
                colors: [
                  AppColors.black.withValues(alpha: 0.38),
                  AppColors.black.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxxxxl,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (texts.title.trim().isNotEmpty)
                    _line(texts.title, 17, FontWeight.w500, AppColors.amber100),
                  if (texts.names.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _line(
                      texts.names,
                      34,
                      FontWeight.w800,
                      AppColors.white,
                      height: 1.35,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: 64,
                    height: 1,
                    color: AppColors.amber200.withValues(alpha: 0.85),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (texts.dateTime.trim().isNotEmpty)
                    _line(texts.dateTime, 16, FontWeight.w600, AppColors.white),
                  if (texts.venue.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _line(texts.venue, 15, FontWeight.w500, AppColors.amber100),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(
    String text,
    double size,
    FontWeight weight,
    Color color, {
    double height = 1.5,
  }) {
    return Text(
      text.trim(),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Tajawal',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        shadows: _shadow,
      ),
    );
  }
}

/// Builds the default template texts from what the user filled on the
/// event-details page: names come from the event-type fields whose key
/// mentions "name" (groom_name, bride_name, graduate_name…), joined by "و".
InvitationTexts invitationTextsFromEvent({
  required bool isArabic,
  Map<String, dynamic> typeFieldValues = const {},
  DateTime? date,
  int? hour,
  int? minute,
  String? venue,
}) {
  final names = typeFieldValues.entries
      .where((e) => e.key.toLowerCase().contains('name'))
      .map((e) => (e.value ?? '').toString().trim())
      .where((v) => v.isNotEmpty)
      .join(isArabic ? ' و ' : ' & ');

  var when = '';
  if (date != null) {
    const ar = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    const en = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    when = '${date.day} ${(isArabic ? ar : en)[date.month - 1]} ${date.year}';
    if (hour != null) {
      final h12 = hour % 12 == 0 ? 12 : hour % 12;
      final mm = (minute ?? 0).toString().padLeft(2, '0');
      final pm = hour >= 12;
      final suffix = isArabic ? (pm ? 'مساءً' : 'صباحاً') : (pm ? 'PM' : 'AM');
      when += isArabic ? ' · الساعة $h12:$mm $suffix' : ' · $h12:$mm $suffix';
    }
  }

  return InvitationTexts(
    names: names,
    dateTime: when,
    venue: venue?.trim() ?? '',
  );
}
