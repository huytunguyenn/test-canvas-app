import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/canvas_element.dart';
import '../painting/element_painter.dart';

abstract class Scene {
  final List<CanvasElement> elements = [];
  final void Function(String sceneName) onNavigate;

  Scene({required this.onNavigate});

  void layout(Size size);

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
