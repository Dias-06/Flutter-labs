import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/format.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Event event;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  String? get _badge {
    if (event.isFull) return 'FULL';
    if (event.freePlaces <= 5) return '${event.freePlaces} left';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final badge = _badge;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.surfaceContainerHighest,
                    child: Icon(
                      event.category.icon,
                      color: event.category.color(scheme),
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: scheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onError,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(formatDateTime(event.starts)),
                    Text(
                      event.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavourite,
                icon: Icon(
                  event.isFavourite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}