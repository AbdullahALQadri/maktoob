import 'package:flutter/material.dart';

import '../widgets/scaffold/app_content_width.dart';

/// Page transitions that draw screens not yet rebuilt for wide windows in a
/// readable 720-wide column on tablets and desktops ([AppContentWidth]).
/// A rebuilt screen opts out by naming its route with [responsivePrefix].
/// Phones are untouched, and every platform keeps its own transition.
class ReadableWidthTransitions extends PageTransitionsBuilder {
  const ReadableWidthTransitions();

  /// Route names of pages that lay themselves out for every width.
  static const responsivePrefix = '/r/';

  static const _platform = PageTransitionsTheme();

  static PageTransitionsTheme get theme =>
      PageTransitionsTheme(builders: {for (final p in TargetPlatform.values) p: const ReadableWidthTransitions()});

  /// The app's first route (it holds the shell) and opted-in pages.
  static bool isResponsive(Route<dynamic> route) {
    final name = route.settings.name ?? '';
    return name == '/' || name.startsWith(responsivePrefix);
  }

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final page = isResponsive(route) ? child : AppContentWidth(child: child);
    return _platform.buildTransitions(route, context, animation, secondaryAnimation, page);
  }
}
