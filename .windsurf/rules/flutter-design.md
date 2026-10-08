# Flutter design

Read `skills/flutter-design/SKILL.md` before UI edits. The compact rules are in `AGENTS.md`.

- Tokens only: `ColorScheme`, `TextTheme`, `ThemeExtension`. No raw colors or inline font sizes in widgets.
- Never ship the default `Colors.deepPurple` seed.
- Light and dark themes. No brightness branches in widgets.
- 48dp targets, 4.5:1 text contrast, layout works at text scale 2.0.
- Run `dart run skills/flutter-design/scripts/audit.dart <path>` and check a render before calling the UI done.
