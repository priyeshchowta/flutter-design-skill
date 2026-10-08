// "Before": what an agent produces without the skill. Intentionally full of slop.
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker'), backgroundColor: Colors.deepPurple),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.purple, Colors.blue]),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: const Text('7 day streak 🔥', style: TextStyle(fontSize: 24, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          for (final h in ['Read', 'Run', 'Meditate'])
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  GestureDetector(onTap: () {}, child: Icon(Icons.check_circle, color: Colors.green, size: 20)),
                  const SizedBox(width: 16),
                  Text(h, style: const TextStyle(fontSize: 18)),
                ]),
              ),
            ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ]),
      ),
    );
  }
}
