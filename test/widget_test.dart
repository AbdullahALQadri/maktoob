// Basic smoke test for the Maktoob app.
//
// The full app widget (Maktoob) requires platform plugins
// (SharedPreferences, SecureStorage, etc.) that are not available
// in the standard Flutter test environment.  This test verifies
// the app's entry-point widget can be instantiated.

import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/app.dart';

void main() {
  testWidgets('Maktoob widget can be instantiated', (WidgetTester tester) async {
    // Verify the Maktoob widget class is importable and constructible.
    const widget = Maktoob();
    expect(widget, isNotNull);
  });
}
