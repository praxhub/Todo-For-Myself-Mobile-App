import 'package:flutter_test/flutter_test.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/domain/models/task.dart';
import 'package:todo_for_myself_mobile_app/core/persistence/local_store.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/data/repositories/theme_repository.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/presentation/task_app.dart';

void main() {
  group('Task widget flows', () {
    testWidgets('task CRUD works from UI interactions', (tester) async {
      final store = MemoryLocalStore();
      final themeRepo = ThemeRepository(store);
      final today = DateTime.now();

      await tester.pumpWidget(TaskApp(
        initialTasks: [],
        themeRepository: themeRepo,
        initialSelectedDate: DateTime(today.year, today.month, today.day),
      ));

      await tester.enterText(find.byKey(const Key('task_input')), 'Buy milk');
      await tester.tap(find.byKey(const Key('add_task_button')));
      await tester.pumpAndSettle();
      expect(find.text('Buy milk'), findsOneWidget);

      await tester.tap(find.text('Buy milk'));
      await tester.pumpAndSettle();
      expect(find.text('Buy milk (edited)'), findsOneWidget);

      await tester.tap(find.byKey(const Key('delete_1')));
      await tester.pumpAndSettle();
      expect(find.text('Buy milk (edited)'), findsNothing);
    });

    testWidgets('today filter shows only tasks for current day', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final app = TaskApp(
        initialTasks: [
          Task(id: '1', title: 'Today Task', dueDate: today),
          Task(id: '2', title: 'Tomorrow Task', dueDate: tomorrow),
        ],
        themeRepository: ThemeRepository(MemoryLocalStore()),
        initialSelectedDate: tomorrow,
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.text('Tomorrow Task'), findsOneWidget);
      expect(find.text('Today Task'), findsNothing);

      await tester.tap(find.byKey(const Key('today_filter_checkbox')));
      await tester.pumpAndSettle();

      expect(find.text('Tomorrow Task'), findsNothing);
      expect(find.text('Today Task'), findsNothing);

      await tester.tap(find.byKey(const Key('prev_date_button')));
      await tester.pumpAndSettle();
      expect(find.text('Today Task'), findsOneWidget);
    });

    testWidgets('calendar date selection changes visible tasks', (tester) async {
      final baseDate = DateTime(2026, 1, 10);
      await tester.pumpWidget(TaskApp(
        initialTasks: [
          Task(id: '1', title: 'Jan 10 task', dueDate: baseDate),
          Task(id: '2', title: 'Jan 11 task', dueDate: baseDate.add(const Duration(days: 1))),
        ],
        themeRepository: ThemeRepository(MemoryLocalStore()),
        initialSelectedDate: baseDate,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Jan 10 task'), findsOneWidget);
      expect(find.text('Jan 11 task'), findsNothing);

      await tester.tap(find.byKey(const Key('next_date_button')));
      await tester.pumpAndSettle();

      expect(find.text('Jan 10 task'), findsNothing);
      expect(find.text('Jan 11 task'), findsOneWidget);
    });

    testWidgets('theme toggle persists to local storage', (tester) async {
      final store = MemoryLocalStore();
      final themeRepo = ThemeRepository(store);

      await tester.pumpWidget(TaskApp(
        initialTasks: [],
        themeRepository: themeRepo,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('theme_toggle')));
      await tester.pumpAndSettle();
      expect(await store.getString('is_dark_mode'), 'true');

      final restartedRepo = ThemeRepository(MemoryLocalStore(store.snapshot()));
      expect(await restartedRepo.loadThemeMode(), isTrue);
    });
  });
}
