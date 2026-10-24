import 'package:flutter/material.dart';

/// The four places of the app, the same on every screen size: a bottom bar
/// on phones, a rail on tablets, the web portal's sidebar on wide windows.
/// Creating an event is an action beside them, not a place.
enum ShellTab {
  home(Icons.home_outlined, Icons.home_rounded, 'nav_home'),
  events(Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'nav_events'),
  door(Icons.qr_code_scanner_outlined, Icons.qr_code_scanner_rounded, 'nav_door'),
  account(Icons.person_outline_rounded, Icons.person_rounded, 'nav_account');

  const ShellTab(this.icon, this.selectedIcon, this.labelKey);

  final IconData icon;
  final IconData selectedIcon;
  final String labelKey;
}
