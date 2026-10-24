import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/design/readable_width.dart';

/// On a wide window, pages not rebuilt yet are drawn 720 wide; rebuilt pages
/// (route name under `/r/`) and the app's first route use the full width.
void main() {
  Future<double> pageWidth(WidgetTester tester, String? routeName, {double windowWidth = 1280}) async {
    tester.view.physicalSize = Size(windowWidth, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(pageTransitionsTheme: ReadableWidthTransitions.theme),
      home: const SizedBox.expand(),
    ));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute<void>(
      settings: RouteSettings(name: routeName),
      builder: (_) => SizedBox.expand(key: key),
    ));
    await tester.pumpAndSettle();
    return tester.getSize(find.byKey(key)).width;
  }

  testWidgets('a page not rebuilt yet keeps the readable column', (tester) async {
    expect(await pageWidth(tester, '/payment'), 720);
    expect(await pageWidth(tester, null), 720);
  });

  testWidgets('a rebuilt page uses the whole window', (tester) async {
    expect(await pageWidth(tester, '/r/home'), 1280);
  });

  testWidgets('phones are untouched', (tester) async {
    expect(await pageWidth(tester, '/payment', windowWidth: 390), 390);
  });

  test('the first route holds the shell and is never narrowed', () {
    final first = MaterialPageRoute<void>(settings: const RouteSettings(name: '/'), builder: (_) => const SizedBox());
    expect(ReadableWidthTransitions.isResponsive(first), isTrue);
  });
}
