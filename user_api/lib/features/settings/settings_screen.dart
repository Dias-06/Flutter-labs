import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _picker = ImagePicker();

  Future<void> _savePickedFile(XFile? picked) async {
    if (picked == null) return;
    final docsDir = await getApplicationDocumentsDirectory();
    final targetPath = '${docsDir.path}/avatar.jpg';
    await File(picked.path).copy(targetPath);
    if (!mounted) return;
    context.read<SettingsModel>().setAvatarPath(targetPath);
  }

  Future<void> _chooseFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    await _savePickedFile(picked);
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          imageQuality: 85,
        );
        await _savePickedFile(picked);

      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
            Text('Camera permission is needed to take a profile photo.'),
          ),
        );

      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Camera access disabled'),
            content: const Text(
              'Camera permission was permanently denied. Enable it in system settings to take a photo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await openAppSettings();
                },
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>().items;
    final cities = users.map((u) => u.address.city).toSet().toList()..sort();

    final avatarFile =
    settings.avatarPath != null ? File(settings.avatarPath!) : null;
    final hasAvatar = avatarFile != null && avatarFile.existsSync();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: hasAvatar ? FileImage(avatarFile) : null,
              child: hasAvatar ? null : const Icon(Icons.person, size: 48),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _chooseFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose photo'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take photo'),
              ),
            ],
          ),
          const Divider(height: 32),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.dark,
            onChanged: settings.setDark,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            value: cities.contains(settings.city) ? settings.city : null,
            decoration: const InputDecoration(
              labelText: 'Filter by City',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All cities'),
              ),
              ...cities.map(
                    (c) => DropdownMenuItem<String?>(value: c, child: Text(c)),
              ),
            ],
            onChanged: settings.setCity,
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await context.read<AuthModel>().logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
}