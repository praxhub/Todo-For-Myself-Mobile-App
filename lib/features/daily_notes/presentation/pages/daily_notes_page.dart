import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mytodo/features/daily_notes/presentation/controllers/daily_note_controller.dart';

class DailyNotesPage extends StatefulWidget {
  const DailyNotesPage({super.key});

  @override
  State<DailyNotesPage> createState() => _DailyNotesPageState();
}

class _DailyNotesPageState extends State<DailyNotesPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyNoteController>().loadNotes();
      _syncEditorWithState();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _syncEditorWithState() {
    final note = context.read<DailyNoteController>().noteForSelectedDate();
    _textController.text = note?.content ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Notes')),
      body: Consumer<DailyNoteController>(
        builder: (context, controller, _) {
          final selectedNote = controller.noteForSelectedDate();
          if (_textController.text != (selectedNote?.content ?? '')) {
            _textController.text = selectedNote?.content ?? '';
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: controller.selectedDate,
                selectedDayPredicate: (day) =>
                    isSameDay(day, controller.selectedDate),
                onDaySelected: (selectedDay, _) {
                  controller.setSelectedDate(selectedDay);
                },
                calendarFormat: CalendarFormat.month,
              ),
              const SizedBox(height: 16),
              Text(
                'Daily note for ${controller.selectedDate.toLocal().toString().split(' ').first}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: null,
                minLines: 15,
                onChanged: (text) {
                  controller.saveNoteForSelectedDate(text);
                },
                decoration: InputDecoration(
                  hintText: 'Write your note for today...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (selectedNote != null && selectedNote.content.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () {
                        _textController.clear();
                        controller.deleteNoteForSelectedDate();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Clear note'),
                    ),
                ],
              ),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
