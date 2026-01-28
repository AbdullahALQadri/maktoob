import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_strings.dart';
import '../../utils/responsive.dart';

/// A unified Scaffold widget for consistent screen layouts.
///
/// This widget provides a standard scaffold with common configurations
/// like app bar, safe area handling, and loading states.
///
/// Example usage:
/// ```dart
/// AppScaffold(
///   title: 'Home',
///   body: HomeContent(),
/// )
///
/// AppScaffold.withScrolling(
///   title: 'Settings',
///   children: [SettingsItem1(), SettingsItem2()],
/// )
/// ```
class AppScaffold extends StatelessWidget {
  /// The title displayed in the app bar.
  final String? title;

  /// Custom title widget (overrides title string).
  final Widget? titleWidget;

  /// The main body content.
  final Widget body;

  /// Whether to show the app bar.
  final bool showAppBar;

  /// Whether to use safe area.
  final bool useSafeArea;

  /// Whether to resize to avoid bottom inset (keyboard).
  final bool resizeToAvoidBottomInset;

  /// Custom app bar.
  final PreferredSizeWidget? appBar;

  /// Floating action button.
  final Widget? floatingActionButton;

  /// Floating action button location.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Bottom sheet.
  final Widget? bottomSheet;

  /// Drawer widget.
  final Widget? drawer;

  /// End drawer widget.
  final Widget? endDrawer;

  /// Background color.
  final Color? backgroundColor;

  /// App bar background color.
  final Color? appBarBackgroundColor;

  /// Leading widget for app bar.
  final Widget? leading;

  /// Actions for app bar.
  final List<Widget>? actions;

  /// Whether to center the title.
  final bool centerTitle;

  /// Whether to show back button automatically.
  final bool automaticallyImplyLeading;

  /// App bar elevation.
  final double? appBarElevation;

  /// Callback when back button is pressed.
  final VoidCallback? onBackPressed;

  /// Whether the screen is loading.
  final bool isLoading;

  /// Loading widget.
  final Widget? loadingWidget;

  /// System UI overlay style.
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  /// Extend body behind app bar.
  final bool extendBodyBehindAppBar;

  /// App bar bottom widget (like TabBar).
  final PreferredSizeWidget? appBarBottom;

  /// Whether app bar is transparent.
  final bool transparentAppBar;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.showAppBar = true,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = true,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.appBarElevation,
    this.onBackPressed,
    this.isLoading = false,
    this.loadingWidget,
    this.systemUiOverlayStyle,
    this.extendBodyBehindAppBar = false,
    this.appBarBottom,
    this.transparentAppBar = false,
  });

  /// Creates a scaffold with scrolling content.
  factory AppScaffold.withScrolling({
    Key? key,
    String? title,
    Widget? titleWidget,
    required List<Widget> children,
    bool showAppBar = true,
    bool useSafeArea = true,
    bool resizeToAvoidBottomInset = true,
    PreferredSizeWidget? appBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Widget? bottomNavigationBar,
    Widget? bottomSheet,
    Widget? drawer,
    Widget? endDrawer,
    Color? backgroundColor,
    Color? appBarBackgroundColor,
    Widget? leading,
    List<Widget>? actions,
    bool centerTitle = true,
    bool automaticallyImplyLeading = true,
    double? appBarElevation,
    VoidCallback? onBackPressed,
    bool isLoading = false,
    Widget? loadingWidget,
    SystemUiOverlayStyle? systemUiOverlayStyle,
    bool extendBodyBehindAppBar = false,
    PreferredSizeWidget? appBarBottom,
    bool transparentAppBar = false,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    ScrollController? scrollController,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return AppScaffold(
      key: key,
      title: title,
      titleWidget: titleWidget,
      showAppBar: showAppBar,
      useSafeArea: useSafeArea,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      appBarBackgroundColor: appBarBackgroundColor,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      appBarElevation: appBarElevation,
      onBackPressed: onBackPressed,
      isLoading: isLoading,
      loadingWidget: loadingWidget,
      systemUiOverlayStyle: systemUiOverlayStyle,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBarBottom: appBarBottom,
      transparentAppBar: transparentAppBar,
      body: _ScrollableBody(
        padding: padding,
        physics: physics,
        scrollController: scrollController,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }

  /// Creates a scaffold with sliver app bar.
  factory AppScaffold.withSliverAppBar({
    Key? key,
    required Widget body,
    required String title,
    Widget? flexibleSpaceBackground,
    double expandedHeight = 200,
    bool pinned = true,
    bool floating = false,
    bool snap = false,
    Color? backgroundColor,
    Color? appBarBackgroundColor,
    List<Widget>? actions,
    bool useSafeArea = true,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Widget? bottomNavigationBar,
    bool isLoading = false,
    Widget? loadingWidget,
  }) {
    return AppScaffold(
      key: key,
      showAppBar: false,
      useSafeArea: useSafeArea,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      isLoading: isLoading,
      loadingWidget: loadingWidget,
      body: _SliverAppBarBody(
        title: title,
        body: body,
        flexibleSpaceBackground: flexibleSpaceBackground,
        expandedHeight: expandedHeight,
        pinned: pinned,
        floating: floating,
        snap: snap,
        appBarBackgroundColor: appBarBackgroundColor,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAppBar = appBar ?? _buildDefaultAppBar(context);

    Widget scaffoldBody = isLoading
        ? loadingWidget ?? const _DefaultLoadingWidget()
        : body;

    if (useSafeArea && !showAppBar) {
      scaffoldBody = SafeArea(child: scaffoldBody);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle ??
          (Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark),
      child: Scaffold(
        appBar: showAppBar ? effectiveAppBar : null,
        body: scaffoldBody,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        drawer: drawer,
        endDrawer: endDrawer,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
    );
  }

  PreferredSizeWidget _buildDefaultAppBar(BuildContext context) {
    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: TextStyle(
                    fontFamily: AppStrings.fontFamily,
                    fontSize: context.dynamicWidth(0.045),
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null),
      centerTitle: centerTitle,
      leading: leading ??
          (onBackPressed != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: onBackPressed,
                )
              : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      elevation: transparentAppBar ? 0 : (appBarElevation ?? 0),
      backgroundColor: transparentAppBar
          ? AppColors.transparent
          : (appBarBackgroundColor ?? Theme.of(context).scaffoldBackgroundColor),
      surfaceTintColor: AppColors.transparent,
      bottom: appBarBottom,
    );
  }
}

/// Scrollable body for AppScaffold.withScrolling
class _ScrollableBody extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? scrollController;
  final CrossAxisAlignment crossAxisAlignment;

  const _ScrollableBody({
    required this.children,
    this.padding,
    this.physics,
    this.scrollController,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: physics ?? const BouncingScrollPhysics(),
      padding: padding ?? AppSpacing.screenPaddingH,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
}

/// Sliver app bar body for AppScaffold.withSliverAppBar
class _SliverAppBarBody extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? flexibleSpaceBackground;
  final double expandedHeight;
  final bool pinned;
  final bool floating;
  final bool snap;
  final Color? appBarBackgroundColor;
  final List<Widget>? actions;

  const _SliverAppBarBody({
    required this.title,
    required this.body,
    this.flexibleSpaceBackground,
    this.expandedHeight = 200,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.appBarBackgroundColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: expandedHeight,
          pinned: pinned,
          floating: floating,
          snap: snap,
          backgroundColor: appBarBackgroundColor,
          surfaceTintColor: AppColors.transparent,
          actions: actions,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              title,
              style: TextStyle(
                fontFamily: AppStrings.fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            background: flexibleSpaceBackground,
          ),
        ),
        SliverToBoxAdapter(child: body),
      ],
    );
  }
}

/// Default loading widget
class _DefaultLoadingWidget extends StatelessWidget {
  const _DefaultLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
      ),
    );
  }
}
