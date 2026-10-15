import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/favorites_screen.dart';
import 'screens/post_details_screen.dart';
import 'screens/posts_screen.dart';
import 'services/favorites_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // 1. Make sure Flutter is ready before we use plugins.
  WidgetsFlutterBinding.ensureInitialized();
  // 2. Start Hive (the local database).
  await Hive.initFlutter();
  // 3. Open the box that stores our favorites.
  await Hive.openBox(FavoritesService.boxName);
  // 4. Run the app.
  runApp(const PostReaderApp());
}

class PostReaderApp extends StatelessWidget {
  const PostReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds the whole app when the light/dark toggle is pressed.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Post Reader & Favorites',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          // The three required named routes.
          initialRoute: '/',
          routes: {
            '/': (context) => const PostsScreen(),
            '/details': (context) => const PostDetailsScreen(),
            '/favorites': (context) => const FavoritesScreen(),
          },
        );
      },
    );
  }
}
