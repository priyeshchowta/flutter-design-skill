# Contributing

## Add a rule

1. Copy any file in `skills/flutter-design/reference/rules/`.
2. Name it `<prefix>-<slug>.md`. Prefixes: `a11y`, `theme`, `state`, `layout`, `platform`, `color`, `type`, `motion`, `perf`, `icon`, `copy`.
3. Keep the frontmatter (`title`, `impact`, `severity`, `tags`) and the Incorrect / Correct Dart blocks. Both blocks must be real Dart that uses real Flutter APIs. The incorrect block shows a bad choice, not a fake API.
4. Add a source link (Material 3, Human Interface Guidelines, WCAG, or Flutter docs).
5. Add a row to `reference/rules/_index.md`.
6. If the check can be made without an LLM, add it to `scripts/audit.dart` and a case in `test/audit_test.dart`.

## Add a palette, font, style, or motion preset

Edit the CSV in `skills/flutter-design/data/`. Keep the header. Palettes are seeds for `ColorScheme.fromSeed`, not raw fills: do not tell an agent to `copyWith` a raw hex onto `secondary` or `tertiary`, because the generated `onSecondary` / `onTertiary` then fails 4.5:1. `test/palette_contrast_test.dart` guards this.

Update the counts in `SKILL.md` and `tool/validate.dart` when the number of rows changes.

## Check before a PR

```bash
dart run tool/validate.dart
flutter analyze
flutter test
dart run tool/check_snippets.dart && dart analyze test/snippet_check
dart run skills/flutter-design/scripts/audit.dart examples/habit_tracker/after
```

`tool/check_snippets.dart` writes `test/snippet_check/` (gitignored) and compiles every rule snippet. Fix the snippet, not the harness, when a Flutter API is wrong.

## Skill format

`skills/flutter-design/SKILL.md` follows [agentskills.io](https://agentskills.io/specification): `name` matches the directory, `description` is under 1024 characters, and the body stays under 500 lines. `argument-hint` is a Claude Code extension and is allowed by `tool/validate.dart`. The spec's `references/` folder is a symlink to `reference/`, which is the path the skill text uses.
