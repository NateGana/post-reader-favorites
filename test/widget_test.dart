import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:post_reader_favorites/main.dart';
import 'package:post_reader_favorites/services/favorites_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_widget_test');
    Hive.init(tempDir.path);
    await Hive.openBox(FavoritesService.boxName);
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  MockClient okClient() => MockClient((request) async => http.Response(
        jsonEncode([
          {'userId': 1, 'id': 1, 'title': 'first title', 'body': 'first body'},
          {
            'userId': 1,
            'id': 2,
            'title': 'second title',
            'body': 'second body'
          },
        ]),
        200,
      ));

  testWidgets('shows posts, then opens details with the right data',
      (tester) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(const PostReaderApp());
      await tester.pumpAndSettle();

      expect(find.text('First title'), findsOneWidget);

      await tester.tap(find.text('First title'));
      await tester.pumpAndSettle();

      expect(find.text('Post Details'), findsOneWidget);
      expect(find.text('POST #1'), findsOneWidget);
      expect(find.text('First body'), findsOneWidget);
      expect(find.text('Save to Favorites'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discover Posts'), findsOneWidget);
    }, okClient);
  });

  testWidgets('Favorites button opens the empty Favorites screen',
      (tester) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(const PostReaderApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Favorites'));
      await tester.pumpAndSettle();

      expect(find.text('No favorites yet'), findsOneWidget);
    }, okClient);
  });

  testWidgets('shows an error message and a retry button on failure',
      (tester) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(const PostReaderApp());
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    }, () => MockClient((request) async => http.Response('error', 500)));
  });

  testWidgets('empty title and body are rejected in the New post dialog',
      (tester) async {
    await http.runWithClient(() async {
      await tester.pumpWidget(const PostReaderApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('New post'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a title.'), findsOneWidget);
      expect(find.text('Please write something in the body.'), findsOneWidget);
    }, okClient);
  });
}
