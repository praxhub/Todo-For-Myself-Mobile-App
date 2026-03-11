import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mytodo/features/tasks/presentation/controllers/task_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'widgets/task_card.dart';
import 'widgets/add_task_bottom_sheet.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  String? _selectedCategoryFilter;
  final List<String> _categories = [
    'All',
    'Work',
    'Personal',
    'Health',
    'Finance',
    'Ideas',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskController>().loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddTaskBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Consumer<TaskController>(
            builder: (context, tc, _) {
              var pending = tc.tasks.where((t) => !t.isCompleted).toList();
              var done = tc.tasks.where((t) => t.isCompleted).toList();
              final running = tc.tasks.where((t) => t.isRunning).firstOrNull;

              if (_selectedCategoryFilter != null &&
                  _selectedCategoryFilter != 'All') {
                pending = pending
                    .where((t) => t.category == _selectedCategoryFilter)
                    .toList();
                done = done
                    .where((t) => t.category == _selectedCategoryFilter)
                    .toList();
              }

              final activeList = _tabController.index == 0 ? pending : done;

              if (tc.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return NestedScrollView(
                headerSliverBuilder: (ctx, _) => [
                  SliverAppBar(
                    floating: true,
                    pinned: false,
                    expandedHeight: 0,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Tasks',
                          style: GoogleFonts.outfit(
                            textStyle: theme.appBarTheme.titleTextStyle,
                          ),
                        ),
                        Text(
                          '${pending.length} pending • ${done.length} done',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      if (running != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer_rounded,
                                    size: 14, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Running',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    bottom: TabBar(
                      controller: _tabController,
                      onTap: (_) => setState(() {}),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13),
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      tabs: [
                        Tab(text: 'Pending (${pending.length})'),
                        Tab(text: 'Completed (${done.length})'),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected =
                              (_selectedCategoryFilter ?? 'All') == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text(category),
                              onPressed: () {
                                setState(() {
                                  _selectedCategoryFilter = category;
                                });
                              },
                              backgroundColor: isSelected
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: isSelected
                                    ? BorderSide(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.2))
                                    : BorderSide.none,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                body: activeList.isEmpty
                    ? _emptyState(context, _tabController.index == 0, isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount: activeList.length,
                        itemBuilder: (context, index) => TaskCard(
                          task: activeList[index],
                          onCompleteChanged: (justCompleted) {
                            if (justCompleted) {
                              _confettiController.play();
                            }
                          },
                        ),
                      ),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBottomSheet,
        icon: const Icon(Icons.add_rounded),
        label: Text('New Task',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _emptyState(BuildContext context, bool isPending, bool isDark) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              isPending
                  ? Icons.task_alt_rounded
                  : Icons.history_toggle_off_rounded,
              size: 40,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isPending ? 'All caught up! 🎉' : 'No completed tasks yet',
            style:
                GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            isPending
                ? 'Tap "New Task" to plan your day.'
                : 'Complete a task to see it here.',
            style: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 14),
          ),
        ],
      ),
    );
  }
}
