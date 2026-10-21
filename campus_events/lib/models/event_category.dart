import 'package:flutter/material.dart';

enum EventCategory {
  tech('Tech', Icons.computer),
  sport('Sport', Icons.sports_soccer),
  music('Music', Icons.music_note),
  study('Study', Icons.menu_book),
  social('Social', Icons.groups);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primary,
    EventCategory.sport => scheme.secondary,
    EventCategory.music => scheme.tertiary,
    EventCategory.study => scheme.error,
    EventCategory.social => scheme.outline,
  };
}