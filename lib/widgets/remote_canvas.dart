import 'package:flutter/material.dart';

import '../models/canvas_element.dart';
import '../scenes/scene.dart';

class RemoteCanvas extends StatefulWidget {
  final Scene scene;

  const RemoteCanvas({super.key, required this.scene});

  @override
  State<RemoteCanvas> createState() => _RemoteCanvasState();
}

class _RemoteCanvasState extends State<RemoteCanvas> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant RemoteCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene != widget.scene) {
      _textController.clear();
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) {
    final scene = widget.scene;
    final size = context.size;
    if (size == null) return;

    scene.layout(size);
    final element = scene.hitTest(details.localPosition);

    if (element != null) {
      scene.onTap(element);

      // If a text field was tapped, sync controller and request focus
      if (element.type == ElementType.textField) {
        _textController.text = element.value;
        _textController.selection = TextSelection.collapsed(
          offset: element.value.length,
        );
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
      }
    } else {
      // Unfocus all text fields
      for (final e in scene.elements) {
        if (e.type == ElementType.textField) {
          e.focused = false;
        }
      }
      _focusNode.unfocus();
    }

    setState(() {});
  }

  void _onTextChanged(String text) {
    widget.scene.onTextChanged(text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: _handleTap,
          child: CustomPaint(
            painter: _ScenePainter(widget.scene),
            size: Size.infinite,
          ),
        ),
        // Hidden text field for keyboard input
        Positioned(
          left: 0,
          top: 0,
          width: 1,
          height: 1,
          child: Opacity(
            opacity: 0.0,
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              onChanged: _onTextChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  final Scene scene;

  _ScenePainter(this.scene);

  @override
  void paint(Canvas canvas, Size size) {
    scene.layout(size);
    scene.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
