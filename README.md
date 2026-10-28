# TaskFlow

> A focused, privacy-friendly task manager built with Flutter.

TaskFlow helps you capture, organize, and complete everyday work without requiring an account or a network connection. Tasks, profile preferences, and theme settings are kept locally on the device, giving the app a fast and dependable offline-first experience.

## Highlights

- Create, edit, complete, and delete tasks
- Add due dates and times to keep work on schedule
- Organize work with task categories
- Keep active and completed tasks easy to find
- Personalize the app with a local profile
- Follow the system theme or choose light and dark mode
- Persist data locally with no backend or sign-in required
- Use the same Flutter codebase across mobile, desktop, and web

## Screenshots

| Home | Tasks | Add Task |
| :---: | :---: | :---: |
| ![Home](docs/screenshots/home.png) | ![Tasks](docs/screenshots/tasks.png) | ![Add Task](docs/screenshots/add_task.png) |

| Edit Task | Completed | Profile |
| :---: | :---: | :---: |
| ![Edit Task](docs/screenshots/edit_task.png) | ![Completed](docs/screenshots/completed.png) | ![Profile](docs/screenshots/profile.png) |

## Tech stack

- **Flutter** with Material 3
- **Dart** 3.10.4 or newer
- **Provider** for reactive application state
- **SQLite** through `sqflite` for native platforms
- **SQLite FFI** through `sqflite_common_ffi` for Windows, macOS, and Linux
- **SharedPreferences** for profile and theme settings, plus web task storage
- **Inter** for the application typography

## Architecture

The project is organized by responsibility:

```text
lib/
├── models/       Domain models such as Task and Profile
├── providers/    ChangeNotifier state for tasks, profiles, and themes
├── screens/      Home, task, completed-task, edit, and profile views
├── services/     Storage abstractions and platform-specific persistence
├── theme/        Shared colors and theme configuration
└── widgets/      Reusable task and form components
```

`TaskStorage` selects the persistence implementation at runtime. Native builds use SQLite, while web builds use a SharedPreferences-backed implementation because browser environments do not provide native SQLite.

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) with Dart 3.10.4+
- An emulator, simulator, physical device, or desktop target supported by Flutter

Check your local setup with:

```bash
flutter doctor
```

## Get started

Clone the repository, install dependencies, and launch the app:

```bash
git clone https://github.com/DuminduMalinga/TaskFlow.git
cd TaskFlow
flutter pub get
flutter run
```

To select a specific target, use Flutter's device flag:

```bash
flutter devices
flutter run -d <device-id>
```

## Quality checks

Run the automated test suite and static analysis before opening a pull request:

```bash
flutter test
flutter analyze
```

Format Dart files with:

```bash
dart format .
```

## Building

Flutter can package TaskFlow for any enabled target. For example:

```bash
flutter build apk       # Android
flutter build ios       # iOS (macOS required)
flutter build web       # Web
flutter build windows   # Windows
```

Refer to the [Flutter deployment documentation](https://docs.flutter.dev/deployment) for platform-specific signing and release configuration.

## Contributing

1. Create a focused branch for your change.
2. Keep user data local and preserve the existing platform storage behavior.
3. Add or update tests for behavioral changes.
4. Run `dart format .`, `flutter analyze`, and `flutter test`.
5. Open a pull request with a concise description of the change.

## License

No license has been declared for this repository yet. Contact the repository owner before redistributing the project or incorporating it into another product.
