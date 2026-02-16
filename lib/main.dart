import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/task_form_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.load();
  runApp(ChangeNotifierProvider.value(value: appState, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return MaterialApp(
      title: 'Todo For Myself',
      themeMode: state.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
        if (settings.name == '/task-form') {
          return MaterialPageRoute(
            builder: (_) => TaskFormScreen(taskId: settings.arguments as String?),
          );
        }
        if (settings.name == '/task-detail') {
          return MaterialPageRoute(
            builder: (_) => TaskDetailScreen(taskId: settings.arguments as String),
          );
        }
        if (settings.name == '/journal') {
          return MaterialPageRoute(builder: (_) => const JournalScreen());
        }
        if (settings.name == '/calendar') {
          return MaterialPageRoute(builder: (_) => const CalendarScreen());
        }
        return null;
      },
    );
  }
}
