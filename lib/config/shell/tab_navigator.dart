import 'package:flutter/material.dart';

import '../../core/design/readable_width.dart';
import '../routes/app_routes.dart';

/// One tab's own page stack: what is opened inside a tab is still there
/// after visiting another tab, and Back closes it before leaving the tab.
class TabNavigator extends StatelessWidget {
  const TabNavigator({
    super.key,
    required this.navigatorKey,
    required this.name,
    required this.root,
    this.responsive = false,
  });

  final GlobalKey<NavigatorState> navigatorKey;

  /// Route name of the tab's first page.
  final String name;
  final WidgetBuilder root;

  /// Whether the first page lays itself out for wide windows; otherwise it is
  /// drawn in the readable column ([ReadableWidthTransitions]).
  final bool responsive;

  @override
  Widget build(BuildContext context) {
    final routeName = responsive ? '${ReadableWidthTransitions.responsivePrefix}$name' : '/tab/$name';
    return HeroControllerScope.none(
      child: Navigator(
        key: navigatorKey,
        // Pages inside a tab still open the named routes (payment, design).
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onGenerateInitialRoutes: (_, _) => [
          MaterialPageRoute<void>(
            settings: RouteSettings(name: routeName),
            builder: root,
          ),
        ],
      ),
    );
  }
}
