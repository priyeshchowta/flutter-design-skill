// Token + ThemeData skeleton. Copy to lib/theme/app_theme.dart and edit the TODOs.
// Imports: match the project. Use package:material_ui/material_ui.dart on material_ui projects.
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Motion tokens (motion-durations, motion-curves).
abstract final class Motion {
  static const press = Duration(milliseconds: 120);
  static const state = Duration(milliseconds: 200);
  static const overlay = Duration(milliseconds: 280);
  static const exit = Duration(milliseconds: 180);
  static const enter = Cubic(0.23, 1, 0.32, 1);
  static const emphasized = Curves.easeInOutCubicEmphasized;
  static const drawer = Cubic(0.32, 0.72, 0, 1);

  /// Honors reduced motion (motion-reduce).
  static Duration of(BuildContext c, Duration d) =>
      MediaQuery.disableAnimationsOf(c) ? Duration.zero : d;
}

/// Design tokens that ColorScheme lacks (theme-extension-tokens).
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.space1, // 4
    required this.space2, // 8
    required this.space3, // 12
    required this.space4, // 16
    required this.space5, // 24
    required this.space6, // 32
    required this.space7, // 48
    required this.radiusControl,
    required this.radiusSurface,
    required this.radiusSheet,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.iconM,
  });

  final double space1, space2, space3, space4, space5, space6, space7;
  final double radiusControl, radiusSurface, radiusSheet, iconM;
  final Color success, onSuccess, warning, onWarning;

  // TODO: set from DESIGN.md. Radius rule: controls pill, surfaces 16, sheets 28.
  static const base = AppTokens(
    space1: 4, space2: 8, space3: 12, space4: 16, space5: 24, space6: 32, space7: 48,
    radiusControl: 999, radiusSurface: 16, radiusSheet: 28, iconM: 24,
    success: Color(0xFF2E7D4F), onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFF9A6700), onWarning: Color(0xFFFFFFFF),
  );

  @override
  AppTokens copyWith({
    double? space1, double? space2, double? space3, double? space4, double? space5, double? space6, double? space7,
    double? radiusControl, double? radiusSurface, double? radiusSheet, double? iconM,
    Color? success, Color? onSuccess, Color? warning, Color? onWarning,
  }) =>
      AppTokens(
        space1: space1 ?? this.space1, space2: space2 ?? this.space2, space3: space3 ?? this.space3,
        space4: space4 ?? this.space4, space5: space5 ?? this.space5, space6: space6 ?? this.space6,
        space7: space7 ?? this.space7,
        radiusControl: radiusControl ?? this.radiusControl, radiusSurface: radiusSurface ?? this.radiusSurface,
        radiusSheet: radiusSheet ?? this.radiusSheet, iconM: iconM ?? this.iconM,
        success: success ?? this.success, onSuccess: onSuccess ?? this.onSuccess,
        warning: warning ?? this.warning, onWarning: onWarning ?? this.onWarning,
      );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    double l(double a, double b) => lerpDouble(a, b, t)!;
    return AppTokens(
      space1: l(space1, other.space1), space2: l(space2, other.space2), space3: l(space3, other.space3),
      space4: l(space4, other.space4), space5: l(space5, other.space5), space6: l(space6, other.space6),
      space7: l(space7, other.space7),
      radiusControl: l(radiusControl, other.radiusControl), radiusSurface: l(radiusSurface, other.radiusSurface),
      radiusSheet: l(radiusSheet, other.radiusSheet), iconM: l(iconM, other.iconM),
      success: Color.lerp(success, other.success, t)!, onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!, onWarning: Color.lerp(onWarning, other.onWarning, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

abstract final class AppTheme {
  // TODO: choose from `dart run scripts/search.dart "<vibe>" --domain palette`. Never the default purple.
  static const Color seed = Color(0xFF0F6B72);

  static ThemeData light({bool highContrast = false}) => _build(Brightness.light, highContrast);
  static ThemeData dark({bool highContrast = false}) => _build(Brightness.dark, highContrast);

  static ThemeData _build(Brightness brightness, bool highContrast) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot, // color-seed-variant
      contrastLevel: highContrast ? 1.0 : 0.0, // theme-contrast-level
    );
    final base = ThemeData(colorScheme: scheme, brightness: brightness);
    // TODO: map the font pair to TextTheme roles (see typeset.md). Bundle fonts for release.
    final text = base.textTheme.copyWith(
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.45),
    );
    const t = AppTokens.base;
    return base.copyWith(
      textTheme: text,
      visualDensity: VisualDensity.standard,
      extensions: const [t],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusSurface)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, kMinInteractiveDimension),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, kMinInteractiveDimension),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.radiusSurface - 4),
          borderSide: BorderSide(color: scheme.outline), // a11y-contrast-ui
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.radiusSurface - 4),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusSheet)),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      // Predictive back (platform-predictive-back): set pageTransitionsTheme to a builders map that
      // includes PredictiveBackPageTransitionsBuilder for Android AND your iOS builder. The Cupertino
      // builder's library differs across Flutter versions (material_ui / cupertino_ui), so it is
      // not hard-coded here. Omitting a platform loses that platform's default transition.
    );
  }
}

// Usage:
// MaterialApp(
//   theme: AppTheme.light(),
//   darkTheme: AppTheme.dark(),
//   themeMode: ThemeMode.system,
//   builder: (context, child) { /* high contrast: AppTheme.*(highContrast: MediaQuery.highContrastOf(context)) */ return child!; },
// );
