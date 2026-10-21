import 'package:flutter/material.dart';

import '../../models/event.dart';
import '../../models/event_category.dart';
import '../../routes.dart';
import '../../utils/format.dart';

typedef _Snapshot = ({
  String title,
  String place,
  String capacity,
  String description,
  EventCategory? category,
  bool online,
  DateTime date,
  TimeOfDay time,
});

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  // A new event starts from Event.empty(); an edited one from its own values.
  late final Event _base = widget.args.event ?? Event.empty();
  bool get _isEditing => widget.args.event != null;

  late final _titleController = TextEditingController(text: _base.title);
  late final _placeController = TextEditingController(text: _base.place);
  late final _capacityController =
      TextEditingController(text: _base.capacity.toString());
  late final _descriptionController =
      TextEditingController(text: _base.description ?? '');
  late final _dateController =
      TextEditingController(text: formatDate(_base.starts));
  late final _timeController =
      TextEditingController(text: formatTime(_base.starts));

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  late DateTime _date =
      DateTime(_base.starts.year, _base.starts.month, _base.starts.day);
  late TimeOfDay _time = TimeOfDay.fromDateTime(_base.starts);
  late EventCategory? _category = _base.category;
  late bool _isOnline = _base.isOnline;
  bool _saving = false;

  late final _Snapshot _initial = _snapshot();

  _Snapshot _snapshot() => (
        title: _titleController.text,
        place: _placeController.text,
        capacity: _capacityController.text,
        description: _descriptionController.text,
        category: _category,
        online: _isOnline,
        date: _date,
        time: _time,
      );

  bool get _dirty => _snapshot() != _initial;

  DateTime _combined() =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _capacityFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 3) return 'At least 3 characters';
    if (text.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validatePlace(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return _isOnline ? 'Link is required' : 'Place is required';
    if (_isOnline && !text.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateCapacity(String? value) {
    final number = int.tryParse((value ?? '').trim());
    if (number == null) return 'Enter a whole number';
    if (number < 1 || number > 500) return 'Between 1 and 500';
    final existing = widget.args.event;
    if (existing != null && number < existing.count) {
      return 'Not below the current ${existing.count} registered';
    }
    return null;
  }

  String? _validateCategory(EventCategory? value) {
    return value == null ? 'Choose a category' : null;
  }

  String? _validateDate(String? value) {
    if ((value ?? '').isEmpty) return 'Date is required';
    if (!_isEditing) {
      final now = DateTime.now();
      if (_date.isBefore(DateTime(now.year, now.month, now.day))) {
        return 'Date must not be in the past';
      }
    }
    return null;
  }

  String? _validateTime(String? value) {
    if ((value ?? '').isEmpty) return 'Time is required';
    if (!_isEditing && !_combined().isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateController.text = formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeController.text = formatTime(_combined());
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    setState(() => _saving = true);
    // Pretend to talk to a server for one second.
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final old = widget.args.event;
    final description = _descriptionController.text.trim();
    final event = Event(
      id: old?.id ?? 'e${DateTime.now().microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      category: _category ?? _base.category,
      starts: _combined(),
      place: _placeController.text.trim(),
      capacity: int.parse(_capacityController.text.trim()),
      isOnline: _isOnline,
      description: description.isEmpty ? null : description,
      isFavourite: old?.isFavourite ?? false,
      attendees: old?.attendees ?? const [],
    );
    Navigator.pop(context, event);
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
    Navigator.pop(context);
  }

  void _dismissKeyboard(Object? event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Edit event' : 'New event')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: () => setState(() {}),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: _validateTitle,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<EventCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final c in EventCategory.values)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon),
                            const SizedBox(width: 8),
                            Text(c.label),
                          ],
                        ),
                      ),
                  ],
                  validator: _validateCategory,
                  onChanged: (value) => setState(() => _category = value),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online event'),
                  value: _isOnline,
                  onChanged: (value) =>
                      setState(() => _isOnline = value ?? false),
                ),
                TextFormField(
                  controller: _placeController,
                  focusNode: _placeFocus,
                  decoration: InputDecoration(
                    labelText: _isOnline ? 'Link' : 'Place',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType:
                      _isOnline ? TextInputType.url : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: _validatePlace,
                  onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacityController,
                  focusNode: _capacityFocus,
                  decoration: const InputDecoration(
                    labelText: 'Capacity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: _validateCapacity,
                  onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: _validateDate,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.schedule),
                        ),
                        validator: _validateTime,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocus,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _descriptionFocus.unfocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
