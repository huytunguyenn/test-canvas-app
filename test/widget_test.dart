import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_canvas_app/main.dart';

void main() {
  testWidgets('App renders with canvas, no Flutter Text widgets visible',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CanvasTestApp());
    await tester.pump();

    // App should render without errors
    expect(find.byType(CustomPaint), findsWidgets);

    // No visible Flutter Text widgets in the tree (all text is canvas-drawn).
    // The only Text that may exist is inside the hidden TextField.
    final textWidgets = find.byType(Text);
    for (final element in textWidgets.evaluate()) {
      final widget = element.widget as Text;
      // Any Text widget present should have empty or null data (from hidden TextField)
      expect(widget.data == null || widget.data!.isEmpty, isTrue,
          reason: 'Found visible Text widget with content: ${widget.data}');
    }
  });
}
