# Canvas Test App

A Flutter app where **all UI is drawn via `CustomPainter` on canvas** — no Flutter widgets appear in the visual tree. This simulates a remote desktop viewer to validate LLM-based element detection from screenshots.

## Why

Standard Flutter apps expose a widget tree that accessibility tools and test frameworks can inspect. This app deliberately avoids that — all buttons, text fields, checkboxes, cards, and labels are painted directly on a `Canvas`. The only way to identify UI elements is by analyzing the rendered pixels, making it ideal for testing vision-based element detection (e.g., an LLM-powered Appium server).

## Scenes

The app has 3 scenes, navigable via canvas-drawn buttons:

### Home
- Title and subtitle
- "Login Form" button → navigates to Login scene
- "Dashboard" button → navigates to Dashboard scene

### Login Form
- Back button → returns to Home
- Username text field (tap to focus, type with keyboard)
- Password text field (input masked with bullet characters)
- "Remember me" checkbox (toggles on tap)
- "Sign In" button (validates fields, shows result message)

### Dashboard
- Back button → returns to Home
- 3 stat cards (Total Users, Revenue, Orders)
- "Refresh Data" button (randomizes stat values)
- "Export Report" button
- "Enable notifications" checkbox

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Dart SDK ^3.10.8)

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d chrome    # Web
flutter run -d macos     # macOS desktop
flutter run -d <device>  # Any connected device
```

### Run Tests

```bash
flutter test
```

### Static Analysis

```bash
flutter analyze
```

## Architecture

```
lib/
  main.dart                       # App shell, scene navigation, scene caching
  models/
    canvas_element.dart           # Element model (id, type, bounds, state, hit-testing, JSON export)
  painting/
    element_painter.dart          # Static paint helpers for each element type
  scenes/
    scene.dart                    # Abstract base class for all scenes
    home_scene.dart               # Home screen with navigation buttons
    login_scene.dart              # Login form with text input and validation
    dashboard_scene.dart          # Dashboard with stat cards and actions
  widgets/
    remote_canvas.dart            # CustomPaint + GestureDetector + hidden TextField
```

### How It Works

1. **RemoteCanvas** is the only widget in the visual tree. It contains:
   - A `GestureDetector` that forwards taps to the active scene's `hitTest()`
   - A `CustomPaint` that delegates to the scene's `paint()` method
   - A hidden `TextField` (Opacity 0.0) that captures keyboard input without being visible in screenshots

2. **Scene** subclasses own all elements and state. They define `layout(Size)` for responsive positioning, `paint()` for rendering, and `onTap()` / `onTextChanged()` for interaction.

3. **ElementPainter** provides static methods (`drawButton`, `drawTextField`, `drawLabel`, `drawCheckbox`, `drawCard`) that render elements using `Canvas` and `TextPainter`.

4. **Scene caching** — scene instances are stored in a map so state (typed text, checkbox values) persists across navigation.

## Ground Truth Export

Each scene can export its elements as structured JSON via `scene.exportGroundTruth()`, returning bounding boxes and state for every element. This enables comparison between what an LLM detects in a screenshot and the actual element positions.

Example output:
```json
[
  {
    "id": "btn_login",
    "type": "button",
    "bounds": {"left": 90, "top": 210, "width": 220, "height": 48},
    "label": "Login Form",
    "value": "",
    "enabled": true,
    "checked": false,
    "focused": false
  }
]
```
