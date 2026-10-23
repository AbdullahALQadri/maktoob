import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/features/payment/presentation/widgets/upload_area_widget.dart';

PlatformFile _img(String name) => PlatformFile(name: name, size: 1);

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('shows a thumbnail per receipt, an add tile and removes by index', (tester) async {
    final removed = <int>[];
    var picks = 0;
    await pump(
      tester,
      UploadAreaWidget(
        selectedFiles: [_img('a.jpg'), _img('b.jpg')],
        onPickFile: () => picks++,
        onRemoveFile: removed.add,
      ),
    );

    expect(find.byKey(const Key('payment_receipt_0')), findsOneWidget);
    expect(find.byKey(const Key('payment_receipt_1')), findsOneWidget);
    expect(find.text('صور الإيصال (2 من 3)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('payment_receipt_add')));
    expect(picks, 1);

    await tester.tap(find.descendant(
      of: find.byKey(const Key('payment_receipt_1')),
      matching: find.byIcon(Icons.close),
    ));
    expect(removed, [1]);
  });

  testWidgets('no add tile once the limit is reached', (tester) async {
    await pump(
      tester,
      UploadAreaWidget(
        selectedFiles: [_img('a.jpg'), _img('b.jpg'), _img('c.jpg')],
        onPickFile: () {},
        onRemoveFile: (_) {},
      ),
    );
    expect(find.byKey(const Key('payment_receipt_add')), findsNothing);
  });

  testWidgets('empty state offers the picker', (tester) async {
    var picks = 0;
    await pump(tester, UploadAreaWidget(onPickFile: () => picks++, onRemoveFile: (_) {}));
    await tester.tap(find.byKey(const Key('payment_receipt_pick')));
    expect(picks, 1);
  });
}
