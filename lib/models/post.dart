/// A single post from JSONPlaceholder.
class Post {
  const Post({required this.id, required this.title, required this.body});

  final int id;
  final String title;
  final String body;

  /// Builds a Post from a Map (JSON from the API, route arguments, or Hive).
  /// Throws [FormatException] if the data is missing or the wrong type.
  factory Post.fromMap(Map<dynamic, dynamic> map) {
    final id = map['id'];
    final title = map['title'];
    final body = map['body'];
    if (id is! int || title is! String || body is! String) {
      throw const FormatException('Invalid post data');
    }
    return Post(id: id, title: title.trim(), body: body.trim());
  }

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'body': body};

  /// Title with a capital first letter (the API gives lowercase text).
  String get displayTitle => capitalize(title);

  /// Body with a capital first letter.
  String get displayBody => capitalize(body);

  /// Body on a single line, used for short previews in lists.
  String get preview => displayBody.replaceAll('\n', ' ');

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
