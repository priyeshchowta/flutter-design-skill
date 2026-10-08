import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.x relative-luminance contrast. Large text and UI chrome may use 3:1;
/// body text needs 4.5:1.
double contrast(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  final csv = File('skills/flutter-design/data/palettes.csv');
  final lines = csv.readAsLinesSync().where((l) => l.trim().isNotEmpty).toList();
  final header = lines.first.split(',');
  final rows = [
    for (final line in lines.skip(1))
      {
        for (final e in line.split(',').asMap().entries)
          if (e.key < header.length) header[e.key]: e.value.trim(),
      },
  ];

  test('palette catalog has 30 rows', () {
    expect(rows, hasLength(30));
  });

  test('fromSeed schemes meet contrast for text roles', () {
    final failures = <String>[];
    const pairs = <(String, String, double)>[
      ('primary', 'onPrimary', 4.5),
      ('primaryContainer', 'onPrimaryContainer', 4.5),
      ('secondary', 'onSecondary', 4.5),
      ('secondaryContainer', 'onSecondaryContainer', 4.5),
      ('tertiary', 'onTertiary', 4.5),
      ('tertiaryContainer', 'onTertiaryContainer', 4.5),
      ('error', 'onError', 4.5),
      ('surface', 'onSurface', 4.5),
      ('surface', 'onSurfaceVariant', 3.0),
    ];
    for (final row in rows) {
      final seed = Color(int.parse(row['seed']!));
      final variant = DynamicSchemeVariant.values.byName(row['variant']!);
      for (final brightness in Brightness.values) {
        final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness, dynamicSchemeVariant: variant);
        final colors = scheme.toMap();
        for (final (bg, fg, min) in pairs) {
          final ratio = contrast(colors[bg]!, colors[fg]!);
          if (ratio < min) {
            failures.add('${row['id']} $brightness $fg on $bg = ${ratio.toStringAsFixed(2)} (need $min)');
          }
        }
      }
    }
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  test('design-system output does not copy raw seeds onto on-colors', () {
    final source = File('skills/flutter-design/scripts/search.dart').readAsStringSync();
    expect(source.contains('.copyWith(secondary:'), isFalse);
  });
}

extension on ColorScheme {
  Map<String, Color> toMap() => {
        'primary': primary,
        'onPrimary': onPrimary,
        'primaryContainer': primaryContainer,
        'onPrimaryContainer': onPrimaryContainer,
        'secondary': secondary,
        'onSecondary': onSecondary,
        'secondaryContainer': secondaryContainer,
        'onSecondaryContainer': onSecondaryContainer,
        'tertiary': tertiary,
        'onTertiary': onTertiary,
        'tertiaryContainer': tertiaryContainer,
        'onTertiaryContainer': onTertiaryContainer,
        'error': error,
        'onError': onError,
        'surface': surface,
        'onSurface': onSurface,
        'onSurfaceVariant': onSurfaceVariant,
      };
}
