import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Hero metric card — editorial dashboard signature.
///
/// White surface with 1px warm-sand border, uppercase label, big saffron
/// percentage, and an italic caption beneath the hairline progress bar.
class ResponseRateCardWidget extends StatefulWidget {
  final double responseRate;
  final int totalResponded;
  final int totalGuests;

  const ResponseRateCardWidget({
    super.key,
    required this.responseRate,
    required this.totalResponded,
    required this.totalGuests,
  });

  @override
  State<ResponseRateCardWidget> createState() => _ResponseRateCardWidgetState();
}

class _ResponseRateCardWidgetState extends State<ResponseRateCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;
    final percentLabel = '${(widget.responseRate * 100).round()}%';
    final ratio = '${_format(widget.totalResponded)} / '
        '${_format(widget.totalGuests)}';
    final rawLabel = t.translate('home_response_rate');
    final labelDisplay =
        t.isEnLocale ? rawLabel.toUpperCase() : rawLabel;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 16 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsetsDirectional.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          labelDisplay,
                          style: text.labelMedium?.copyWith(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: t.isEnLocale ? 1.5 : 0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            percentLabel,
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryColor,
                              height: 1.0,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 6),
                    child: Text(
                      ratio,
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(1),
                    child: SizedBox(
                      height: 2,
                      child: Stack(
                        children: [
                          Container(color: AppColors.gray200),
                          FractionallySizedBox(
                            widthFactor:
                                widget.responseRate * _progressAnimation.value,
                            child: Container(color: AppColors.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Text(
                t.translate('home_response_rate_caption'),
                style: text.bodySmall?.copyWith(
                  color: context.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
