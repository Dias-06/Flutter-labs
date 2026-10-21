import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/event_category.dart';
import '../widgets/empty_state.dart';
import '../widgets/events_list.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.events,
    required this.onToggleFavourite,
    required this.onOpen,
  });

  final List<Event> events;
  final void Function(String id) onToggleFavourite;
  final void Function(Event event) onOpen;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final _searchController = TextEditingController();
  String _query = '';
  EventCategory? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
      _showPast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.events
        .where((e) => e.title.toLowerCase().contains(_query.toLowerCase()))
        .where((e) => _category == null || e.category == _category)
        .where((e) => _showPast || !e.isPast)
        .toList();

    visible.sort((a, b) {
      if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
      return a.starts.compareTo(b.starts);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: const Icon(Icons.clear),
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final c in EventCategory.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(c.icon),
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                ),
              ],
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
            icon: Icons.search_off,
            message: 'No events match your filters',
            buttonLabel: 'Reset filters',
            onPressed: _resetFilters,
          )
              : EventList(
            events: visible,
            onToggleFavourite: widget.onToggleFavourite,
            onOpen: widget.onOpen,
          ),
        ),
      ],
    );
  }
}