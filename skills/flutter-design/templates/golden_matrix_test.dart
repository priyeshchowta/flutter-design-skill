// Golden + accessibility matrix: device x light/dark x text scale x LTR/RTL.
// Copy to test/golden_matrix_test.dart, replace `screens`, then:
//   flutter test --update-goldens test/golden_matrix_test.dart   (create baselines, then LOOK at the PNGs)
//   flutter test test/golden_matrix_test.dart                    (regression)
// Goldens render with the Ahem test font by default; load real fonts (e.g. `alchemist` or
// FontLoader) if the design depends on typography.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// TODO: import your app theme and screens
// import 'package:my_app/theme/app_theme.dart';

class Device {
  const Device(this.name, this.size, this.dpr);
  final String name;
  final Size size;
  final double dpr;
}

const devices = [
  Device('phone_small', Size(360, 640), 3),
  Device('phone', Size(412, 915), 2.625),
  Device('tablet', Size(820, 1180), 2),
  Device('desktop', Size(1440, 900), 1),
];

final screens = <String, Widget Function()>{
  // 'home': () => const HomeScreen(),
};

const textScales = [1.0, 2.0];

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required Device device,
  required ThemeData theme,
  required double textScale,
  required TextDirection direction,
}) async {
  tester.view
    ..physicalSize = device.size * device.dpr
    ..devicePixelRatio = device.dpr;
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: direction == TextDirection.rtl ? const Locale('ar') : const Locale('en'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: direction, child: child!),
      ),
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // TODO: replace with AppTheme.light() / AppTheme.dark()
  final themes = <String, ThemeData>{
    'light': ThemeData(brightness: Brightness.light),
    'dark': ThemeData(brightness: Brightness.dark),
  };

  setUp(() {});

  for (final entry in screens.entries) {
    for (final device in devices) {
      for (final themeEntry in themes.entries) {
        for (final scale in textScales) {
          for (final dir in TextDirection.values) {
            final name = '${entry.key}_${device.name}_${themeEntry.key}_x${scale}_${dir.name}';
            testWidgets(name, (tester) async {
              addTearDown(tester.view.reset);
              await pumpScreen(tester, entry.value(),
                  device: device, theme: themeEntry.value, textScale: scale, direction: dir);
              expect(tester.takeException(), isNull, reason: 'overflow or build error: $name');
              await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
            });
          }
        }
      }
    }
  }

  // Accessibility guidelines (a11y-test-guidelines)
  for (final entry in screens.entries) {
    testWidgets('a11y ${entry.key}', (tester) async {
      addTearDown(tester.view.reset);
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, entry.value(),
          device: devices[1], theme: themes['light']!, textScale: 1.0, direction: TextDirection.ltr);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose(); // must be disposed before the test ends
    });
  }
}
