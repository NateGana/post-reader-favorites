# Post Reader & Favorites

A Flutter app for **ITP107 – Mobile Application Development (Finals Laboratory Examination)**, University of Cabuyao, Section 3 IT A.

It loads posts from the internet, lets you read them, create a new post, and save favorite posts (with a personal note) on your device.

## Features

- **Posts screen (`/`)** – loads posts with `http.get`, shows them in a `ListView.builder` of `ListTile`s, pull-to-refresh, loading / error (with Retry) / empty states.
- **Post Details screen (`/details`)** – receives `id`, `title`, `body` through `ModalRoute.of(context)!.settings.arguments`; **Save to Favorites** button.
- **Favorites screen (`/favorites`)** – lists saved posts from Hive, edit note, delete (icon with confirmation, or swipe left), Undo.
- **New post** – floating action button opens a dialog (title + body, both required) and sends `http.post` with `jsonEncode`. Success message on status `201`, failure message otherwise. Repeated taps are blocked while sending.
- **Light / dark theme** toggle on every screen.

## Tech stack

Flutter, Dart, `http`, `hive`, `hive_flutter`.

## Project structure

```text
lib/
  main.dart                  Hive setup + named routes
  models/post.dart           Post model
  services/post_service.dart       GET and POST requests
  services/favorites_service.dart  Hive create / read / update / delete
  screens/                   posts, post details, favorites
  widgets/                   reusable cards, dialogs, state views
  theme/app_theme.dart       colors, ThemeData, theme mode
test/                        unit and widget tests
```

## Setup and run (Chrome)

1. Install Flutter and VS Code (with the Flutter extension). Chrome must be installed.
2. Inside this folder run `flutter create --platforms=web .` once (adds the `web/` folder).
3. Run:

```bash
flutter pub get
flutter run -d chrome --web-port 5000
```

To check that favorites survive a restart, use `flutter run -d web-server --web-port 5000` and open `http://localhost:5000` in your normal Chrome (a fixed port keeps the browser's saved data).

## Tests

```bash
dart format lib test
flutter analyze
flutter test
```

## API

- `GET  https://jsonplaceholder.typicode.com/posts`
- `POST https://jsonplaceholder.typicode.com/posts`

## How favorites are stored

Favorites are saved in a Hive box named `favoritesBox` as plain Maps `{id, title, body, note}`. The post id is the key, so a post can't be saved twice. Data stays on the device after the app is closed.

## Known limitations

- JSONPlaceholder **only simulates** `POST`: it replies `201` but does not store the post, so it disappears from the list after refreshing or restarting. The app adds it to the visible list for the current session and says so on screen.
- The light/dark choice is not remembered after restart.

## AI assistance disclosure

This project was built with AI assistance (Claude), which the instructor allows. The team reviewed and tested the app.
