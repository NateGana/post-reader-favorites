import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/favorites_service.dart';
import '../services/post_service.dart';
import '../theme/app_theme.dart';
import '../widgets/add_post_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/post_card.dart';
import '../widgets/theme_toggle_button.dart';

/// Route '/': the feed of posts loaded from the internet.
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final PostService _service = PostService();

  List<Post> _posts = []; // posts from the API
  final List<Post> _addedPosts = []; // posts created in this session
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts(); // async method called from initState
  }

  /// GET request. Never leaves the screen stuck on the spinner.
  Future<void> _loadPosts() async {
    try {
      final posts = await _service.fetchPosts();
      if (!mounted) return; // screen was closed while waiting
      setState(() {
        _posts = posts;
        _error = null;
        _loading = false;
      });
    } on PostException catch (e) {
      _handleLoadError(e.message);
    } catch (_) {
      _handleLoadError('Something went wrong. Please try again.');
    }
  }

  void _handleLoadError(String message) {
    if (!mounted) return;
    final hadPosts = _posts.isNotEmpty;
    setState(() {
      _loading = false;
      if (!hadPosts) _error = message;
    });
    // Pull-to-refresh failed but old posts are still visible: use a snackbar.
    if (hadPosts) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _loadPosts();
  }

  Future<void> _openAddPostDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddPostDialog(service: _service),
    );
    if (result == null || !mounted) return;

    // JSONPlaceholder only SIMULATES saving, so we add the post to our own
    // list so the user can see it for this session.
    final allIds = [..._posts, ..._addedPosts].map((p) => p.id);
    final nextId = allIds.isEmpty ? 101 : allIds.reduce(math.max) + 1;
    setState(() {
      _addedPosts.insert(
        0,
        Post(id: nextId, title: result['title']!, body: result['body']!),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 6),
        content: Text(
          'Success! The server replied 201 (Created). JSONPlaceholder only '
          'simulates saving, so the post is shown here for this session only.',
        ),
      ),
    );
  }

  void _openDetails(Post post) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: {'id': post.id, 'title': post.title, 'body': post.body},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Reader'),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.bookmarks_rounded),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPostDialog,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('New post'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading posts…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _retry);

    final posts = [..._addedPosts, ..._posts];
    if (posts.isEmpty) {
      return EmptyState(
        icon: Icons.article_outlined,
        title: 'No posts yet',
        message: 'There is nothing to read right now. Pull down or tap below '
            'to refresh.',
        actionLabel: 'Refresh',
        onAction: _retry,
      );
    }

    // Centered with a maximum width so it looks good on wide screens too.
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: RefreshIndicator(
          onRefresh: _loadPosts,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _HeroHeader(
                  count: posts.length,
                  onOpenFavorites: () =>
                      Navigator.pushNamed(context, '/favorites'),
                );
              }
              final post = posts[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PostCard(
                  post: post,
                  isNew: _addedPosts.contains(post),
                  onTap: () => _openDetails(post),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Headline card at the top of the feed.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.count, required this.onOpenFavorites});

  final int count;
  final VoidCallback onOpenFavorites;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = AppColors.isDark(context);
    final gradient = dark
        ? const [Color(0xFF0F766E), Color(0xFF134E4A)]
        : const [Color(0xFF00897B), Color(0xFF004D40)];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(dark ? 90 : 45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Soft decorative circles.
            Positioned(
              right: -30,
              top: -30,
              child: _circle(150, 22),
            ),
            Positioned(
              right: 50,
              bottom: -60,
              child: _circle(120, 16),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_stories_rounded,
                          size: 18, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        'POST READER',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Discover Posts',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$count posts to explore. Tap one to read it, then save '
                    'your favorites.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withAlpha(225),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Live number of favorites saved in Hive.
                      ValueListenableBuilder(
                        valueListenable: FavoritesService.listenable,
                        builder: (context, box, child) => _InfoChip(
                          icon: Icons.bookmark_rounded,
                          label: '${FavoritesService.all().length} saved',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: onOpenFavorites,
                        icon: const Icon(Icons.bookmarks_outlined, size: 18),
                        label: const Text('My favorites'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _circle(double size, int alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(alpha),
        ),
      );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
