import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/post.dart';
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
        title: const Text('Discover Posts'),
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

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _Header(count: posts.length);
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
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
      child: Text(
        '$count posts to explore. Tap one to read it, then save your '
        'favorites.',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.muted(context)),
      ),
    );
  }
}
