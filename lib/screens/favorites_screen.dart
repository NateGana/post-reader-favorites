import 'package:flutter/material.dart';

import '../services/favorites_service.dart';
import '../widgets/edit_note_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/favorite_card.dart';
import '../widgets/theme_toggle_button.dart';

/// Route '/favorites': shows everything saved in the Hive box.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> _editNote(
    BuildContext context,
    Map<String, dynamic> favorite,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final newNote = await showDialog<String>(
      context: context,
      builder: (context) =>
          EditNoteDialog(initialNote: '${favorite['note'] ?? ''}'),
    );
    if (newNote == null) return; // cancelled

    try {
      await FavoritesService.updateNote(favorite['id'] as int, newNote);
      messenger.showSnackBar(const SnackBar(content: Text('Note updated.')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not update the note.')),
      );
    }
  }

  /// Asks for confirmation, then deletes. Returns true if it was deleted.
  Future<bool> _confirmAndDelete(
    BuildContext context,
    Map<String, dynamic> favorite,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove favorite?'),
        content: const Text(
          'This post and your note will be removed from your favorites.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      await FavoritesService.delete(favorite['id'] as int);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Removed from favorites.'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () => FavoritesService.restore(favorite),
            ),
          ),
        );
      return true;
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not remove this favorite.')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: const [ThemeToggleButton(), SizedBox(width: 4)],
      ),
      // Rebuilds whenever the Hive box changes (save, edit, delete).
      body: ValueListenableBuilder(
        valueListenable: FavoritesService.listenable,
        builder: (context, box, child) {
          final favorites = FavoritesService.all();

          if (favorites.isEmpty) {
            return EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No favorites yet',
              message: 'Open any post and tap "Save to Favorites". '
                  'It will show up here, even after you close the app.',
              actionLabel: 'Browse posts',
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey(favorite['id']),
                  direction: DismissDirection.endToStart,
                  // Swipe left to delete (asks first).
                  confirmDismiss: (_) async {
                    await _confirmAndDelete(context, favorite);
                    return false; // the list rebuilds itself from Hive
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                  child: FavoriteCard(
                    favorite: favorite,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/details',
                      arguments: {
                        'id': favorite['id'],
                        'title': favorite['title'],
                        'body': favorite['body'],
                      },
                    ),
                    onEditNote: () => _editNote(context, favorite),
                    onDelete: () => _confirmAndDelete(context, favorite),
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
