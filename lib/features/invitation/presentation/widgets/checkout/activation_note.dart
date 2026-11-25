import 'package:flutter/material.dart';
import '../../../../../config/locale/app_localizations.dart';
import '../../../../../core/core.dart';


class ActivationNote extends StatefulWidget {
  const ActivationNote({super.key});

  @override
  State<ActivationNote> createState() => _ActivationNoteState();
}


class _ActivationNoteState extends State<ActivationNote>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) {
                final t = _controller.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 16 * t,
                      height: 16 * t,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor.withValues(
                          alpha: (1 - t) * 0.5,
                        ),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l?.translate('wizard_instant_execution_notice') ??
                  'هذا الطلب سيتم تنفيذه بشكل فوري عند التأكيد.',
              style: TextStyle(
                fontSize: 13,
                color: context.brandInk.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
