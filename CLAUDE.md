# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Canvas-based Flutter test app (test_canvas_app) where ALL visible UI is drawn via `CustomPainter` — no Flutter widgets in the visual tree. Simulates a remote desktop viewer for testing LLM-based element detection from screenshots. Targets iOS, Android, web, macOS, Linux, and Windows. Uses Dart SDK ^3.10.8.

## Commands

- **Run app:** `flutter run` (add `-d <device>` to target a specific device)
- **Build:** `flutter build <platform>` (e.g., `flutter build ios`, `flutter build apk`)
- **Run all tests:** `flutter test`
- **Run a single test:** `flutter test test/widget_test.dart`
- **Analyze/lint:** `flutter analyze`
- **Get dependencies:** `flutter pub get`

## Architecture

```
lib/
  main.dart                  # App shell (CanvasTestApp → CanvasShell), scene navigation + caching
  models/
    canvas_element.dart      # Element model: id, type, bounds, state, hitTest(), toGroundTruth()
  painting/
    element_painter.dart     # Static paint helpers: drawButton, drawTextField, drawLabel, drawCheckbox, drawCard
  scenes/
    scene.dart               # Abstract base: elements list, layout, paint, hitTest, debug overlay
    home_scene.dart          # Avatar image, title, subtitle, 2 nav buttons
    login_scene.dart         # Back, title, username/password fields, checkbox, sign in, result label
    dashboard_scene.dart     # Back, title, 3 stat cards, 2 action buttons, notifications checkbox
  widgets/
    remote_canvas.dart       # CustomPaint + GestureDetector + hidden TextField (Opacity 0.0)
assets/
    avatar.png               # Avatar image drawn on canvas in home scene
```

Key classes:
- `CanvasTestApp` (StatelessWidget) — root MaterialApp
- `CanvasShell` (StatefulWidget) — manages current scene name + scene cache map
- `RemoteCanvas` (StatefulWidget) — delegates paint/hitTest/tap to Scene, manages hidden TextField for keyboard input
- `Scene` (abstract) — base class with element management, ground truth export, and debug overlay
- `CanvasElement` — element model with hit-testing and JSON export

## Key Design Decisions

- **Hidden TextField with Opacity(0.0)** — stays in layout tree for focus/keyboard but invisible in screenshots
- **Password masking** — scene stores real value internally, displays bullet characters
- **Scene caching** — scene instances stored in map, state preserved across navigation
- **shouldRepaint always true** — repaints only on user interaction so overhead is negligible
- **onRepaint callback** — allows async operations (e.g., image loading) to trigger repaints
- **Debug overlay (GT button)** — bottom-right button on every screen toggles ground truth overlay with bounding boxes and JSON

Linting uses `package:flutter_lints/flutter.yaml` (configured in `analysis_options.yaml`).
