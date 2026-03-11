import 'package:flutter/material.dart';
import 'package:mytodo/features/daily_notes/presentation/pages/daily_notes_page.dart';
import 'package:mytodo/features/settings/presentation/pages/settings_page.dart';
import 'package:mytodo/features/tasks/presentation/pages/task_page.dart';
import 'package:mytodo/features/pomodoro/presentation/pages/pomodoro_page.dart';
import 'package:mytodo/features/habits/presentation/pages/habits_page.dart';
import 'package:mytodo/ui/dashboard_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const TaskPage(),
      const PomodoroPage(), // New Focus Mode Tab
      const HabitsPage(), // New Habits Tab
      const DailyNotesPage(),
      const DashboardScreen(), // FinPilot Integration
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
          NavigationDestination(
              icon: Icon(Icons.timer_outlined), label: 'Focus'),
          NavigationDestination(
              icon: Icon(Icons.repeat_rounded), label: 'Habits'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined), label: 'Notes'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'FinPilot'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
