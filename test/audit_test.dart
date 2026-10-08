import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../skills/flutter-design/scripts/audit.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('flutter_design_audit'));
  tearDown(() => dir.deleteSync(recursive: true));

  Finding? find(String source, String rule) {
    final file = File('${dir.path}/sample.dart')..writeAsStringSync(source);
    return auditFile(file, file.path).where((f) => f.rule == rule).firstOrNull;
  }

  test('flags a multiline TextStyle fontSize', () {
    final hit = find('''
class W {
  void build() {
    final style = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
  }
}
''', 'theme-inline-textstyle');
    expect(hit, isNotNull);
    expect(hit!.severity, 'P1');
  });

  test('flags a default seed and an unlabeled icon button', () {
    final file = File('${dir.path}/sample.dart')
      ..writeAsStringSync('''
class W {
  void build() {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
    IconButton(onPressed: () {}, icon: Icon(Icons.add));
  }
}
''');
    final hits = auditFile(file, file.path);
    expect(hits.map((h) => h.rule), containsAll(['theme-default-seed', 'a11y-semantics-label']));
  });

  test('flags off-grid literals and ignores the 4dp grid', () {
    expect(find('SizedBox(height: 13);', 'layout-grid-4-8'), isNotNull);
    expect(find('SizedBox(height: 16);', 'layout-grid-4-8'), isNull);
  });

  test('audit:ignore suppresses the line', () {
    expect(
      find('SizedBox(height: 13); // audit:ignore', 'layout-grid-4-8'),
      isNull,
    );
  });

  test('the worked example scores clean and the slop example does not', () {
    final before = auditFile(
      File('examples/habit_tracker/before/main.dart'),
      'examples/habit_tracker/before/main.dart',
    );
    final after = [
      ...auditFile(File('examples/habit_tracker/after/main.dart'), 'examples/habit_tracker/after/main.dart'),
      ...auditFile(File('examples/habit_tracker/after/app_theme.dart'), 'examples/habit_tracker/after/app_theme.dart'),
    ];
    expect(before.any((f) => f.severity == 'P0' || f.severity == 'P1'), isTrue);
    expect(after, isEmpty);
  });
}
