// Generates one Dart file per rule snippet so `flutter analyze` can catch
// APIs that do not exist. Incorrect examples are included too: they must be
// real Dart using real widgets, only the design choice is wrong.
//
//   dart run tool/check_snippets.dart
//   flutter analyze test/snippet_check
//
// Generated files are gitignored.
import 'dart:io';

void main() {
  final rules = Directory('skills/flutter-design/reference/rules');
  final rulesDir = rules.existsSync()
      ? rules
      : Directory('skills/flutter-design/reference/rules');
  if (!rulesDir.existsSync()) {
    stderr.writeln('Run from the repo root. Rules dir not found.');
    exit(1);
  }
  final out = Directory('test/snippet_check')..createSync(recursive: true);
  for (final f in out.listSync()) {
    if (f is File) f.deleteSync();
  }
  var n = 0;
  for (final file in rulesDir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.md') || file.path.endsWith('_index.md')) continue;
    final id = file.uri.pathSegments.last.replaceAll('.md', '');
    final blocks = _dartBlocks(file.readAsStringSync());
    for (var i = 0; i < blocks.length; i++) {
      final name = '${id}_$i'.replaceAll('-', '_');
      File('${out.path}/$name.dart').writeAsStringSync(_wrap(name, blocks[i]));
      n++;
    }
  }
  File('${out.path}/analysis_options.yaml').writeAsStringSync('''
analyzer:
  errors:
    unnecessary_import: ignore
    unused_import: ignore
    unused_shown_name: ignore
''');
  stdout.writeln('Wrote $n snippet files to ${out.path}');
}

List<String> _dartBlocks(String md) {
  final out = <String>[];
  final re = RegExp(r'```dart\n([\s\S]*?)```');
  for (final m in re.allMatches(md)) {
    out.add(m.group(1)!.trim());
  }
  return out;
}

const _preamble = '''
    final cs = Theme.of(context).colorScheme;
    final scheme = cs;
    final textTheme = Theme.of(context).textTheme;
    final base = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    final seed = const Color(0xFF0F6B72);
    final items = List<int>.generate(20, (i) => i);
    final rest = items.skip(1);
    final i = 0;
    final label = 'Label';
    final longTitle = 'A long title that should ellipsize';
    final longLabel = longTitle;
    final article = 'Body copy';
    final body = article;
    final visible = true;
    final pressed = false;
    final open = true;
    final reduce = false;
    final d = const Duration(milliseconds: 200);
    final offset = Offset.zero;
    final anim = const AlwaysStoppedAnimation<double>(1);
    final v = 1.0;
    final f = () {};
    final go = () {};
    final add = () {};
    final reload = () {};
    final no = () {};
    final yes = () {};
    final card = const SizedBox.shrink();
    final lightTheme = ThemeData();
    final bigTree = const SizedBox.shrink();
    final child = const SizedBox.shrink();
    final button = const SizedBox.shrink();
    final form = const SizedBox.shrink();
    final header = const SizedBox.shrink();
    final subtitle = const SizedBox.shrink();
    final section = const SizedBox.shrink();
    final row = const SizedBox.shrink();
    final btnA = const SizedBox.shrink();
    final btnB = const SizedBox.shrink();
    final firstAction = const SizedBox.shrink();
    final secondAction = const SizedBox.shrink();
    final tabBar = const SizedBox.shrink();
    final bar = NavigationBar(destinations: const <NavigationDestination>[], onDestinationSelected: _noop, selectedIndex: 0);
    final rail = NavigationRail(destinations: const <NavigationRailDestination>[], selectedIndex: 0);
    final drawer = const Drawer();
    final page = const SizedBox.shrink();
    final dirty = false;
    final messenger = ScaffoldMessenger.of(context);
    final mq = MediaQuery.of(context);
    final url = 'https://example.com';
    final h = const Habit('Read', 'detail', false);
    final days = 7;
    final boldText = false;
    final offline = false;
    final highContrast = false;
    final brightness = Brightness.light;
    final isOpen = true;
    final from = 0.0;
    final to = 1.0;
    final velocity = 0.0;
    final controller = AnimationController.unbounded(vsync: const _Ticker());
    final fallbackLight = ColorScheme.fromSeed(seedColor: seed);
    final l = fallbackLight;
    final confirmDiscard = () {};
    final repo = _Repo();
    final id = 'id';
    final api = _Api();
    final _count = ValueNotifier<int>(0);
    final n = 3;
    final windowWidth = MediaQuery.sizeOf(context).width;
''';

/// Puts a semicolon on the last code line, before any trailing comment.
String _terminate(String body) {
  final lines = body.split('\n');
  for (var i = lines.length - 1; i >= 0; i--) {
    final commentAt = _commentIndex(lines[i]);
    final code = (commentAt >= 0 ? lines[i].substring(0, commentAt) : lines[i]).trimRight();
    if (code.trim().isEmpty) continue;
    if (code.endsWith(';') || code.endsWith('}') || code.endsWith(',') || code.endsWith('{')) return body;
    final insertion = code.length;
    // code may have trailing spaces already trimmed; insert at end of code.
    if (commentAt >= 0) {
      lines[i] = '${lines[i].substring(0, commentAt).trimRight()}; ${lines[i].substring(commentAt)}';
    } else {
      lines[i] = '${lines[i].substring(0, insertion).trimRight()};${lines[i].substring(insertion)}';
    }
    return lines.join('\n');
  }
  return body;
}

int _commentIndex(String line) {
  var quote = '';
  for (var i = 0; i < line.length - 1; i++) {
    final c = line[i];
    if (quote.isNotEmpty) {
      if (c == quote && line[i - 1] != r'\') quote = '';
      continue;
    }
    if (c == "'" || c == '"') {
      quote = c;
    } else if (c == '/' && line[i + 1] == '/') {
      return i;
    }
  }
  return -1;
}

String _asStatement(String body) {
  final lastCode = body.trimRight().split('\n').last;
  final code = lastCode.split('//').first.trim();
  if (code.endsWith(';') || code.endsWith('}') || code.endsWith('{')) return body;
  if (body.contains(';')) return _terminate(body);
  final lines = body.split('\n');
  lines[0] = 'final value = ${lines[0]}';
  return _terminate(lines.join('\n'));
}

String _wrap(String name, String snippet) {
  final imports = snippet
      .split('\n')
      .where((l) => l.trim().startsWith('import '))
      .toList();
  final snippetBody = snippet
      .split('\n')
      .where((l) => !l.trim().startsWith('import '))
      .join('\n')
      .trim();
  snippet = snippetBody;
  final firstCode = snippet
      .split('\n')
      .map((l) => l.trim())
      .firstWhere((l) => l.isNotEmpty && !l.startsWith('//'), orElse: () => '');
  final libraryLevel = RegExp(r'^(import |class |enum |extension |abstract |mixin )').hasMatch(firstCode);
  final namedArg = RegExp(r'^[\w.]+\s*:').hasMatch(firstCode) &&
      !firstCode.startsWith('return') &&
      !RegExp(r'^(if|for|while|switch|final|var|const|late)\b').hasMatch(firstCode);

  final buffer = StringBuffer()
    ..writeln("import 'dart:io' show Platform;")
    ..writeln("import 'dart:ui' show ImageFilter, lerpDouble;")
    ..writeln("import 'package:flutter/cupertino.dart';")
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln("import 'package:flutter/physics.dart';")
    ..writeln("import 'package:flutter/scheduler.dart';")
    ..writeln("import 'package:flutter/semantics.dart';")
    ..writeln("import 'package:flutter/services.dart';");
  for (final line in imports) {
    if (line.contains('package:flutter/material.dart') ||
        line.contains('package:flutter/semantics.dart') ||
        line.contains('package:flutter/cupertino.dart') ||
        line.contains('package:flutter/physics.dart')) {
      continue;
    }
    if (line.contains('package:material_ui/') || line.contains('package:cupertino_ui/')) {
      buffer.writeln('// ${line.trim()} // resolved in projects that depend on the package');
      continue;
    }
    buffer.writeln(line);
  }
  buffer
    ..writeln()
    ..writeln('// ignore_for_file: unused_element, unused_local_variable, unused_field, dead_code')
    ..writeln()
    ..writeln(_stubs);

  if (firstCode.isEmpty) {
    buffer.writeln('// snippet is prose-only');
    return buffer.toString();
  }
  final isTest = snippet.contains('testWidgets') || snippet.contains('expectLater') || snippet.contains('meetsGuideline');
  if (isTest) {
    final inner = snippet.trim().startsWith('testWidgets')
        ? snippet.trim()
        : '''
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    $snippet''';
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ${snippet.trim().startsWith('testWidgets') ? inner : '''testWidgets('snippet', (WidgetTester tester) async {
$inner
  });'''}
}
''';
  }
  if (!snippet.contains('enum WindowClass') && !snippet.contains('class Motion')) {
    buffer.writeln(_extraStubs);
  }
  if (!snippet.contains('class AppTokens')) buffer.writeln(_appTokensStub);
  if (!snippet.contains('extension TokensX')) buffer.writeln(_tokensExt);
  if (libraryLevel) {
    buffer.writeln(snippet);
  } else {
    var body = snippet.trim();
    if (namedArg) {
      var inner = body.trim();
      if (inner.endsWith(',')) inner = inner.substring(0, inner.length - 1);
      body = 'final record = (\n$inner,\n);';
    } else if (RegExp(r'^(return|if|for|while|switch|await|try|final|var|const|late)\b').hasMatch(firstCode)) {
      body = _terminate(body);
    } else {
      body = _asStatement(body);
    }
    if (snippet.contains('setState(')) {
      buffer
        ..writeln('class Host_$name extends StatefulWidget {')
        ..writeln('  const Host_$name({super.key});')
        ..writeln('  @override')
        ..writeln('  State<Host_$name> createState() => _Host_${name}State();')
        ..writeln('}')
        ..writeln('class _Host_${name}State extends State<Host_$name> {')
        ..writeln('  @override')
        ..writeln('  Widget build(BuildContext context) {')
        ..writeln(_preamble)
        ..writeln(body)
        ..writeln('    return const SizedBox.shrink();')
        ..writeln('  }')
        ..writeln('}');
    } else {
      buffer
        ..writeln('class Host_$name extends StatelessWidget {')
        ..writeln('  const Host_$name({super.key});')
        ..writeln('  @override')
        ..writeln('  Widget build(BuildContext context) {')
        ..writeln(_preamble)
        ..writeln(body)
        ..writeln('    return const SizedBox.shrink();')
        ..writeln('  }')
        ..writeln('}');
    }
  }
  return buffer.toString();
}

const _stubs = '''
class Gap extends StatelessWidget {
  const Gap(this.extent, {super.key});
  final double extent;
  @override
  Widget build(BuildContext context) => SizedBox(width: extent, height: extent);
}

abstract final class Symbols {
  static const home = Icons.home;
  static const search = Icons.search;
}

class Habit {
  const Habit(this.name, this.detail, this.done);
  final String name, detail;
  final bool done;
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.body, required this.action});
  final String title, body;
  final Widget action;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class Tile extends StatelessWidget {
  const Tile(this.item, {super.key});
  final int item;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class LeadFeature extends StatelessWidget {
  const LeadFeature({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class Detail extends StatelessWidget {
  const Detail({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class FeatureRow extends StatelessWidget {
  const FeatureRow(this.item, {super.key});
  final int item;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class Compact extends StatelessWidget {
  const Compact({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _Repo {
  void delete(String id) {}
  void softDelete(String id) {}
  void restore(String id) {}
}

class _Api {
  Future<int> load() async => 1;
}

void _noop(int _) {}

class _Ticker implements TickerProvider {
  const _Ticker();
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

class _Tokens {
  const _Tokens();
  double get space1 => 4;
  double get space2 => 8;
  double get space3 => 12;
  double get space4 => 16;
  double get space5 => 24;
  double get space6 => 32;
  double get space7 => 48;
  double get radiusM => 16;
  double get radiusSurface => 16;
  double get iconM => 24;
  Color get success => const Color(0xFF2E7D4F);
}

class _GfConfig {
  bool allowRuntimeFetching = true;
}

abstract final class GoogleFonts {
  static final config = _GfConfig();
  static TextTheme interTextTheme(TextTheme t) => t;
  static TextTheme dmSansTextTheme(TextTheme t) => t;
  static TextTheme barlowTextTheme(TextTheme t) => t;
  static TextStyle inter({TextStyle? textStyle}) => textStyle ?? const TextStyle();
  static TextStyle fraunces({TextStyle? textStyle}) => textStyle ?? const TextStyle();
  static TextStyle barlowCondensed({TextStyle? textStyle}) => textStyle ?? const TextStyle();
}

class DynamicColorBuilder extends StatelessWidget {
  const DynamicColorBuilder({super.key, required this.builder});
  final Widget Function(ColorScheme? light, ColorScheme? dark) builder;
  @override
  Widget build(BuildContext context) => builder(null, null);
}

extension Harmonize on ColorScheme {
  ColorScheme harmonized() => this;
}

class OpenContainer extends StatelessWidget {
  const OpenContainer({super.key, required this.closedBuilder, required this.openBuilder});
  final Widget Function(BuildContext, VoidCallback) closedBuilder;
  final Widget Function(BuildContext, VoidCallback) openBuilder;
  @override
  Widget build(BuildContext context) => closedBuilder(context, () {});
}
''';

const _extraStubs = '''
enum WindowClass { compact, medium, expanded, large, extraLarge }

WindowClass windowClassOf(BuildContext context) => WindowClass.compact;

abstract final class Motion {
  static const press = Duration(milliseconds: 120);
  static const state = Duration(milliseconds: 200);
  static const enter = Cubic(0.23, 1, 0.32, 1);
  static Duration of(BuildContext context, Duration duration) => duration;
}

class AppTheme {
  static ThemeData light({bool highContrast = false}) => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F6B72), contrastLevel: highContrast ? 1.0 : 0.0),
      );
  static ThemeData dark({bool highContrast = false}) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F6B72),
          brightness: Brightness.dark,
          contrastLevel: highContrast ? 1.0 : 0.0,
        ),
      );
}

class Header extends StatelessWidget {
  const Header({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class HeavyAnimatedChart extends StatelessWidget {
  const HeavyAnimatedChart({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class Wide extends StatelessWidget {
  const Wide({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

abstract final class FontAwesomeIcons {
  static const user = Icons.person;
}
''';

const _tokensExt = '''
extension TokensX on BuildContext {
  _Tokens get tokens => const _Tokens();
}
''';

const _appTokensStub = '''
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({required this.success});
  final Color success;
  @override
  AppTokens copyWith({Color? success}) => AppTokens(success: success ?? this.success);
  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) => this;
}
''';
