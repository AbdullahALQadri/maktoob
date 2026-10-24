import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/config/shell/shell_bottom_bar.dart';
import 'package:maktoob/config/shell/shell_rail.dart';
import 'package:maktoob/config/shell/shell_sidebar.dart';
import 'package:maktoob/config/shell/shell_tab.dart';

typedef _Chrome = Widget Function(ShellTab current, ValueChanged<ShellTab> onSelect, VoidCallback onCreate);

/// Each window size gets its own navigation, and every one of them lays out
/// in Arabic and English and reports the tapped place.
final _cases = <(String, Size, _Chrome, Axis)>[
  ('bottom bar on a small phone', const Size(320, 568), (c, s, n) => ShellBottomBar(current: c, onSelect: s, onCreate: n), Axis.vertical),
  ('rail on a tablet', const Size(768, 1024), (c, s, n) => ShellRail(current: c, onSelect: s, onCreate: n), Axis.horizontal),
  ('sidebar on a desktop', const Size(1280, 800), (c, s, n) => ShellSidebar(current: c, onSelect: s, onCreate: n), Axis.horizontal),
];

Future<void> _pump(WidgetTester tester, Locale locale, Size size, Widget chrome, Axis axis) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final body = axis == Axis.vertical
      ? Scaffold(body: const SizedBox.expand(), bottomNavigationBar: chrome)
      : Scaffold(body: Row(children: [chrome, const Expanded(child: SizedBox.expand())]));
  await tester.runAsync(() async {
    await tester.pumpWidget(MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      home: body,
    ));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final (name, size, build, axis) in _cases) {
      testWidgets('${locale.languageCode}: $name', (tester) async {
        final tapped = <ShellTab>[];
        var created = 0;
        await _pump(tester, locale, size, build(ShellTab.home, tapped.add, () => created++), axis);

        expect(tester.takeException(), isNull);
        final events = locale.languageCode == 'ar' ? 'فعالياتي' : 'My events';
        await tester.tap(find.text(events));
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();

        expect(tapped, [ShellTab.events]);
        expect(created, 1);
      });
    }
  }
}
