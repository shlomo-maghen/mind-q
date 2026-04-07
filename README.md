# Mind-Q

> Don't lose your train of thought. Queue it.

Mind-Q is a frictionless capture app for interrupting thoughts. When you're deep in Task A and Task B surfaces in your mind, Mind-Q lets you log it in under 5 seconds and return immediately to what you were doing.

It's not a to-do list. It's a short-term buffer — a queue. You log the thought, go back to your current task, and clear the queue later when you're ready.

**Platforms:** iOS · Android · Web (single Flutter codebase)

---

## Features

- **Quick Add** — type a thought and tap "Quick Add"; the app immediately backgrounds itself so you can return to what you were doing
- **FIFO queue** — items are shown oldest-first so you address them in the order they arrived
- **Timed reminder** — one notification fires after a configurable delay (default 60 min) reminding you to review the queue

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (tested on Dart SDK ^3.9)
- Android Studio, Xcode (for mobile targets), or VS Code with the [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)

Verify your Flutter setup:
```sh
flutter doctor
```

---

## Installation

```sh
git clone https://github.com/shlomo-maghen/mind-q
cd mind-q
flutter pub get
```

---

## Running

```sh
flutter run -d android   # Android device or emulator
flutter run -d ios       # iOS simulator or device (macOS only)
flutter run -d chrome    # Web (Chrome)
```

Or use the **Run and Debug** panel in VS Code / Android Studio to select a device and launch.

---

## Android — notification permissions

On Android 12+, the app will prompt for:
- **Post Notifications** — to show reminders
- **Exact Alarms** — to fire reminders at the scheduled time (opens system "Alarms & reminders" settings)

Both prompts appear when you enable notifications in Settings for the first time.
