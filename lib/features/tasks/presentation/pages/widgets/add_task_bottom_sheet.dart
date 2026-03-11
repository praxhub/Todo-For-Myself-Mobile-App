import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mytodo/features/tasks/presentation/controllers/task_controller.dart';
import 'package:intl/intl.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _controller = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isOptional = false;
  String? _selectedCategory;
  final List<String> _categories = [
    'Work',
    'Personal',
    'Health',
    'Finance',
    'Ideas',
    'Other'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  DateTime? _buildDateTime(TimeOfDay? time) {
    if (time == null) return null;
    final base = _selectedDate ?? DateTime.now();
    return DateTime(base.year, base.month, base.day, time.hour, time.minute);
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Widget _buildTimeButton({
    required String label,
    required IconData icon,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isSet = value != null;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSet ? theme.colorScheme.primary : theme.dividerColor,
              width: isSet ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSet
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: isSet
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Text(
                isSet ? _formatTime(value) : label,
                style: TextStyle(
                  color: isSet
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: isSet ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _controller.text.trim().isNotEmpty;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Task',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  // Optional toggle
                  GestureDetector(
                    onTap: () => setState(() => _isOptional = !_isOptional),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isOptional
                            ? Colors.amber.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isOptional
                              ? Colors.amber.shade600
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isOptional
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: _isOptional
                                ? Colors.amber.shade600
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _isOptional
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _isOptional
                                  ? Colors.amber.shade600
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Task title input
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Category Chips
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    selectedColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Date picker row
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedDate != null
                      ? theme.colorScheme.secondary
                      : theme.dividerColor,
                  width: _selectedDate != null ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: _selectedDate != null
                    ? theme.colorScheme.secondary.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded,
                      size: 18,
                      color: _selectedDate != null
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate == null
                        ? 'Set due date (optional)'
                        : DateFormat('EEE, MMM d, yyyy').format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate != null
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: _selectedDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedDate = null),
                      child: Icon(Icons.close_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 24-hour time pickers
          Row(
            children: [
              _buildTimeButton(
                label: 'Start Time',
                icon: Icons.alarm_rounded,
                value: _startTime,
                onTap: () => _pickTime(isStart: true),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('→', style: TextStyle(fontSize: 20)),
              ),
              _buildTimeButton(
                label: 'End Time',
                icon: Icons.alarm_off_rounded,
                value: _endTime,
                onTap: () => _pickTime(isStart: false),
              ),
            ],
          ),
          if (_startTime != null || _endTime != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_rounded,
                      size: 14, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Reminders will fire at set times',
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Submit button
          FilledButton.icon(
            onPressed: canSubmit
                ? () async {
                    await context.read<TaskController>().addTask(
                          _controller.text,
                          dueDate: _selectedDate,
                          isOptional: _isOptional,
                          category: _selectedCategory,
                          startTime: _buildDateTime(_startTime),
                          endTime: _buildDateTime(_endTime),
                        );
                    if (context.mounted) Navigator.pop(context);
                  }
                : null,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Create Task',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
