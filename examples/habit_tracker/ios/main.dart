// iOS reading of the same habit screen.
// Design Read: daily habit dashboard for people building routines, calm, Cupertino on iPhone.
// Glass is one floating tab bar over the list, with a blur fallback (no official Liquid Glass in Flutter 3.47).
import 'dart:ui';

import 'package:flutter/cupertino.dart';

void main() => runApp(const HabitApp());

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(applyThemeToAll: true),
      home: HomePage(),
    );
  }
}

class Habit {
  const Habit(this.name, this.detail, this.done);
  final String name;
  final String detail;
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
    final bottom = MediaQuery.paddingOf(context).bottom;
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const CupertinoSliverNavigationBar(
                largeTitle: Text('Today'),
                border: null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 28 + bottom + 76),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Streak(),
                      SizedBox(height: 28),
                      _HabitList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 48,
            right: 48,
            bottom: bottom + 8,
            child: const _GlassTabBar(),
          ),
        ],
      ),
    );
  }
}

class _Streak extends StatelessWidget {
  const _Streak();

  @override
  Widget build(BuildContext context) {
    final primary = CupertinoColors.label.resolveFrom(context);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    return Semantics(
      container: true,
      label: '7 day streak',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7',
            style: TextStyle(
              fontSize: 72,
              height: 0.9,
              fontWeight: FontWeight.w700,
              letterSpacing: -2,
              color: primary,
            ),
          ),
          const SizedBox(height: 4),
          Text('day streak', style: TextStyle(fontSize: 17, color: secondary)),
          const SizedBox(height: 16),
          const _Week(),
        ],
      ),
    );
  }
}

class _Week extends StatelessWidget {
  const _Week();

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final fill = CupertinoColors.activeBlue.resolveFrom(context);
    final idle = CupertinoColors.tertiarySystemFill.resolveFrom(context);
    final onFill = CupertinoColors.white;
    final label = CupertinoColors.secondaryLabel.resolveFrom(context);
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i < 5 ? fill : idle,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: i < 5 ? onFill : label,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HabitList extends StatelessWidget {
  const _HabitList();

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      margin: EdgeInsets.zero,
      header: const Text('Habits'),
      children: [
        for (final habit in _habits)
          CupertinoListTile(
            title: Text(habit.name),
            subtitle: Text(habit.detail),
            leading: Icon(
              habit.done ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
              color: habit.done
                  ? CupertinoColors.activeBlue.resolveFrom(context)
                  : CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
          ),
      ],
    );
  }
}

class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar();

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    final fill = brightness == Brightness.dark ? const Color(0xCC1C1C1E) : const Color(0xD9F2F2F7);
    final stroke = brightness == Brightness.dark ? const Color(0x33FFFFFF) : const Color(0x66FFFFFF);
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: stroke),
          ),
          child: const SizedBox(
            height: 62,
            child: Row(
              children: [
                Expanded(child: _Tab(icon: CupertinoIcons.checkmark_circle_fill, label: 'Today', selected: true)),
                Expanded(child: _Tab(icon: CupertinoIcons.chart_bar, label: 'Progress', selected: false)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.icon, required this.label, required this.selected});

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? CupertinoColors.activeBlue.resolveFrom(context)
        : CupertinoColors.secondaryLabel.resolveFrom(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
