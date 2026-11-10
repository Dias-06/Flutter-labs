import 'package:flutter/material.dart';
import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final pages = int.parse(_pagesController.text);
      final yearText = _yearController.text.trim();
      final year = yearText.isEmpty ? null : int.tryParse(yearText);

      final newBook = Book(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        pages: pages,
        year: year,
      );

      Navigator.of(context).pop(newBook);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  final val = (v ?? '').trim();
                  if (val.length < 2) {
                    return 'Title is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  final val = (v ?? '').trim();
                  if (val.isEmpty) {
                    return 'Author is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pagesController,
                decoration: const InputDecoration(labelText: 'Pages'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) {
                    return 'A whole number above 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year (optional)',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  final val = (v ?? '').trim();
                  if (val.isEmpty) return null;
                  final n = int.tryParse(val);
                  final currentYear = DateTime.now().year;
                  if (n == null || n < 1450 || n > currentYear) {
                    return 'Enter a year between 1450 and $currentYear';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}