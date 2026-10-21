import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/app_shell.dart';
import 'theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Events',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      routes: {
        Routes.home: (context) => AppShell(
              themeMode: _themeMode,
              onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
            ),
      },
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
    );
  }
}
