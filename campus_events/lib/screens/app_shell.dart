import 'package:flutter/material.dart';

import '../../data/seed_events.dart';
import '../../models/event.dart';
import '../../models/profile.dart';
import '../../routes.dart';
import './events_tab.dart';
import './favourites_tab.dart';
import 'profile_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final void Function(ThemeMode mode) onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  List<Event> _events = buildSeedEvents();
  Profile _profile = const Profile.empty();
  int _tabIndex = 0;

  void _toggleFavourite(String id) {
    setState(() {
      _events = [
        for (final e in _events)
          e.id == id ? e.copyWith(isFavourite: !e.isFavourite) : e,
      ];
    });
  }

  void _updateEvent(Event updated) {
    setState(() {
      _events = [
        for (final e in _events) e.id == updated.id ? updated : e,
      ];
    });
  }

  void _deleteEvent(String id) {
    setState(() {
      _events = _events.where((e) => e.id != id).toList();
    });
  }

  void _updateProfile(Profile profile) {
    setState(() => _profile = profile);
  }

  void _goToProfileTab() {
    setState(() => _tabIndex = 2);
  }

  void _openDetail(Event event) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        event: event,
        profile: _profile,
        onChanged: _updateEvent,
        onDelete: _deleteEvent,
        onOpenProfile: _goToProfileTab,
      ),
    );
  }

  Future<void> _createEvent() async {
    final created = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    setState(() => _events = [..._events, created]);
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Campus Events: browse events, register and add your own.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data'),
        content: const Text('Restore the original events and clear the profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _events = buildSeedEvents();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Events')),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Campus Events',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAbout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmReset();
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          EventsTab(
            events: _events,
            onToggleFavourite: _toggleFavourite,
            onOpen: _openDetail,
          ),
          FavouritesTab(
            events: _events,
            onToggleFavourite: _toggleFavourite,
            onOpen: _openDetail,
          ),
          ProfileTab(
            profile: _profile,
            events: _events,
            onProfileChanged: _updateProfile,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
              onPressed: _createEvent,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) {
          setState(() => _tabIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favourites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
