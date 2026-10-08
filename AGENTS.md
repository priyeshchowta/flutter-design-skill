# Flutter design rules (compact, for agents without skill support)

Full skill: `skills/flutter-design/SKILL.md`. Read it when your tool supports skills. This file is the short version (under 4k chars) for Copilot, Codex and similar.

## Before any UI edit
1. State a Design Read: "Reading this as: <screen> for <audience>, <vibe>, <Material|Cupertino|custom>."
2. Plan tokens: 4-6 colors -> `ColorScheme`, 1-2 font families -> `TextTheme`, spacing scale (4/8dp), radius scale. Put them in the theme, never in widgets.
3. Build with tokens only. Then verify with a golden or screenshot, light and dark, text scale 1.0 and 2.0.

## Never
- Ship `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` or `0xFF6750A4` untouched.
- Use raw `Colors.*`, `Color(0x...)` or `TextStyle(fontSize:)` inside widgets. Use `Theme.of(context).colorScheme` / `textTheme` / a `ThemeExtension`.
- Branch on `Brightness` inside widgets. Provide light and dark themes.
- Use emoji as icons, identical `Card` grids, or `AnimatedContainer` on everything.
- Use a hit target below 48dp (44pt iOS) or below 8dp apart.
- Animate things users see 100+ times a day, or ignore `MediaQuery.disableAnimationsOf`.

## Numbers
- Contrast 4.5:1 body, 3:1 large text and UI. Disabled opacity 0.38.
- Spacing 4/8dp grid. Body 14-16sp. Lines 45-75 chars.
- Window classes: compact <600, medium 600-840, expanded 840-1200, large 1200+. NavigationBar -> NavigationRail -> drawer.
- Motion: press 100-160ms (scale 0.97), state 150-250ms, overlay 200-300ms, exit ~0.65x enter, stagger 30-50ms. Never ease-in.
- Layout must survive `TextScaler.linear(2.0)`.

## Imports
Flutter 3.47+: prefer `package:material_ui` / `package:cupertino_ui` when the project uses them; match the project's existing imports.
