import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../../events/domain/entities/event_entity.dart';
import '../../../events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../../events/presentation/cubit/events_list/events_list_state.dart';
import '../widgets/widgets.dart';

/// Screen that displays ongoing events for scanner selection
class ScannerEventsScreen extends StatelessWidget {
  final Function(EventEntity)? onEventSelected;

  const ScannerEventsScreen({super.key, this.onEventSelected});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<EventsListCubit>()..loadEvents(),
      child: _ScannerEventsContent(onEventSelected: onEventSelected),
    );
  }
}

class _ScannerEventsContent extends StatefulWidget {
  final Function(EventEntity)? onEventSelected;

  const _ScannerEventsContent({this.onEventSelected});

  @override
  State<_ScannerEventsContent> createState() => _ScannerEventsContentState();
}

class _ScannerEventsContentState extends State<_ScannerEventsContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.overlayBg,
      body: Column(
        children: [
          _AnimatedHeader(fadeController: _fadeController, t: t),
          Expanded(
            child: BlocBuilder<EventsListCubit, EventsListState>(
              builder: (context, state) {
                if (state.isLoading) return const _LoadingState();
                if (state.isFailure) {
                  return _ErrorState(message: state.errorMessage ?? '');
                }

                final ongoingEvents = state.events
                    .where((e) => e.status == EventStatus.active)
                    .toList();

                if (ongoingEvents.isEmpty) return const _EmptyState();
                return _EventsList(
                  events: ongoingEvents,
                  onEventSelected: widget.onEventSelected,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedHeader extends StatelessWidget {
  final AnimationController fadeController;
  final AppLocalizations t;

  const _AnimatedHeader({required this.fadeController, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: fadeController,
          child: Padding(
            padding: EdgeInsets.only(
              left: context.dynamicWidth(0.04),
              right: context.dynamicWidth(0.04),
              top: context.dynamicHeight(0.02),
              bottom: context.dynamicHeight(0.03),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconBadge(t: t),
                SizedBox(height: context.dynamicHeight(0.015)),
                _TitleText(t: t),
                SizedBox(height: context.dynamicHeight(0.007)),
                Text(
                  t.translate('scanner_select_event_desc'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: context.dynamicWidth(0.035),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final AppLocalizations t;

  const _IconBadge({required this.t});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.029),
          vertical: context.dynamicHeight(0.007),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.white, size: context.dynamicWidth(0.04)),
            SizedBox(width: context.dynamicWidth(0.016)),
            Text(
              t.translate('scanner_guest_scanner'),
              style: TextStyle(
                color: Colors.white,
                fontSize: context.dynamicWidth(0.029),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  final AppLocalizations t;

  const _TitleText({required this.t});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0, 20), end: Offset.zero),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, offset, child) => Transform.translate(offset: offset, child: child),
      child: Text(
        t.translate('scanner_select_event'),
        style: TextStyle(
          color: Colors.white,
          fontSize: context.dynamicWidth(0.064),
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      itemCount: 4,
      itemBuilder: (context, index) => const RecentEventCardSkeleton(),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.08)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.dynamicWidth(0.2),
              height: context.dynamicWidth(0.2),
              decoration: BoxDecoration(
                color: AppColors.red500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: context.dynamicWidth(0.101), color: AppColors.red500),
            ),
            SizedBox(height: context.dynamicHeight(0.025)),
            Text(
              t.translate('home_something_wrong'),
              style: TextStyle(fontSize: context.dynamicWidth(0.045), fontWeight: FontWeight.bold, color: context.textPrimary),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: context.iconSecondary, fontSize: context.dynamicWidth(0.035))),
            SizedBox(height: context.dynamicHeight(0.03)),
            ElevatedButton(
              onPressed: () => context.read<EventsListCubit>().refreshEvents(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.08), vertical: context.dynamicHeight(0.015)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.dynamicWidth(0.029))),
              ),
              child: Text(t.translate('home_try_again'), style: TextStyle(fontSize: context.dynamicWidth(0.035))),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.08)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.dynamicWidth(0.251),
              height: context.dynamicWidth(0.251),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_busy, size: context.dynamicWidth(0.12), color: AppColors.primaryColor),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            Text(
              t.translate('scanner_no_ongoing_events'),
              style: TextStyle(fontSize: context.dynamicWidth(0.051), fontWeight: FontWeight.bold, color: context.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.dynamicHeight(0.015)),
            Text(
              t.translate('scanner_no_ongoing_events_desc'),
              style: TextStyle(fontSize: context.dynamicWidth(0.035), color: context.iconSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final List<EventEntity> events;
  final Function(EventEntity)? onEventSelected;

  const _EventsList({required this.events, this.onEventSelected});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<EventsListCubit>().refreshEvents(),
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: context.dynamicWidth(0.04),
          right: context.dynamicWidth(0.04),
          top: context.dynamicWidth(0.04),
          bottom: context.dynamicHeight(0.119),
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ScannerEventCard(
            event: event,
            index: index,
            onTap: onEventSelected != null ? () => onEventSelected!(event) : null,
          );
        },
      ),
    );
  }
}
