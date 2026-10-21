import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/count_down.dart';
import '../../models/event.dart';
import '../../routes.dart';
import '../../utils/format.dart';
import '../../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Event _event = widget.args.event;
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _apply(Event updated) {
    widget.args.onChanged(updated);
    setState(() => _event = updated);
  }

  void _showNameMissing() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Enter your name in the profile first'),
        action: SnackBarAction(
          label: 'Profile',
          onPressed: () {
            widget.args.onOpenProfile();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _onPrimaryPressed() async {
    final name = widget.args.profile.name;
    if (name.isEmpty) {
      _showNameMissing();
      return;
    }
    if (_event.contains(name)) {
      _apply(
        _event.copyWith(
          attendees: _event.attendees.where((n) => n != name).toList(),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register'),
        content: Text('Register for "${_event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Register'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _apply(_event.copyWith(attendees: [..._event.attendees, name]));
  }

  Future<void> _edit() async {
    final updated = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: FormArgs(event: _event),
    );
    if (updated == null || !mounted) return;
    _apply(updated);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event'),
        content: Text('Delete "${_event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.args.onDelete(_event.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final countdown = Countdown.of(_event.starts, _now);
    final name = widget.args.profile.name;
    final registered = _event.contains(name);
    final VoidCallback? onPressed =
        (!registered && _event.isFull) ? null : _onPrimaryPressed;
    final label = registered
        ? 'Cancel registration'
        : (_event.isFull ? 'Full' : 'Register');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event details'),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (action) {
                switch (action) {
                  case _MenuAction.edit:
                    _edit();
                  case _MenuAction.delete:
                    _confirmDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset('assets/header.png', fit: BoxFit.cover),
                  ),
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: scheme.surface,
                      child: Icon(
                        _event.category.icon,
                        size: 40,
                        color: _event.category.color(scheme),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Label(text: _event.category.label),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _Label(text: countdownText(countdown)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _event.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_event.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(event: _event),
                  _NamesTab(event: _event, myName: name),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onPressed, child: Text(label)),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = event.places;
    final description = event.description;

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(formatDateTime(event.starts)),
        ),
        ListTile(
          leading: Icon(event.isOnline ? Icons.link : Icons.place),
          title: Text(event.place),
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: Text('$taken taken, $free free of ${event.capacity}'),
        ),
        if (description != null)
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(description),
          ),
      ],
    );
  }
}

class _NamesTab extends StatelessWidget {
  const _NamesTab({required this.event, required this.myName});

  final Event event;
  final String myName;

  @override
  Widget build(BuildContext context) {
    if (event.attendees.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Nobody has registered yet',
      );
    }
    return ListView(
      children: [
        for (final name in event.attendees)
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(name == myName ? '$name (You)' : name),
            selected: name == myName,
          ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: scheme.onPrimaryContainer),
      ),
    );
  }
}
