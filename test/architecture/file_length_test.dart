import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// No file under lib/ may pass 250 lines. Files that were already longer
/// are listed in oversized_files.txt with their size at the time; they may
/// only shrink until they are split, so the list only ever gets shorter.
void main() {
  const limit = 250;

  Map<String, int> legacy() {
    final entries = File('test/architecture/oversized_files.txt')
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .map((l) => l.split(' '));
    return {for (final e in entries) e[0]: int.parse(e[1])};
  }

  test('every Dart file in lib/ stays within $limit lines', () {
    final allowed = legacy();
    final problems = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll(r'\', '/');
      final lines = entity.readAsLinesSync().length;
      final max = allowed[path] ?? limit;
      if (lines > max) {
        problems.add(allowed.containsKey(path)
            ? '$path grew to $lines lines (may not pass $max; split it)'
            : '$path has $lines lines (limit $limit)');
      }
    }

    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('the legacy list only names files that still need splitting', () {
    final stale = legacy().keys.where((path) {
      final file = File(path);
      return !file.existsSync() || file.readAsLinesSync().length <= limit;
    }).toList();

    expect(stale, isEmpty,
        reason: 'Remove from oversized_files.txt: ${stale.join(', ')}');
  });
}
