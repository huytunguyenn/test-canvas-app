import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/canvas_element.dart';
import '../painting/element_painter.dart';
import 'scene.dart';

class HomeScene extends Scene {
  ui.Image? _avatarImage;

  HomeScene({required super.onNavigate}) {
    elements.addAll([
      CanvasElement(id: 'avatar', type: ElementType.label, label: ''),
      CanvasElement(id: 'title', type: ElementType.label, label: 'Canvas Test App'),
      CanvasElement(id: 'subtitle', type: ElementType.label, label: 'All UI is drawn on Canvas'),
      CanvasElement(id: 'btn_login', type: ElementType.button, label: 'Login Form'),
      CanvasElement(id: 'btn_dashboard', type: ElementType.button, label: 'Dashboard'),
    ]);
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final data = await rootBundle.load('assets/avatar.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    _avatarImage = frame.image;
    onRepaint?.call();
  }

  @override
  void layout(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const avatarSize = 100.0;

    // Avatar
    elements[0].bounds = Rect.fromCenter(
      center: Offset(cx, cy - 160),
      width: avatarSize,
      height: avatarSize,
    );
    // Title
    elements[1].bounds = Rect.fromCenter(
      center: Offset(cx, cy - 80),
      width: 300,
      height: 30,
    );
    // Subtitle
    elements[2].bounds = Rect.fromCenter(
      center: Offset(cx, cy - 40),
      width: 300,
      height: 20,
    );
    // Login button
    elements[3].bounds = Rect.fromCenter(
      center: Offset(cx, cy + 30),
      width: 220,
      height: 48,
    );
    // Dashboard button
    elements[4].bounds = Rect.fromCenter(
      center: Offset(cx, cy + 100),
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

    // Avatar (circular clipped image)
    final avatarBounds = elements[0].bounds;
    if (_avatarImage != null) {
      canvas.save();
      canvas.clipPath(
        Path()..addOval(avatarBounds),
      );
      canvas.drawImageRect(
        _avatarImage!,
        Rect.fromLTWH(
          0, 0,
          _avatarImage!.width.toDouble(),
          _avatarImage!.height.toDouble(),
        ),
        avatarBounds,
        Paint()..filterQuality = FilterQuality.medium,
      );
      canvas.restore();
    } else {
      // Placeholder circle while loading
      canvas.drawOval(
        avatarBounds,
        Paint()..color = Colors.grey.shade300,
      );
    }

    // Title
    _drawCenteredText(
      canvas,
      elements[1].label,
      elements[1].bounds,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    // Subtitle
    _drawCenteredText(
      canvas,
      elements[2].label,
      elements[2].bounds,
      fontSize: 15,
      color: Colors.grey.shade600,
    );

    // Buttons
    for (var i = 3; i < elements.length; i++) {
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
