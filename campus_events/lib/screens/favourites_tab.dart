import 'package:flutter/material.dart';

import '../models/event.dart';
import '../widgets/empty_state.dart';
import '../widgets/events_list.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.onToggleFavourite,
    required this.onOpen,
  });

  final List<Event> events;
  final void Function(String id) onToggleFavourite;
  final void Function(Event event) onOpen;

  @override
  Widget build(BuildContext context) {
    final favourites = events.where((e) => e.isFavourite).toList();
    if (favourites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
      );
    }
    return EventList(
      events: favourites,
      onToggleFavourite: onToggleFavourite,
      onOpen: onOpen,
    );
  }
}