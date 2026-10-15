import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:post_reader_favorites/services/post_service.dart';

void main() {
  final service = PostService();

  test('fetchPosts returns posts on status 200', () async {
    final posts = await http.runWithClient(
      () => service.fetchPosts(),
      () => MockClient((request) async => http.Response(
            jsonEncode([
              {'userId': 1, 'id': 1, 'title': 'hello', 'body': 'world'},
              {'id': 'broken'}, // invalid item is skipped
            ]),
            200,
          )),
    );
    expect(posts.length, 1);
    expect(posts.first.title, 'hello');
  });

  test('fetchPosts throws PostException on non-200', () async {
    expect(
      http.runWithClient(
        () => service.fetchPosts(),
        () => MockClient((request) async => http.Response('nope', 500)),
      ),
      throwsA(isA<PostException>()),
    );
  });

  test('fetchPosts throws PostException on network failure', () async {
    expect(
      http.runWithClient(
        () => service.fetchPosts(),
        () => MockClient((request) async => throw http.ClientException('down')),
      ),
      throwsA(isA<PostException>()),
    );
  });

  test('fetchPosts throws PostException on malformed JSON', () async {
    expect(
      http.runWithClient(
        () => service.fetchPosts(),
        () => MockClient((request) async => http.Response('not json', 200)),
      ),
      throwsA(isA<PostException>()),
    );
  });

  test('createPost succeeds on status 201 and sends JSON', () async {
    late http.Request sent;
    await http.runWithClient(
      () => service.createPost(title: 'T', body: 'B'),
      () => MockClient((request) async {
        sent = request;
        return http.Response('{"id": 101}', 201);
      }),
    );
    expect(sent.method, 'POST');
    expect(jsonDecode(sent.body)['title'], 'T');
  });

  test('createPost throws PostException when status is not 201', () async {
    expect(
      http.runWithClient(
        () => service.createPost(title: 'T', body: 'B'),
        () => MockClient((request) async => http.Response('bad', 400)),
      ),
      throwsA(isA<PostException>()),
    );
  });
}
