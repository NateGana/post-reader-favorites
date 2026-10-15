import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';
import '../widgets/theme_toggle_button.dart';

/// Route '/details': reads one post and lets the user save it.
class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Arguments sent by Navigator.pushNamed on the Posts screen.
    final args = ModalRoute.of(context)!.settings.arguments;

    Post? post;
    if (args is Map) {
      try {
        post = Post.fromMap(args);
      } on FormatException {
        post = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        actions: const [ThemeToggleButton(), SizedBox(width: 4)],
      ),
      body: post == null
          ? ErrorView(
              message: 'We could not open this post. Please go back and '
                  'choose it again.',
              onRetry: () => Navigator.pop(context),
              buttonLabel: 'Go back',
              buttonIcon: Icons.arrow_back_rounded,
            )
          : _PostDetailsBody(post: post),
    );
  }
}

class _PostDetailsBody extends StatelessWidget {
  const _PostDetailsBody({required this.post});

  final Post post;

  Future<void> _save(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final added = await FavoritesService.save(post);
      messenger.showSnackBar(
        SnackBar(
          content: Text(added
              ? 'Saved to your favorites.'
              : 'This post is already in your favorites.'),
          action: added
              ? SnackBarAction(
                  label: 'VIEW',
                  onPressed: () => Navigator.pushNamed(context, '/favorites'),
                )
              : null,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save this post. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'POST #${post.id}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(post.displayTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 18),
              Divider(color: AppColors.border(context)),
              const SizedBox(height: 14),
              Text(post.displayBody, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
        // Rebuilds automatically when the favorite is saved or removed.
        ValueListenableBuilder(
          valueListenable: FavoritesService.listenable,
          builder: (context, box, child) {
            final saved = FavoritesService.isSaved(post.id);
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                border: Border(
                  top: BorderSide(color: AppColors.border(context)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: saved
                    ? FilledButton.tonalIcon(
                        onPressed: () => _save(context),
                        icon: const Icon(Icons.bookmark_added_rounded),
                        label: const Text('Saved to Favorites'),
                      )
                    : FilledButton.icon(
                        onPressed: () => _save(context),
                        icon: const Icon(Icons.bookmark_add_rounded),
                        label: const Text('Save to Favorites'),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
