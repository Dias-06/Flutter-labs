import 'package:flutter/material.dart';

import 'models/event.dart';
import 'models/profile.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Event event;
  final Profile profile;
  final void Function(Event event) onChanged;
  final void Function(String id) onDelete;
  final VoidCallback onOpenProfile;
}

/// event == null means "create a new event".
class FormArgs {
  const FormArgs({this.event});

  final Event? event;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      final args = settings.arguments as DetailArgs;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => DetailScreen(args: args),
      );
    case Routes.form:
      final args = settings.arguments as FormArgs;
      return MaterialPageRoute<Event>(
        settings: settings,
        builder: (context) => FormScreen(args: args),
      );
    default:
      return null;
  }
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (context) => const Scaffold(
      body: Center(child: Text('Not found')),
    ),
  );
}
