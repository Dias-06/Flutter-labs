import 'package:campus_events/widgets/event_card.dart';
import 'package:flutter/material.dart';

import '../../models/event.dart';


const _gridBreakpoint = 600.0;
const _maxCellWidth = 360.0;
const _cellHeight = 140.0;
const _listPadding = EdgeInsets.fromLTRB(8, 8, 8, 88);

class EventList extends StatelessWidget {
  const EventList({
    super.key,
    required this.events,
    required this.onToggleFavourite,
    required this.onOpen,
  });

  final List<Event> events;
  final void Function(String id) onToggleFavourite;
  final void Function(Event event) onOpen;

  Widget _card(Event event) {
    return EventCard(
      event: event,
      onTap: () => onOpen(event),
      onToggleFavourite: () => onToggleFavourite(event.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _gridBreakpoint) {
          return GridView.builder(
            padding: _listPadding,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _maxCellWidth,
              mainAxisExtent: _cellHeight,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) => _card(events[index]),
          );
        }
        return ListView.separated(
          padding: _listPadding,
          itemCount: events.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: (context, index) => _card(events[index]),
        );
      },
    );
  }
}
