import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';

/// An error with a message that is safe to show to the user.
class PostException implements Exception {
  const PostException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Talks to the JSONPlaceholder REST API.
class PostService {
  static const String postsUrl = 'https://jsonplaceholder.typicode.com/posts';
  static const Duration _timeout = Duration(seconds: 15);

  /// GET /posts -> list of posts.
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(postsUrl)).timeout(_timeout);

      if (response.statusCode != 200) {
        throw PostException(
          'The server replied with an error (code ${response.statusCode}). '
          'Please try again.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const PostException('The server sent data we could not read.');
      }

      // Skip any broken items instead of crashing.
      final posts = <Post>[];
      for (final item in decoded) {
        if (item is Map) {
          try {
            posts.add(Post.fromMap(item));
          } on FormatException {
            continue;
          }
        }
      }
      if (decoded.isNotEmpty && posts.isEmpty) {
        throw const PostException('The server sent data we could not read.');
      }
      return posts;
    } on PostException {
      rethrow;
    } on TimeoutException {
      throw const PostException(
        'The request took too long. Check your internet connection and try again.',
      );
    } on FormatException {
      throw const PostException('The server sent data we could not read.');
    } catch (_) {
      throw const PostException(
        'Could not reach the server. Please check your internet connection.',
      );
    }
  }

  /// POST /posts. Succeeds only when the server answers 201 (Created).
  Future<void> createPost({required String title, required String body}) async {
    try {
      final response = await http
          .post(
            Uri.parse(postsUrl),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
          )
          .timeout(_timeout);

      if (response.statusCode != 201) {
        throw PostException(
          'The server did not accept the post (code ${response.statusCode}).',
        );
      }
    } on PostException {
      rethrow;
    } on TimeoutException {
      throw const PostException(
        'The request took too long. Check your internet connection and try again.',
      );
    } catch (_) {
      throw const PostException(
        'Could not send the post. Please check your internet connection.',
      );
    }
  }
}
