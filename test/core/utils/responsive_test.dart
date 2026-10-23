import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/utils/responsive.dart';

void main() {
  Future<BuildContext> contextAt(WidgetTester tester, Size size) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    );
    return captured;
  }

  testWidgets('phones scale with the real screen size', (tester) async {
    final context = await contextAt(tester, const Size(360, 780));

    expect(context.dynamicWidth(0.04), closeTo(14.4, 1e-9));
    expect(context.dynamicHeight(0.02), closeTo(15.6, 1e-9));
  });

  testWidgets('tablets are capped at the largest phone', (tester) async {
    final context = await contextAt(tester, const Size(720, 1194));

    expect(context.dynamicWidth(0.04), closeTo(17.2, 1e-9));
    expect(context.dynamicHeight(0.02), closeTo(18.64, 1e-9));
  });
}
