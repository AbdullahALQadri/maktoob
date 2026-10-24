import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

/// The invitation as a small poster. Without a design yet it is a paper
/// card with the event's title between two stars, like the web.
class EventPoster extends StatelessWidget {
  const EventPoster({
    super.key,
    required this.title,
    required this.width,
    required this.height,
    this.imageUrl,
    this.accent = AppColors.sky200,
    this.ink = AppColors.tertiaryColor,
  });

  final String title;
  final String? imageUrl;
  final double width;
  final double height;

  /// Paper outline and stars.
  final Color accent;

  /// Title colour on the paper.
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .25),
            blurRadius: 18,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              memCacheWidth: (width * 3).round(),
              fadeInDuration: const Duration(milliseconds: 150),
              errorWidget: (_, __, ___) => _Paper(title: title, accent: accent, ink: ink),
            )
          : _Paper(title: title, accent: accent, ink: ink),
    );
  }
}

class _Paper extends StatelessWidget {
  const _Paper({required this.title, required this.accent, required this.ink});

  final String title;
  final Color accent;
  final Color ink;

  /// A picture of the invitation: its words do not grow with the system text
  /// size (the title is written in full beside the poster) and the title
  /// shrinks to the paper.
  @override
  Widget build(BuildContext context) {
    final star = Text('✦', style: TextStyle(color: accent, fontSize: 10, letterSpacing: 5, height: 1));
    return MediaQuery.withNoTextScaling(
      child: Container(
        margin: const EdgeInsetsDirectional.all(5),
        padding: const EdgeInsetsDirectional.all(5),
        decoration: BoxDecoration(border: Border.all(color: accent)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            star,
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w800, height: 1.3),
                ),
              ),
            ),
            star,
          ],
        ),
      ),
    );
  }
}
