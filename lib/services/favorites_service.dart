import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post.dart';

/// All Hive (local database) work lives here.
/// Each favorite is a plain Map stored with the post id as the key:
/// {id, title, body, note}
class FavoritesService {
  static const String boxName = 'favoritesBox';

  static Box<dynamic> get _box => Hive.box(boxName);

  /// Lets screens rebuild automatically whenever the box changes.
  static ValueListenable<Box<dynamic>> get listenable => _box.listenable();

  static bool isSaved(int id) => _box.containsKey(id);

  /// CREATE. Returns false (and saves nothing) if the post is already saved.
  static Future<bool> save(Post post) async {
    if (_box.containsKey(post.id)) return false;
    await _box.put(post.id, {...post.toMap(), 'note': ''});
    return true;
  }

  /// READ. All saved favorites, ordered by post id.
  static List<Map<String, dynamic>> all() {
    final favorites = _box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
    favorites.sort((a, b) => (a['id'] as num).compareTo(b['id'] as num));
    return favorites;
  }

  /// UPDATE. Changes only the note; id, title and body stay untouched.
  static Future<void> updateNote(int id, String note) async {
    final existing = _box.get(id);
    if (existing is! Map) return;
    final updated = Map<String, dynamic>.from(existing);
    updated['note'] = note.trim();
    await _box.put(id, updated);
  }

  /// DELETE.
  static Future<void> delete(int id) => _box.delete(id);

  /// Puts a deleted favorite back (used by the "Undo" button).
  static Future<void> restore(Map<String, dynamic> favorite) =>
      _box.put(favorite['id'], favorite);
}
