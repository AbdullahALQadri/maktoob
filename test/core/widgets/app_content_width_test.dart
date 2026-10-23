import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/widgets/scaffold/app_content_width.dart';

void main() {
  late double seenWidth;

  Widget probe() => MaterialApp(
    builder: (context, child) => AppContentWidth(child: child!),
    home: Builder(
      builder: (context) {
        seenWidth = MediaQuery.sizeOf(context).width;
        return const SizedBox.expand(key: Key('content'));
      },
    ),
  );

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(probe());
  }

  testWidgets('phones are left full width', (tester) async {
    await pumpAt(tester, const Size(360, 780));

    expect(seenWidth, 360);
    expect(tester.getSize(find.byKey(const Key('content'))).width, 360);
  });

  testWidgets('tablets get a centred 720 column and a matching MediaQuery', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1194, 834));

    expect(seenWidth, 720);
    final content = find.byKey(const Key('content'));
    expect(tester.getSize(content).width, 720);
    expect(tester.getTopLeft(content).dx, (1194 - 720) / 2);
  });
}
