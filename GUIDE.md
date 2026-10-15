# Simple Guide: run the app in Chrome, test it, and submit

Group: Alvarez, Claude S. · Amador, Mark Christian Subala · Gana, Nathaniel E. — Section 3 IT A — Prof. Albert Q. Alforja

> The code has not been run yet by the author (no Flutter SDK was available). Follow the steps and send the exact error text if something fails.

## Part A – One-time setup
1. Install **Flutter** (flutter.dev) and **VS Code**, plus the **Flutter** extension in VS Code (it also installs Dart). Chrome must be installed.
2. In VS Code: **File > Open Folder** > choose `post_reader_favorites` (the unzipped folder).
3. Open the terminal: **Terminal > New Terminal**.
4. Check Flutter: `flutter doctor` — the Flutter and Chrome lines should have a green tick. (Android lines don't matter for Chrome.)
5. Create the web files: `flutter create --platforms=web .`
   Expected: it adds a `web/` folder. It does NOT overwrite `lib/` or `pubspec.yaml`.
6. Download packages: `flutter pub get` — expected: "Got dependencies!".

## Part B – Check the code
```
dart format lib test
flutter analyze
flutter test
```
Expected: "No issues found!" and "All tests passed!". Any red error: copy it and send it to me.

## Part C – Run in Chrome
Use this command (it keeps the SAME address every time, which keeps your saved favorites):
```
flutter run -d chrome --web-port 5000
```
- Wait for Chrome to open (first time takes 1–3 minutes). You should see "Discover Posts" with a list.
- In the terminal: `r` = hot reload, `R` = restart, `q` = quit.
- Make it look like a phone: in Chrome press `F12`, then `Ctrl+Shift+M`, choose "Pixel 7" or "iPhone 14".

**Important – testing "still saved after reopening":** Chrome opened by `flutter run` may use a temporary profile, so favorites could vanish when you stop and re-run. Use the safer way for that test:
1. Stop the app (`q`).
2. Run: `flutter run -d web-server --web-port 5000`
3. Open your normal Chrome and go to `http://localhost:5000`.
4. Save favorites + a note. Close the tab. Stop (`q`), run the same command again, open `http://localhost:5000` — favorites and notes should still be there. Refreshing the page (`F5`) also proves it.

## Part D – Test checklist
| # | Do this | You should see |
|---|---------|----------------|
| 1 | Open the app | Posts list (100 posts) |
| 2 | Tap a post | Details: correct #id, title, body. Back arrow returns |
| 3 | Bookmarks icon (top right) | Favorites screen |
| 4 | "New post" button > Submit empty | Red messages: title / body required |
| 5 | Fill both > Submit | Spinner, then success message; post at top with NEW tag |
| 6 | Details > Save to Favorites | "Saved" message, button changes |
| 7 | Press it again | "Already in your favorites" |
| 8 | Favorites > pencil > type note > Save note | Note shows immediately |
| 9 | Trash icon > Remove (or drag card left) | Confirm, then it disappears; empty message when none left |
| 10 | Reopen test from Part C | Favorites and notes still there |
| 11 | Sun/moon icon | Light/dark theme everywhere |
| 12 | Error test: Chrome DevTools (F12) > Network tab > set "Offline", press "Try again"/refresh | Error message with Try again button |

## Part E – Screenshots (Windows: `Win+Shift+S`, then paste in Paint and save; Mac: `Cmd+Shift+4`). Put them in a `screenshots` folder.
| File | Show |
|---|---|
| `01_posts_list.png` | Posts list loaded |
| `02_post_details.png` | A post's details with Save button |
| `03_post_result.png` | Success message right after submitting a new post |
| `04_favorites.png` | Favorites with 2+ posts |
| `05_edit_note.png` | Edit note dialog or the saved note |
| `06_delete.png` | Remove confirmation or "Removed" message |
| `07_after_reopen.png` | Favorites after stopping and reopening (Part C test) |

Screen recording instead: Windows `Win+Alt+R` (Xbox Game Bar) – record the whole checklist in under 2 minutes.

## Part F – Submit
File name: `ITP107_FinalsLabExam_3ITA_Alvarez.zip` (format Section_LastName; use the last name your group agrees on and your exact section text).

- **ZIP:** delete the `build/` and `.dart_tool/` folders, then zip the whole project folder (keep `lib`, `test`, `web`, `pubspec.yaml`, `README.md`) and add your screenshots.
- **GitHub:** create a repo, then `git init`, `git add .`, `git commit -m "Finals lab exam"`, push. Type the real link in the GITHUB LINK line of the exam form. Never type a fake link.
- **Exam form:** names and section are already filled in. Leave SCORE for the professor.

## Rubric map (status stays "not run" until you test it)
| Requirement | File |
|---|---|
| 3 named routes + `initialRoute`/`routes` | `lib/main.dart` |
| `pushNamed`/`pop`, AppBar Favorites button, arguments via `ModalRoute` | `posts_screen.dart`, `post_details_screen.dart` |
| `http.get` from `initState`, status 200, `jsonDecode`, `ListView.builder` + `ListTile`, on-screen error | `post_service.dart`, `posts_screen.dart`, `post_card.dart`, `error_view.dart` |
| FAB dialog, validation, `http.post` + `jsonEncode`, 201/failure message | `add_post_dialog.dart`, `post_service.dart` |
| Hive init order, Create/Read/Update/Delete, persistence | `main.dart`, `favorites_service.dart`, `favorites_screen.dart`, `edit_note_dialog.dart` |
| ThemeData consistency + light/dark | `app_theme.dart` |
