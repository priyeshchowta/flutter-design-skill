// "After": same screen designed with flutter-design.
// Design Read: Reading this as: daily habit dashboard for people building routines, calm and encouraging,
// leaning Material on phone. Dials: VARIANCE 5, MOTION 4, DENSITY 4. Palette p01 Tidewater Teal (seed 0xFF0F6B72).
// Primary action: mark today's habit done. One lead element (streak), rest is a divided list.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

void main() => runApp(const HabitApp());

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habits',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class Habit {
  const Habit(this.name, this.detail, this.done);
  final String name, detail;
  final bool done;
}

const _habits = [
  Habit('Read 20 pages', 'Evening, 22 min avg', true),
  Habit('Morning run', '5.2 km, 31 min', false),
  Habit('Meditate', '10 min, before breakfast', false),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: CustomScrollView(slivers: [
              const SliverAppBar.large(title: Text('Today')),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: t.space4),
                sliver: SliverList.list(children: [
                  const _StreakHeader(days: 7),
                  SizedBox(height: t.space6),
                  Text('Habits', style: context.text.titleMedium),
                  SizedBox(height: t.space2),
                  for (final h in _habits) _HabitRow(habit: h),
                  SizedBox(height: t.space7),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _StreakHeader extends StatelessWidget {
  const _StreakHeader({required this.days});
  final int days;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      container: true,
      label: '$days day streak',
      child: Container(
        padding: EdgeInsets.all(t.space5),
        decoration: BoxDecoration(
          color: context.cs.primaryContainer,
          borderRadius: BorderRadius.circular(t.radiusSurface),
        ),
        // Wrap, not Row: survives 2.0x text scale (a11y-text-scale-2x).
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: t.space2,
          children: [
            Text('$days', style: context.text.displayLarge?.copyWith(color: context.cs.onPrimaryContainer)),
            Padding(
              padding: EdgeInsets.only(bottom: t.space2),
              child: Text('day streak', style: context.text.titleMedium?.copyWith(color: context.cs.onPrimaryContainer)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitRow extends StatefulWidget {
  const _HabitRow({required this.habit});
  final Habit habit;
  @override
  State<_HabitRow> createState() => _HabitRowState();
}

class _HabitRowState extends State<_HabitRow> {
  late bool _done = widget.habit.done;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cs = context.cs;
    return MergeSemantics(
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radiusSurface),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _done = !_done);
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: t.space3, horizontal: t.space1),
            child: Row(children: [
              AnimatedSwitcher(
                duration: Motion.of(context, Motion.state),
                switchInCurve: Motion.enter,
                child: Icon(
                  _done ? Icons.check_circle : Icons.circle_outlined,
                  key: ValueKey(_done),
                  size: t.iconM,
                  color: _done ? cs.primary : cs.outline,
                  semanticLabel: _done ? 'Done' : 'Not done',
                ),
              ),
              SizedBox(width: t.space4),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.habit.name, style: context.text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(widget.habit.detail, style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
