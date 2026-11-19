import 'package:flutter/material.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Username'),
            subtitle: Text('@${user.username}'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(user.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Phone'),
            subtitle: Text('${user.phone} (digits: ${user.phoneDigits})'),
            onTap: () {}, // Заглушка для Practice 12
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Website'),
            subtitle: Text(user.website ?? 'Not provided'),
            onTap: () {}, // Заглушка для Practice 12
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Address'),
            subtitle: Text(
              '${user.address.street}, ${user.address.suite}\n'
                  '${user.address.city}, ${user.address.zipcode}\n'
                  'Geo: ${user.address.geo.lat}, ${user.address.geo.lng}',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Company'),
            subtitle: Text('${user.company.name}\n"${user.company.catchPhrase}"'),
          ),
        ],
      ),
    );
  }
}