import 'package:flutter/material.dart';
import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((b) => b.read).toList(),
  };

  Future<void> _openDetail(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(
        builder: (_) => DetailScreen(book: book),
      ),
    );

    if (!mounted) return;

    if (action == BookAction.toggleRead) {
      setState(() {
        book.read = !book.read;
      });
    } else if (action == BookAction.delete) {
      setState(() {
        _books.remove(book);
      });
    }
  }

  Future<void> _addBook() async {
    final newBook = await Navigator.of(context).push<Book>(
      MaterialPageRoute(
        builder: (_) => const AddBookScreen(),
      ),
    );

    if (!mounted || newBook == null) return;

    setState(() {
      _books.add(newBook);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reading list (${_visible.length})'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Stat Header Card
          Card(
            margin: const EdgeInsets.all(12.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${_books.length}',
                          style: textTheme.headlineSmall,
                        ),
                        Text('Books', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${totalPages(_books)}',
                          style: textTheme.headlineSmall,
                        ),
                        Text('Pages', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${unread(_books).length}',
                          style: textTheme.headlineSmall,
                        ),
                        Text('Unread', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ChoiceChips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                for (final f in Filter.values) ...[
                  ChoiceChip(
                    label: Text(f.name[0].toUpperCase() + f.name.substring(1)),
                    selected: _filter == f,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filter = f;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ListView
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _visible.length,
              itemBuilder: (context, index) {
                final book = _visible[index];
                return GestureDetector(
                  onTap: () => _openDetail(book),
                  child: BookTile(
                    book: book,
                    onToggle: () {
                      setState(() {
                        book.read = !book.read;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}