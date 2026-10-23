import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keys in file order, duplicates included (jsonDecode would hide them).
List<String> _rawKeys(String source) => RegExp(r'^\s*"([^"]+)"\s*:', multiLine: true)
    .allMatches(source)
    .map((m) => m.group(1)!)
    .toList();

void main() {
  const langs = ['ar', 'en', 'tr'];
  final sources = {for (final l in langs) l: File('lang/$l.json').readAsStringSync()};

  for (final l in langs) {
    test('$l.json has no duplicate keys', () {
      final seen = <String>{};
      final dups = _rawKeys(sources[l]!).where((k) => !seen.add(k)).toList();
      expect(dups, isEmpty);
    });
  }

  test('ar, en and tr have the same keys', () {
    final maps = {for (final l in langs) l: (jsonDecode(sources[l]!) as Map).keys.toSet()};
    expect(maps['en']!.difference(maps['ar']!), isEmpty);
    expect(maps['ar']!.difference(maps['en']!), isEmpty);
    expect(maps['en']!.difference(maps['tr']!), isEmpty);
    expect(maps['tr']!.difference(maps['en']!), isEmpty);
  });

  test('the Arabic app name is Arabic', () {
    expect((jsonDecode(sources['ar']!) as Map)['app_name'], 'مكتوب');
  });

  test('placeholders match across languages', () {
    final en = jsonDecode(sources['en']!) as Map;
    final re = RegExp(r'\{(\w+)\}');
    for (final l in ['ar', 'tr']) {
      final other = jsonDecode(sources[l]!) as Map;
      for (final k in en.keys) {
        final a = re.allMatches('${en[k]}').map((m) => m.group(1)).toSet();
        final b = re.allMatches('${other[k]}').map((m) => m.group(1)).toSet();
        expect(b, a, reason: '$l:$k');
      }
    }
  });
}
