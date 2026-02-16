import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../services/file_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _controller = TextEditingController();
  late final FileService _fileService;
  DateTime _selectedDate = DateTime.now();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _fileService = FileService(ImagePicker());
    _loadCurrentEntry();
  }

  void _loadCurrentEntry() {
    final entry = context.read<AppState>().journalForDate(_selectedDate);
    _controller.text = entry?.content ?? '';
    _imagePath = entry?.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Journal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Entry date'),
            subtitle: Text(_selectedDate.toString().split(' ').first),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          TextField(
            controller: _controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Write your thoughts for today…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
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
              child: Image.file(File(_imagePath!), height: 180, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Save Entry')),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;
    setState(() {
      _selectedDate = date;
      _loadCurrentEntry();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final path = await _fileService.pickAndCompressImage(source);
    if (path == null) return;
    setState(() => _imagePath = path);
  }

  Future<void> _save() async {
    await context.read<AppState>().saveJournal(
          date: _selectedDate,
          content: _controller.text.trim(),
          imagePath: _imagePath,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }
}
