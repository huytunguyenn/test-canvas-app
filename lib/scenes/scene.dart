import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/canvas_element.dart';
import '../painting/element_painter.dart';

abstract class Scene {
  final List<CanvasElement> elements = [];
  final void Function(String sceneName) onNavigate;
  VoidCallback? onRepaint;

  bool _showGroundTruth = false;
  final CanvasElement _debugButton = CanvasElement(
    id: 'debug_ground_truth',
    type: ElementType.button,
    label: 'GT',
  );

  Scene({required this.onNavigate});

  void layout(Size size);

  void layoutDebugButton(Size size) {
    _debugButton.bounds = Rect.fromLTWH(size.width - 60, size.height - 52, 48, 40);
  }

  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    for (final element in elements) {
      switch (element.type) {
        case ElementType.button:
          ElementPainter.drawButton(canvas, element);
        case ElementType.textField:
          ElementPainter.drawTextField(canvas, element);
        case ElementType.label:
          ElementPainter.drawLabel(canvas, element);
        case ElementType.checkbox:
          ElementPainter.drawCheckbox(canvas, element);
        case ElementType.card:
          ElementPainter.drawCard(canvas, element);
      }
    }
  }

  bool get showGroundTruth => _showGroundTruth;

  void paintDebugOverlay(Canvas canvas, Size size) {
    // Debug button (small, bottom-right)
    final btnRect = _debugButton.bounds;
    final btnRRect = RRect.fromRectAndRadius(btnRect, const Radius.circular(6));
    canvas.drawRRect(
      btnRRect,
      Paint()..color = _showGroundTruth ? Colors.red.shade700 : Colors.grey.shade700,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: _debugButton.label,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        btnRect.left + (btnRect.width - tp.width) / 2,
        btnRect.top + (btnRect.height - tp.height) / 2,
      ),
    );

    if (!_showGroundTruth) return;

    // Draw bounding boxes over each element
    for (final element in elements) {
      // Semi-transparent fill
      canvas.drawRect(
        element.bounds,
        Paint()..color = _colorForType(element.type).withValues(alpha: 0.1),
      );
      // Border
      canvas.drawRect(
        element.bounds,
        Paint()
          ..color = _colorForType(element.type)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Element id label with background
      final labelText = '${element.id} (${element.type.name})';
      final labelTp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            color: _colorForType(element.type),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final labelY = (element.bounds.top - 16).clamp(0.0, size.height - 14);
      // Label background
      canvas.drawRect(
        Rect.fromLTWH(element.bounds.left, labelY, labelTp.width + 4, 14),
        Paint()..color = Colors.black87,
      );
      labelTp.paint(canvas, Offset(element.bounds.left + 2, labelY + 1));
    }
  }

  Color _colorForType(ElementType type) {
    switch (type) {
      case ElementType.button:
        return Colors.cyanAccent;
      case ElementType.textField:
        return Colors.yellowAccent;
      case ElementType.label:
        return Colors.white70;
      case ElementType.checkbox:
        return Colors.orangeAccent;
      case ElementType.card:
        return Colors.purpleAccent;
    }
  }

  bool handleDebugTap(Offset position) {
    if (_debugButton.hitTest(position)) {
      _showGroundTruth = !_showGroundTruth;
      return true;
    }
    return false;
  }

  CanvasElement? hitTest(Offset position) {
    for (final element in elements.reversed) {
      if (element.hitTest(position)) return element;
    }
    return null;
  }

  void onTap(CanvasElement element) {}

  void onTextChanged(String text) {}

  String? get activeTextFieldId {
    for (final element in elements) {
      if (element.type == ElementType.textField && element.focused) {
        return element.id;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> exportGroundTruth() =>
      elements.map((e) => e.toGroundTruth()).toList();
}
