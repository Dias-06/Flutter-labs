import 'package:flutter/material.dart';
import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  final Book book;

  const DetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final yearText = book.year != null ? '${book.year}' : 'Year unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Author: ${book.author}', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Pages: ${book.pages}', style: textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text('Year: $yearText', style: textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(
              'Status: ${book.read ? "Read" : "Unread"}',
              style: textTheme.bodyLarge,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(BookAction.toggleRead);
                    },
                    child: Text(
                      book.read ? 'Mark as unread' : 'Mark as read',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Delete "${book.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (!context.mounted) return;
                      if (confirm == true) {
                        Navigator.of(context).pop(BookAction.delete);
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}