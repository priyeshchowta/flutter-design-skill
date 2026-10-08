# Flutter design rules

Full skill: `skills/flutter-design/SKILL.md`. This file is the short version for Copilot.

## Before any UI edit
1. State a Design Read: "Reading this as: <screen> for <audience>, <vibe>, <Material|Cupertino|custom>."
2. Plan tokens: 4-6 colors into `ColorScheme`, 1-2 font families into `TextTheme`, a 4/8dp spacing scale, a radius scale. Put them in the theme, never in widgets.
3. Build with tokens only. Then verify with a golden or screenshot, light and dark, text scale 1.0 and 2.0.

## Never
- Ship `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` or `0xFF6750A4` untouched.
- Use raw `Colors.*`, `Color(0x...)` or `TextStyle(fontSize:)` inside widgets. Use `Theme.of(context).colorScheme`, `textTheme`, or a `ThemeExtension`.
- Branch on `Brightness` inside widgets. Provide light and dark themes.
- Use emoji as icons, identical `Card` grids, or `AnimatedContainer` on everything.
- Use a hit target below 48dp (44pt on iOS) or below 8dp apart.
- Animate something a user sees 100+ times a day, or ignore `MediaQuery.disableAnimationsOf`.

## Numbers
- Contrast 4.5:1 for body text, 3:1 for large text and UI. Disabled content opacity 0.38.
- Spacing on a 4/8dp grid. Body 14-16sp. Lines 45-75 characters.
- Window classes: compact under 600, medium 600-840, expanded 840-1200, large 1200+. Switch `NavigationBar` to `NavigationRail` to a drawer.
- Motion: press 100-160ms at scale 0.97, state 150-250ms, overlay 200-300ms, exit about 0.65x enter, stagger 30-50ms. Never ease-in.
- Layout must survive `TextScaler.linear(2.0)`.

## Imports
On Flutter 3.47 or newer, prefer `package:material_ui` and `package:cupertino_ui` when the project already uses them. Match the project's existing imports.
