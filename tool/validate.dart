// Checks the skill against the agentskills.io frontmatter rules and the
// repo's own cross-references. No Flutter needed.
//
//   dart run tool/validate.dart
import 'dart:io';

const _allowedKeys = {
  'name',
  'description',
  'license',
  'compatibility',
  'metadata',
  'allowed-tools',
  // Claude Code extension. Not part of the agentskills.io spec; kept because
  // Claude uses it for the command hint. Validators that reject unknown keys
  // should allow this one.
  'argument-hint',
};

void main() {
  final errors = <String>[];
  final skillDir = Directory('skills/flutter-design');
  final skill = File('${skillDir.path}/SKILL.md').readAsStringSync();
  final front = _frontmatter(skill);
  if (front == null) {
    errors.add('SKILL.md has no YAML frontmatter');
  } else {
    final name = front['name'];
    if (name != 'flutter-design') errors.add('name "$name" must match the parent directory flutter-design');
    if (name != null && (name.startsWith('-') || name.endsWith('-') || name.contains('--'))) {
      errors.add('name has a leading, trailing, or doubled hyphen');
    }
    final description = front['description'];
    if (description == null || description.isEmpty || description.length > 1024) {
      errors.add('description must be 1-1024 characters (is ${description?.length ?? 0})');
    }
    final compatibility = front['compatibility'];
    if (compatibility != null && compatibility.length > 500) {
      errors.add('compatibility is ${compatibility.length} characters; max is 500');
    }
    for (final key in front.keys) {
      if (!_allowedKeys.contains(key)) errors.add('unknown frontmatter key "$key"');
    }
    final bodyLines = skill.split('---').skip(2).join('---').split('\n').length;
    if (bodyLines > 500) errors.add('SKILL.md body is $bodyLines lines; keep it under 500');
  }

  final rulesDir = Directory('${skillDir.path}/reference/rules');
  final ruleFiles = rulesDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md') && !f.path.endsWith('_index.md'))
      .map((f) => f.uri.pathSegments.last.replaceAll('.md', ''))
      .toSet();
  if (ruleFiles.length != 111) errors.add('expected 111 rule files, found ${ruleFiles.length}');

  final id = RegExp(r'`((?:a11y|theme|state|layout|platform|color|type|motion|perf|icon|copy)-[a-z0-9-]+)`');
  for (final file in _markdown(skillDir).followedBy([File('AGENTS.md'), File('README.md')])) {
    if (!file.existsSync()) continue;
    for (final match in id.allMatches(file.readAsStringSync())) {
      final token = match.group(1)!;
      if (token.endsWith('-')) continue;
      if (!ruleFiles.contains(token)) errors.add('${file.path} mentions `$token`, which has no rule file');
    }
  }

  final counts = {
    'data/palettes.csv': 30,
    'data/fonts.csv': 20,
    'data/styles.csv': 24,
    'data/motion.csv': 14,
  };
  for (final entry in counts.entries) {
    final rows = File('${skillDir.path}/${entry.key}').readAsLinesSync().where((l) => l.trim().isNotEmpty).length - 1;
    if (rows != entry.value) errors.add('${entry.key} has $rows rows, expected ${entry.value}');
  }

  for (final command in ['shape', 'theme', 'typeset', 'layout', 'adapt', 'animate', 'audit', 'critique', 'polish', 'harden']) {
    final file = File('${skillDir.path}/reference/commands/$command.md');
    if (!file.existsSync()) errors.add('missing command playbook ${file.path}');
  }

  final agents = File('AGENTS.md').readAsStringSync();
  if (agents.length > 4000) errors.add('AGENTS.md is ${agents.length} characters; Copilot-sized copy should stay under 4000');

  if (errors.isEmpty) {
    stdout.writeln('validate: ok (${ruleFiles.length} rules, description ${front?['description']?.length} chars)');
  } else {
    for (final error in errors) {
      stderr.writeln('validate: $error');
    }
    exit(1);
  }
}

Map<String, String>? _frontmatter(String skill) {
  if (!skill.startsWith('---\n')) return null;
  final end = skill.indexOf('\n---', 4);
  if (end < 0) return null;
  final out = <String, String>{};
  String? key;
  final buffer = StringBuffer();
  for (final line in skill.substring(4, end).split('\n')) {
    final top = RegExp(r'^([A-Za-z0-9-]+):\s*(.*)$').firstMatch(line);
    if (top != null && !line.startsWith(' ')) {
      if (key != null) out[key] = buffer.toString().trim();
      key = top.group(1);
      buffer
        ..clear()
        ..write(top.group(2));
    } else if (key != null) {
      buffer
        ..write(' ')
        ..write(line.trim());
    }
  }
  if (key != null) out[key] = buffer.toString().trim();
  for (final entry in out.entries) {
    var value = entry.value;
    if (value.startsWith('"') && value.endsWith('"')) value = value.substring(1, value.length - 1);
    out[entry.key] = value;
  }
  return out;
}

Iterable<File> _markdown(Directory root) sync* {
  for (final entity in root.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.md')) yield entity;
  }
}
