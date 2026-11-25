import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  final avatarPath = await prefs.getString('avatarPath');

  const store = SecureStore();
  final initialToken = await store.readToken();

  final api = ApiClient(http.Client(), store);

  runApp(
    MultiProvider(
      providers: [
        Provider<SecureStore>.value(value: store),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(
            prefs,
            dark: dark,
            city: city,
            avatarPath: avatarPath,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthModel(store, initialToken: initialToken),
        ),
        ChangeNotifierProvider(
          create: (_) => UsersModel(UserRepository(api))..load(),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<SettingsModel>().dark;
    final signedIn = context.watch<AuthModel>().signedIn;

    return MaterialApp(
      title: 'Users API',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: signedIn ? const UsersScreen() : const LoginScreen(),
    );
  }
}