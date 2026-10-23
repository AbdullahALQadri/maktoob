import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/ai_design/presentation/widgets/template_invitation_canvas.dart';

void main() {
  group('invitationTextsFromEvent', () {
    test('joins the name fields and formats date/time in Arabic', () {
      final t = invitationTextsFromEvent(
        isArabic: true,
        typeFieldValues: {
          'groom_name': 'أحمد',
          'bride_name': 'سارة',
          'hall_notes': 'ignored',
        },
        date: DateTime(2026, 11, 5),
        hour: 19,
        minute: 30,
        venue: ' صالة الأندلس ',
      );
      expect(t.names, 'أحمد و سارة');
      expect(t.dateTime, '5 نوفمبر 2026 · الساعة 7:30 مساءً');
      expect(t.venue, 'صالة الأندلس');
    });

    test('empty input gives empty texts', () {
      expect(invitationTextsFromEvent(isArabic: false).isEmpty, isTrue);
    });
  });

  testWidgets('canvas lays the texts over the background', (tester) async {
    // 1x1 transparent PNG.
    final png = Uint8List.fromList(const [
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0,
      1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 13, 73, 68, 65,
      84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73,
      69, 78, 68, 174, 66, 96, 130,
    ]);
    await tester.pumpWidget(MaterialApp(
      home: FittedBox(
        child: TemplateInvitationCanvas(
          background: MemoryImage(png),
          texts: const InvitationTexts(
            title: 'حفل زفاف',
            names: 'أحمد و سارة',
            dateTime: '5 نوفمبر 2026',
            venue: 'غزة',
          ),
        ),
      ),
    ));
    expect(find.text('أحمد و سارة'), findsOneWidget);
    expect(find.text('حفل زفاف'), findsOneWidget);
    expect(find.text('غزة'), findsOneWidget);
  });
}
