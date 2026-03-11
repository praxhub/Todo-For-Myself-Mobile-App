import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:mytodo/core/data/local/hive_database.dart';
import 'package:mytodo/features/daily_notes/data/repositories/local_daily_note_repository.dart';
import 'package:mytodo/features/daily_notes/presentation/controllers/daily_note_controller.dart';
import 'package:mytodo/features/home/presentation/pages/home_page.dart';
import 'package:mytodo/features/settings/data/repositories/local_settings_repository.dart';
import 'package:mytodo/features/settings/presentation/controllers/settings_controller.dart';
import 'package:mytodo/features/tasks/data/repositories/local_task_repository.dart';
import 'package:mytodo/features/tasks/presentation/controllers/task_controller.dart';
import 'package:mytodo/features/pomodoro/data/repositories/local_pomodoro_repository.dart';
import 'package:mytodo/features/pomodoro/presentation/controllers/pomodoro_controller.dart';
import 'package:mytodo/features/habits/data/repositories/local_habit_repository.dart';
import 'package:mytodo/features/habits/presentation/controllers/habit_controller.dart';
import 'package:mytodo/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:mytodo/services/notification_service.dart';
import 'package:mytodo/ui/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize OS Local Notifications
    await NotificationService().initialize();
    await NotificationService().requestPermissions();

    // 1. Initialize existing Hive Database for MyTodo
    await HiveDatabase.initialize();

    // 2. Initialize new SQLite Database for FinPilot (skip if web)
    if (!kIsWeb) {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.database;
    }

    // Global error handlers to prevent red screen of death
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Platform Error: $error');
      return true;
    };

    // Check if onboarding was seen
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    runApp(
      riverpod.ProviderScope(
        // Riverpod injection for FinPilot features
        child: MultiProvider(
          providers: [
            Provider(
                create: (_) => LocalTaskRepository(HiveDatabase.tasksBox())),
            Provider(create: (_) => LocalDailyNoteRepository()),
            Provider(create: (_) => LocalSettingsRepository()),
            Provider(
                create: (_) => LocalPomodoroRepository(
                    HiveDatabase.pomodoroSessionsBox())),
            Provider(
                create: (_) => LocalHabitRepository(HiveDatabase.habitsBox())),
            ChangeNotifierProvider(
              create: (context) =>
                  TaskController(context.read<LocalTaskRepository>()),
            ),
            ChangeNotifierProvider(
              create: (context) => PomodoroController(
                context.read<LocalPomodoroRepository>(),
                context.read<TaskController>(),
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => HabitController(
                context.read<LocalHabitRepository>(),
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => DailyNoteController(
                context.read<LocalDailyNoteRepository>(),
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => SettingsController(
                context.read<LocalSettingsRepository>(),
              )..loadSettings(),
            ),
            ChangeNotifierProvider(
              create: (context) => AnalyticsController(
                context.read<LocalTaskRepository>(),
                context.read<LocalPomodoroRepository>(),
                context.read<LocalHabitRepository>(),
              ),
            ),
          ],
          child: MyTodoApp(hasSeenOnboarding: hasSeenOnboarding),
        ),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('Failed to initialize app: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(const _StartupErrorApp());
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to start MyTodo. Please restart the app.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class MyTodoApp extends StatelessWidget {
  const MyTodoApp({super.key, required this.hasSeenOnboarding});
  final bool hasSeenOnboarding;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settingsController, _) {
        return MaterialApp(
          title: 'MyTodo',
          debugShowCheckedModeBanner: false,
          themeMode: settingsController.isDarkModeEnabled
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F6BF5),
              onPrimary: Colors.white,
              secondary: Color(0xFF00B4A6),
              onSecondary: Colors.white,
              tertiary: Color(0xFF7C5CBF),
              surface: Color(0xFFF8F9FF),
              surfaceContainerHighest: Color(0xFFECEFF9),
              onSurface: Color(0xFF1A1C29),
              error: Color(0xFFE03E3E),
            ),
            navigationBarTheme: const NavigationBarThemeData(
              indicatorColor: Color(0xFFDDE3FF),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF8F9FF),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Color(0xFF1A1C29),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7B9EFF),
              onPrimary: Color(0xFF0A0F1E),
              secondary: Color(0xFF00C9B4),
              onSecondary: Color(0xFF0A0F1E),
              tertiary: Color(0xFFBB86FC),
              surface: Color(0xFF131722),
              surfaceContainerHighest: Color(0xFF1C2136),
              onSurface: Color(0xFFE2E4F0),
              onSurfaceVariant: Color(0xFF9EA3B0),
              error: Color(0xFFFF6B6B),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFF131722),
              indicatorColor: const Color(0xFF7B9EFF).withValues(alpha: 0.2),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: const Color(0xFF1C2136),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D1019),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Color(0xFFE2E4F0),
              ),
            ),
            scaffoldBackgroundColor: const Color(0xFF0D1019),
            dividerColor: Colors.white.withValues(alpha: 0.08),
          ),
          home: hasSeenOnboarding ? const HomePage() : const OnboardingScreen(),
        );
      },
    );
  }
}
