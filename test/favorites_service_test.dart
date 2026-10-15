import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:post_reader_favorites/models/post.dart';
import 'package:post_reader_favorites/services/favorites_service.dart';

void main() {
  late Directory tempDir;
  const post = Post(id: 7, title: 'a title', body: 'a body');

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox(FavoritesService.boxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('CREATE: saves a post with an empty note', () async {
    expect(await FavoritesService.save(post), isTrue);
    final saved = FavoritesService.all().single;
    expect(saved['id'], 7);
    expect(saved['note'], '');
  });

  test('CREATE: saving the same post twice does not duplicate it', () async {
    await FavoritesService.save(post);
    expect(await FavoritesService.save(post), isFalse);
    expect(FavoritesService.all().length, 1);
  });

  test('UPDATE: editing the note keeps id, title and body', () async {
    await FavoritesService.save(post);
    await FavoritesService.updateNote(7, '  my note ');
    final saved = FavoritesService.all().single;
    expect(saved['note'], 'my note');
    expect(saved['id'], 7);
    expect(saved['title'], 'a title');
    expect(saved['body'], 'a body');
  });

  test('DELETE: removes the favorite', () async {
    await FavoritesService.save(post);
    await FavoritesService.delete(7);
    expect(FavoritesService.all(), isEmpty);
    expect(FavoritesService.isSaved(7), isFalse);
  });

  test('PERSISTENCE: data survives closing and reopening the box', () async {
    await FavoritesService.save(post);
    await FavoritesService.updateNote(7, 'keep me');
    await Hive.box(FavoritesService.boxName).close();
    await Hive.openBox(FavoritesService.boxName);
    expect(FavoritesService.all().single['note'], 'keep me');
  });
}
