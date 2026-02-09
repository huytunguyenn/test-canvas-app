import 'package:flutter/material.dart';

import '../models/canvas_element.dart';
import '../painting/element_painter.dart';
import 'scene.dart';

class DashboardScene extends Scene {
  DashboardScene({required super.onNavigate}) {
    elements.addAll([
      CanvasElement(id: 'btn_back', type: ElementType.button, label: 'Back'),
      CanvasElement(
          id: 'title', type: ElementType.label, label: 'Dashboard'),
      CanvasElement(
        id: 'card_users',
        type: ElementType.card,
        label: 'Total Users',
        value: '1,234',
      ),
      CanvasElement(
        id: 'card_revenue',
        type: ElementType.card,
        label: 'Revenue',
        value: '\$45,678',
      ),
      CanvasElement(
        id: 'card_orders',
        type: ElementType.card,
        label: 'Orders',
        value: '892',
      ),
      CanvasElement(
        id: 'btn_refresh',
        type: ElementType.button,
        label: 'Refresh Data',
      ),
      CanvasElement(
        id: 'btn_export',
        type: ElementType.button,
        label: 'Export Report',
      ),
      CanvasElement(
        id: 'chk_notifications',
        type: ElementType.checkbox,
        label: 'Enable notifications',
      ),
    ]);
  }

  @override
  void layout(Size size) {
    final cx = size.width / 2;
    const padding = 16.0;
    const cardGap = 10.0;
    final availableWidth = size.width - padding * 2;
    final cardWidth = (availableWidth - cardGap * 2) / 3;
    const cardHeight = 80.0;

    // Back button
    elements[0].bounds = const Rect.fromLTWH(16, 50, 80, 40);

    // Title
    elements[1].bounds = Rect.fromLTWH(padding, 110, availableWidth, 32);

    // 3 stat cards in a row — responsive to screen width
    for (var i = 0; i < 3; i++) {
      elements[2 + i].bounds = Rect.fromLTWH(
        padding + i * (cardWidth + cardGap),
        170,
        cardWidth,
        cardHeight,
      );
    }

    // Action buttons side by side — responsive
    const btnGap = 12.0;
    final btnWidth = (availableWidth - btnGap) / 2;

    elements[5].bounds = Rect.fromLTWH(padding, 290, btnWidth, 48);
    elements[6].bounds =
        Rect.fromLTWH(padding + btnWidth + btnGap, 290, btnWidth, 48);

    // Notifications checkbox
    elements[7].bounds = Rect.fromLTWH(cx - 120, 370, 240, 28);
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

    // Cards
    ElementPainter.drawCard(canvas, elements[2]);
    ElementPainter.drawCard(canvas, elements[3]);
    ElementPainter.drawCard(canvas, elements[4]);

    // Action buttons
    ElementPainter.drawButton(canvas, elements[5]);
    ElementPainter.drawButton(canvas, elements[6]);

    // Checkbox
    ElementPainter.drawCheckbox(canvas, elements[7]);
  }

  @override
  void onTap(CanvasElement element) {
    if (element.id == 'btn_back') {
      onNavigate('home');
      return;
    }

    if (element.id == 'chk_notifications') {
      element.checked = !element.checked;
      return;
    }

    if (element.id == 'btn_refresh') {
      // Simulate refresh: update values
      elements[2].value = '1,${250 + DateTime.now().second}';
      elements[3].value = '\$${45000 + DateTime.now().millisecond}';
      elements[4].value = '${890 + DateTime.now().second}';
      return;
    }
  }
}
