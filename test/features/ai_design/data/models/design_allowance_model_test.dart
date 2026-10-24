import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/ai_design/data/models/design_allowance_model.dart';
import 'package:maktoob/features/ai_design/data/models/generation_status_model.dart';

void main() {
  test('reads design_allowance from the server', () {
    final a = DesignAllowanceModel.tryParse({
      'designs_limit': 3,
      'designs_used': 3,
      'designs_left': 0,
      'stickers_left': 5,
      'pool_reached': false,
    })!;

    expect(a.designsLimit, 3);
    expect(a.designsLeft, 0);
    expect(a.isUsedUp, isTrue);
    expect(a.poolReached, isFalse);
  });

  test('an older backend without the field leaves it null', () {
    expect(DesignAllowanceModel.tryParse(null), isNull);
    expect(DesignAllowanceModel.tryParse({'foo': 1}), isNull);
  });

  test('every status poll carries the latest count', () {
    final s = GenerationStatusModel.fromJson({
      'success': true,
      'data': {
        'status': 'failed',
        'image_id': 7,
        'design_allowance': {'designs_limit': '3', 'designs_used': '1', 'designs_left': '2'},
      },
    });

    expect(s.allowance?.designsLeft, 2);
    expect(s.allowance?.isUsedUp, isFalse);
  });
}
