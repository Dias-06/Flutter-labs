import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final selectedCity = context.watch<SettingsModel>().city;

    final filteredItems = selectedCity == null
        ? m.items
        : m.items.where((u) => u.address.city == selectedCity).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCity == null ? 'Users' : 'Users ($selectedCity)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          unawaited(
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (m.fromCache)
            Material(
              color: Colors.amber.shade200,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Saved data · no connection',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: m.load,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (m.loading && m.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return switch (m.error) {
                  null => _UserList(items: filteredItems, onRefresh: m.load),
                  NoConnectionException() => _ErrorView(
                    icon: Icons.wifi_off,
                    message:
                    'No internet connection.\nCheck your network and try again.',
                    onRetry: m.load,
                  ),
                  NotFoundException() || UnauthorizedException() => _ErrorView(
                    icon: Icons.lock_outline,
                    message: 'Access denied or resource not found.',
                    onRetry: m.load,
                  ),
                  ServerException(:final status) => _ErrorView(
                    icon: Icons.cloud_off,
                    message: 'Server error ($status). Please try later.',
                    onRetry: m.load,
                  ),
                  BadResponseException() => const _ErrorView(
                    icon: Icons.bug_report,
                    message: 'Unexpected data format from server.',
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({required this.items, required this.onRefresh});

  final List<User> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = items[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text('${user.email} • ${user.address.city}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => UserDetailScreen(user: user),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}