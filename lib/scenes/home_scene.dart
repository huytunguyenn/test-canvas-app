import 'package:flutter/material.dart';

import '../models/canvas_element.dart';
import '../painting/element_painter.dart';
import 'scene.dart';

class HomeScene extends Scene {
  HomeScene({required super.onNavigate}) {
    elements.addAll([
      CanvasElement(id: 'title', type: ElementType.label, label: 'Canvas Test App'),
      CanvasElement(id: 'subtitle', type: ElementType.label, label: 'All UI is drawn on Canvas'),
      CanvasElement(id: 'btn_login', type: ElementType.button, label: 'Login Form'),
      CanvasElement(id: 'btn_dashboard', type: ElementType.button, label: 'Dashboard'),
    ]);
  }

  @override
  void layout(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    elements[0].bounds = Rect.fromCenter(
      center: Offset(cx, cy - 100),
      width: 300,
      height: 30,
    );
    elements[1].bounds = Rect.fromCenter(
      center: Offset(cx, cy - 60),
      width: 300,
      height: 20,
    );
    elements[2].bounds = Rect.fromCenter(
      center: Offset(cx, cy + 10),
      width: 220,
      height: 48,
    );
    elements[3].bounds = Rect.fromCenter(
      center: Offset(cx, cy + 80),
      width: 220,
      height: 48,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    // Title - large centered
    _drawCenteredText(
      canvas,
      elements[0].label,
      elements[0].bounds,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    // Subtitle
    _drawCenteredText(
      canvas,
      elements[1].label,
      elements[1].bounds,
      fontSize: 15,
      color: Colors.grey.shade600,
    );

    // Buttons
    for (var i = 2; i < elements.length; i++) {
      ElementPainter.drawButton(canvas, elements[i]);
    }
  }

  @override
  void onTap(CanvasElement element) {
    if (element.id == 'btn_login') {
      onNavigate('login');
    } else if (element.id == 'btn_dashboard') {
      onNavigate('dashboard');
    }
  }

  void _drawCenteredText(
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
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        bounds.left + (bounds.width - tp.width) / 2,
        bounds.top + (bounds.height - tp.height) / 2,
      ),
    );
  }
}
