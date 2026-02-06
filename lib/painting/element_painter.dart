import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/canvas_element.dart';

class ElementPainter {
  static void drawButton(Canvas canvas, CanvasElement element) {
    final bgColor = element.enabled ? Colors.blue : Colors.grey;
    final rrect =
        RRect.fromRectAndRadius(element.bounds, const Radius.circular(8));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill,
    );

    _drawCenteredText(
      canvas,
      element.label,
      element.bounds,
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }

  static void drawTextField(Canvas canvas, CanvasElement element) {
    final rect = element.bounds;
    final borderColor = element.focused ? Colors.blue : Colors.grey;

    // Background
    canvas.drawRect(rect, Paint()..color = Colors.white);

    // Border
    canvas.drawRect(
      rect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = element.focused ? 2.0 : 1.0,
    );

    // Label above
    _drawText(
      canvas,
      element.label,
      Offset(rect.left, rect.top - 20),
      color: Colors.black87,
      fontSize: 13,
    );

    // Value or placeholder
    final displayText = element.value.isEmpty ? 'Enter ${element.label}' : element.value;
    final textColor = element.value.isEmpty ? Colors.grey : Colors.black;
    _drawText(
      canvas,
      displayText,
      Offset(rect.left + 8, rect.top + (rect.height - 16) / 2),
      color: textColor,
      fontSize: 15,
    );

    // Cursor when focused
    if (element.focused) {
      final cursorPainter = TextPainter(
        text: TextSpan(
          text: element.value.isEmpty ? '' : element.value,
          style: const TextStyle(fontSize: 15),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final cursorX = rect.left + 8 + cursorPainter.width + 1;
      canvas.drawLine(
        Offset(cursorX, rect.top + 6),
        Offset(cursorX, rect.bottom - 6),
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2,
      );
    }
  }

  static void drawLabel(Canvas canvas, CanvasElement element) {
    _drawText(
      canvas,
      element.label,
      Offset(element.bounds.left, element.bounds.top),
      color: Colors.black,
      fontSize: 14,
    );
  }

  static void drawCheckbox(Canvas canvas, CanvasElement element) {
    final boxSize = element.bounds.height.clamp(18.0, 24.0);
    final boxRect = Rect.fromLTWH(
      element.bounds.left,
      element.bounds.top + (element.bounds.height - boxSize) / 2,
      boxSize,
      boxSize,
    );

    // Box border
    canvas.drawRect(
      boxRect,
      Paint()
        ..color = element.checked ? Colors.blue : Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Fill when checked
    if (element.checked) {
      canvas.drawRect(
        boxRect.deflate(3),
        Paint()..color = Colors.blue,
      );
      // Checkmark
      final path = Path()
        ..moveTo(boxRect.left + 4, boxRect.top + boxSize / 2)
        ..lineTo(boxRect.left + boxSize / 2 - 1, boxRect.bottom - 5)
        ..lineTo(boxRect.right - 4, boxRect.top + 5);
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Label to the right
    _drawText(
      canvas,
      element.label,
      Offset(
        element.bounds.left + boxSize + 8,
        element.bounds.top + (element.bounds.height - 15) / 2,
      ),
      color: Colors.black87,
      fontSize: 15,
    );
  }

  static void drawCard(Canvas canvas, CanvasElement element) {
    final rrect =
        RRect.fromRectAndRadius(element.bounds, const Radius.circular(12));

    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(2, 2)),
      Paint()..color = Colors.black12,
    );

    // Card background
    canvas.drawRRect(rrect, Paint()..color = Colors.white);

    // Card border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke,
    );

    // Label (title)
    _drawText(
      canvas,
      element.label,
      Offset(element.bounds.left + 16, element.bounds.top + 14),
      color: Colors.grey.shade600,
      fontSize: 13,
    );

    // Value (main content)
    _drawText(
      canvas,
      element.value,
      Offset(element.bounds.left + 16, element.bounds.top + 38),
      color: Colors.black,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );
  }

  static void _drawCenteredText(
    Canvas canvas,
    String text,
    Rect bounds, {
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        bounds.left + (bounds.width - tp.width) / 2,
        bounds.top + (bounds.height - tp.height) / 2,
      ),
    );
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }
}
