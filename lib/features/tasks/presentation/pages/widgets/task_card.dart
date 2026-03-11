import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mytodo/features/tasks/domain/models/task.dart';
import 'package:mytodo/features/tasks/presentation/controllers/task_controller.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onCompleteChanged});

  final Task task;
  final ValueChanged<bool>? onCompleteChanged;

  String _formatMs(int totalMs) {
    if (totalMs < 0) totalMs = 0;
    final hours = totalMs ~/ 3600000;
    final minutes = (totalMs % 3600000) ~/ 60000;
    final seconds = (totalMs % 60000) ~/ 1000;
    final centiseconds = (totalMs % 1000) ~/ 10; // show 2 digits

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
  }

  String _formatHM(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.read<TaskController>();

    final isOverdue = task.dueDate != null &&
        !task.isCompleted &&
        DateTime.now().isAfter(task.dueDate!.add(const Duration(days: 1)));

    final cardBg = isDark
        ? (task.isRunning ? const Color(0xFF1A2540) : const Color(0xFF1C1C2E))
        : (task.isRunning
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
            : theme.colorScheme.surface);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.isRunning
              ? theme.colorScheme.primary.withValues(alpha: 0.7)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06)),
          width: task.isRunning ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: task.isRunning
                ? theme.colorScheme.primary
                    .withValues(alpha: isDark ? 0.3 : 0.15)
                : Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: task.isRunning ? 16 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final wasCompleted = task.isCompleted;
          controller.toggleTask(task.id);
          if (!wasCompleted && onCompleteChanged != null) {
            onCompleteChanged!(true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () {
                      final wasCompleted = task.isCompleted;
                      controller.toggleTask(task.id);
                      if (!wasCompleted && onCompleteChanged != null) {
                        onCompleteChanged!(true);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted
                            ? Colors.green.shade500
                            : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted
                              ? Colors.green.shade500
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title & badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                            color: task.isCompleted
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45)
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (task.isOptional)
                              _Chip(
                                label: 'Optional',
                                icon: Icons.star_rounded,
                                color: Colors.amber,
                              ),
                            if (task.dueDate != null)
                              _Chip(
                                label:
                                    DateFormat('MMM d').format(task.dueDate!),
                                icon: Icons.event_rounded,
                                color: isOverdue
                                    ? Colors.red
                                    : theme.colorScheme.secondary,
                                bold: isOverdue,
                              ),
                            if (task.startTime != null)
                              _Chip(
                                label: _formatHM(task.startTime!),
                                icon: Icons.alarm_rounded,
                                color: theme.colorScheme.primary,
                              ),
                            if (task.endTime != null)
                              _Chip(
                                label: _formatHM(task.endTime!),
                                icon: Icons.alarm_off_rounded,
                                color: Colors.deepOrange,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Overflow menu
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        size: 20,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    onSelected: (value) {
                      if (value == 'delete') {
                        controller.deleteTask(task.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                color: Colors.red, size: 18),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Stopwatch row
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white
                          .withValues(alpha: task.isRunning ? 0.08 : 0.04)
                      : Colors.black
                          .withValues(alpha: task.isRunning ? 0.05 : 0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      task.isRunning
                          ? Icons.timer_rounded
                          : Icons.timer_outlined,
                      size: 16,
                      color: task.isRunning
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 8),
                    // Millisecond stopwatch display
                    Text(
                      _formatMs(task.timerMilliseconds),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight:
                            task.isRunning ? FontWeight.w800 : FontWeight.w500,
                        color: task.isRunning
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    if (!task.isCompleted)
                      GestureDetector(
                        onTap: () => controller.toggleTimer(task.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.isRunning
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            task.isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 18,
                            color: task.isRunning
                                ? Colors.white
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 14, color: Colors.green.shade500),
                          const SizedBox(width: 4),
                          Text(
                            'Done',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade500),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
        begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    this.bold = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: bold ? 0.7 : 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
