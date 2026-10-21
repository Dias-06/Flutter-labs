import 'package:flutter/material.dart';

import '../../models/event.dart';
import '../../models/profile.dart';

final _groupPattern = RegExp(r'^[A-Z]{2,5}-\d{2,3}$');

String _modeLabel(ThemeMode mode) => switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.onProfileChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Event> events;
  final void Function(Profile profile) onProfileChanged;
  final ThemeMode themeMode;
  final void Function(ThemeMode mode) onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _groupController =
      TextEditingController(text: widget.profile.group);
  final _groupFocus = FocusNode();

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The profile can change from outside (Reset data): keep fields in sync.
    if (_nameController.text != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }
    if (_groupController.text != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = (value ?? '').trim();
    if (text.isNotEmpty && text.length < 2) return 'At least 2 characters';
    return null;
  }

  String? _validateGroup(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return _groupPattern.hasMatch(text) ? null : 'Use a format like CS-21';
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    widget.onProfileChanged(
      widget.profile.copyWith(
        name: _nameController.text.trim(),
        group: _groupController.text.trim(),
      ),
    );
  }

  void _dismissKeyboard(Object? event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final myName = widget.profile.name;
    final lists =
        myName.isEmpty ? 0 : widget.events.where((e) => e.contains(myName)).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: _validateName,
                onFieldSubmitted: (_) {
                  _save();
                  _groupFocus.requestFocus();
                },
                onTapOutside: _dismissKeyboard,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupController,
                focusNode: _groupFocus,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'CS-21',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                validator: _validateGroup,
                onFieldSubmitted: (_) => _save(),
                onTapOutside: _dismissKeyboard,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Text('Theme', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(_modeLabel(mode)),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeModeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}
