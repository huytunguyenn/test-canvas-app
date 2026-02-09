# Kobiton Canvas App

A Flutter app where **all UI is drawn via `CustomPainter` on canvas** — no Flutter widgets appear in the visual tree. This simulates a remote desktop viewer to validate LLM-based element detection from screenshots.

## App Identifiers

| Platform | Bundle / Package ID |
|----------|---------------------|
| Android | `com.kobiton.kobiton_canvas_app` |
| iOS | `com.kobiton.kobitonCanvasApp` |
| macOS | `com.kobiton.kobitonCanvasApp` |
| Linux | `com.kobiton.kobiton_canvas_app` |
| Dart package | `kobiton_canvas_app` |

## Why

Standard Flutter apps expose a widget tree that accessibility tools and test frameworks can inspect. This app deliberately avoids that — all buttons, text fields, checkboxes, cards, and labels are painted directly on a `Canvas`. The only way to identify UI elements is by analyzing the rendered pixels, making it ideal for testing vision-based element detection (e.g., an LLM-powered Appium server).

## Scenes

The app has 3 scenes, navigable via canvas-drawn buttons:

### Home
- Circular avatar image (loaded from assets, drawn on canvas)
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

### Debug Overlay (all screens)

Every screen has a **"GT" button** in the bottom-right corner. Tap it to toggle the ground truth debug overlay:

- **Dark overlay** covers the screen
- **Colored bounding boxes** around each element (cyan = button, yellow = text field, white = label, orange = checkbox, purple = card)
- **Element IDs and types** labeled above each box
- **Full JSON** of all elements displayed in green monospace text
- Tap "GT" again to dismiss

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

### Build for Distribution

| Platform | Command | Output |
|----------|---------|--------|
| Android APK | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android AAB | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |
| iOS | `flutter build ipa --release` | `build/ios/ipa/*.ipa` |
| Web | `flutter build web --release` | `build/web/` |
| macOS | `flutter build macos --release` | `build/macos/Build/Products/Release/*.app` |

**Android** — install APK directly on a device:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**iOS** — requires macOS with Xcode and an Apple Developer account. Configure signing first:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to Runner → Signing & Capabilities → select your Team
3. Then run `flutter build ipa --release`

**Web** — produces a static site in `build/web/`:
```bash
flutter build web --release
```

Output contents:
```
build/web/
  index.html            # Entry point
  main.dart.js          # Compiled Dart → JavaScript
  flutter.js            # Flutter engine loader
  flutter_bootstrap.js
  manifest.json         # PWA manifest
  assets/               # Fonts, images (avatar.png), etc.
  canvaskit/            # CanvasKit rendering engine (WASM)
```

Host on any static file server (Nginx, GitHub Pages, Firebase Hosting, Netlify, S3, etc.). To preview locally:
```bash
cd build/web && python3 -m http.server 8080
# Open http://localhost:8080
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
    scene.dart                    # Abstract base class with debug overlay
    home_scene.dart               # Home screen with avatar and navigation buttons
    login_scene.dart              # Login form with text input and validation
    dashboard_scene.dart          # Dashboard with stat cards and actions
  widgets/
    remote_canvas.dart            # CustomPaint + GestureDetector + hidden TextField
assets/
    avatar.png                    # Avatar image drawn on canvas in home scene
```

### How It Works

1. **RemoteCanvas** is the only widget in the visual tree. It contains:
   - A `GestureDetector` that forwards taps to the active scene's `hitTest()`
   - A `CustomPaint` that delegates to the scene's `paint()` method
   - A hidden `TextField` (Opacity 0.0) that captures keyboard input without being visible in screenshots

2. **Scene** subclasses own all elements and state. They define `layout(Size)` for responsive positioning, `paint()` for rendering, and `onTap()` / `onTextChanged()` for interaction. The base class provides the debug overlay and ground truth export.

3. **ElementPainter** provides static methods (`drawButton`, `drawTextField`, `drawLabel`, `drawCheckbox`, `drawCard`) that render elements using `Canvas` and `TextPainter`.

4. **Scene caching** — scene instances are stored in a map so state (typed text, checkbox values) persists across navigation.

5. **Async image loading** — `HomeScene` loads `assets/avatar.png` asynchronously and triggers a repaint via the `onRepaint` callback when ready. A grey circle placeholder is shown while loading.

## Ground Truth Export

Each scene can export its elements as structured JSON via `scene.exportGroundTruth()`, returning bounding boxes and state for every element. This enables comparison between what an LLM detects in a screenshot and the actual element positions.

You can view the ground truth directly in the app by tapping the **"GT" button** in the bottom-right corner of any screen.

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
