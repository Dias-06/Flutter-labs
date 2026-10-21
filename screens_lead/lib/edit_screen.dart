import 'package:flutter/material.dart';
import 'students.dart'; // Импортируем наш файл со Student

class EditScreen extends StatefulWidget {
  final Student student; // Явно указываем тип Student

  const EditScreen({
    super.key,
    required this.student,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late String _name = widget.student.name;
  bool get _dirty => _name != widget.student.name;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Name'),
      ),
      body: PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;

          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard changes?'),
              content: const Text('You have unsaved changes.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Keep editing'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );

          if (shouldPop == true && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                onChanged: (v) => setState(() => _name = v),
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(_name);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}