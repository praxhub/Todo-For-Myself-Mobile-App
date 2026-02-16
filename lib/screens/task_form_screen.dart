import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../app_state.dart';
import '../models/task.dart';
import '../services/file_service.dart';
import '../services/voice_note_service.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _audioPlayer = AudioPlayer();

  late final FileService _fileService;
  late final VoiceNoteService _voiceService;

  DateTime _dueDate = DateTime.now();
  String? _imagePath;
  String? _voicePath;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _fileService = FileService(ImagePicker());
    _voiceService = VoiceNoteService(AudioRecorder());

    final task = widget.taskId == null ? null : context.read<AppState>().getTask(widget.taskId!);
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _dueDate = task.dueDate;
      _imagePath = task.imagePath;
      _voicePath = task.voiceNotePath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioPlayer.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.taskId == null ? 'Create Task' : 'Edit Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due date'),
              subtitle: Text(_dueDate.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDueDate,
            ),
            const Divider(),
            const Text('Image attachment', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            if (_imagePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_imagePath!), height: 180, fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 16),
            const Text('Voice note', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Max duration: ${VoiceNoteService.maxDuration.inMinutes} minutes'),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _isRecording ? null : _startRecording,
                  icon: const Icon(Icons.mic),
                  label: const Text('Record'),
                ),
                FilledButton.icon(
                  onPressed: _isRecording ? _stopRecording : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
                FilledButton.icon(
                  onPressed: _voicePath == null ? null : _playVoice,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
                FilledButton.icon(
                  onPressed: _voicePath == null ? null : _deleteVoice,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(widget.taskId == null ? 'Create Task' : 'Save Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dueDate));
    if (time == null) return;

    setState(() {
      _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final path = await _fileService.pickAndCompressImage(source);
    if (path == null) return;
    setState(() => _imagePath = path);
  }

  Future<void> _startRecording() async {
    await _voiceService.startRecording();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final path = await _voiceService.stopRecording();
    if (path != null) {
      setState(() => _voicePath = path);
    }
    setState(() => _isRecording = false);
  }

  Future<void> _playVoice() async {
    if (_voicePath == null) return;
    await _audioPlayer.setFilePath(_voicePath!);
    await _audioPlayer.play();
  }

  Future<void> _deleteVoice() async {
    if (_voicePath == null) return;
    final file = File(_voicePath!);
    if (file.existsSync()) {
      await file.delete();
    }
    setState(() => _voicePath = null);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<AppState>();
    final task = Task(
      id: widget.taskId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      imagePath: _imagePath,
      voiceNotePath: _voicePath,
    );

    if (widget.taskId == null) {
      await state.addTask(task);
    } else {
      await state.updateTask(task);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }
}
