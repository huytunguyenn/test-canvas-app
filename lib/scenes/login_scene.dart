import 'package:flutter/material.dart';

import '../models/canvas_element.dart';
import '../painting/element_painter.dart';
import 'scene.dart';

class LoginScene extends Scene {
  final Map<String, String> _realValues = {
    'field_username': '',
    'field_password': '',
  };

  LoginScene({required super.onNavigate}) {
    elements.addAll([
      CanvasElement(id: 'btn_back', type: ElementType.button, label: 'Back'),
      CanvasElement(id: 'title', type: ElementType.label, label: 'Login Form'),
      CanvasElement(
        id: 'field_username',
        type: ElementType.textField,
        label: 'Username',
      ),
      CanvasElement(
        id: 'field_password',
        type: ElementType.textField,
        label: 'Password',
      ),
      CanvasElement(
        id: 'chk_remember',
        type: ElementType.checkbox,
        label: 'Remember me',
      ),
      CanvasElement(
        id: 'btn_signin',
        type: ElementType.button,
        label: 'Sign In',
      ),
      CanvasElement(
        id: 'lbl_result',
        type: ElementType.label,
        label: '',
      ),
    ]);
  }

  @override
  void layout(Size size) {
    final cx = size.width / 2;
    const formWidth = 300.0;
    final left = cx - formWidth / 2;
    var y = 40.0;

    // Back button (top-left)
    elements[0].bounds = const Rect.fromLTWH(16, 16, 80, 40);

    // Title
    y = 90;
    elements[1].bounds = Rect.fromLTWH(left, y, formWidth, 30);

    // Username field
    y += 60;
    elements[2].bounds = Rect.fromLTWH(left, y, formWidth, 44);

    // Password field
    y += 74;
    elements[3].bounds = Rect.fromLTWH(left, y, formWidth, 44);

    // Remember me checkbox
    y += 64;
    elements[4].bounds = Rect.fromLTWH(left, y, formWidth, 28);

    // Sign In button
    y += 50;
    elements[5].bounds = Rect.fromLTWH(left, y, formWidth, 48);

    // Result label
    y += 70;
    elements[6].bounds = Rect.fromLTWH(left, y, formWidth, 24);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    // Back button
    ElementPainter.drawButton(canvas, elements[0]);

    // Title
    final tp = TextPainter(
      text: TextSpan(
        text: elements[1].label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(elements[1].bounds.left, elements[1].bounds.top));

    // Text fields
    ElementPainter.drawTextField(canvas, elements[2]);
    ElementPainter.drawTextField(canvas, elements[3]);

    // Checkbox
    ElementPainter.drawCheckbox(canvas, elements[4]);

    // Sign In button
    ElementPainter.drawButton(canvas, elements[5]);

    // Result label
    if (elements[6].label.isNotEmpty) {
      ElementPainter.drawLabel(canvas, elements[6]);
    }
  }

  @override
  void onTap(CanvasElement element) {
    if (element.id == 'btn_back') {
      onNavigate('home');
      return;
    }

    if (element.id == 'chk_remember') {
      element.checked = !element.checked;
      return;
    }

    if (element.id == 'btn_signin') {
      final username = _realValues['field_username'] ?? '';
      final password = _realValues['field_password'] ?? '';
      if (username.isNotEmpty && password.isNotEmpty) {
        elements[6].label = 'Welcome, $username!';
      } else {
        elements[6].label = 'Please fill in all fields';
      }
      return;
    }

    // Handle text field focus
    if (element.type == ElementType.textField) {
      for (final e in elements) {
        if (e.type == ElementType.textField) {
          e.focused = e.id == element.id;
        }
      }
    }
  }

  @override
  void onTextChanged(String text) {
    final focusedField = elements.firstWhere(
      (e) => e.type == ElementType.textField && e.focused,
      orElse: () => elements[2],
    );
    if (!focusedField.focused) return;

    _realValues[focusedField.id] = text;

    if (focusedField.id == 'field_password') {
      focusedField.value = '\u25CF' * text.length;
    } else {
      focusedField.value = text;
    }
  }

  String getRealValue(String fieldId) => _realValues[fieldId] ?? '';
}
