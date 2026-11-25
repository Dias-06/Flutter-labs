import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/storage/secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  Future<void> _openUri(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No app can open this')),
      );
    }
  }

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
            onTap: () => _openUri(
              context,
              Uri(scheme: 'mailto', path: user.email),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Phone'),
            subtitle: Text('${user.phone} (digits: ${user.phoneDigits})'),
            onTap: () => _openUri(
              context,
              Uri(scheme: 'tel', path: user.phoneDigits),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Website'),
            subtitle: Text(user.website ?? 'Not provided'),
            onTap: user.website == null
                ? null
                : () => _openUri(
              context,
              Uri.parse('https://${user.website}'),
            ),
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
          if (kDebugMode) ...[
            const Divider(),
            OutlinedButton.icon(
              onPressed: () async {
                final token = await context.read<SecureStore>().readToken();
                if (token != null) {
                  await Clipboard.setData(ClipboardData(text: token));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Token copied to clipboard'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.key),
              label: const Text('Copy token to clipboard'),
            ),
          ],
        ],
      ),
    );
  }
}