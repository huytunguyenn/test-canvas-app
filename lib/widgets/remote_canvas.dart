import 'dart:convert';

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
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.scene.onRepaint = _repaint;
  }

  @override
  void didUpdateWidget(covariant RemoteCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene != widget.scene) {
      oldWidget.scene.onRepaint = null;
      widget.scene.onRepaint = _repaint;
      _textController.clear();
      _focusNode.unfocus();
    }
  }

  void _repaint() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) {
    final scene = widget.scene;
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    if (size == null) return;

    scene.layout(size);
    scene.layoutDebugButton(size);

    // Check debug button first
    if (scene.handleDebugTap(details.localPosition)) {
      setState(() {});
      return;
    }

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
    final showGT = widget.scene.showGroundTruth;

    return Column(
      children: [
        Expanded(
          flex: showGT ? 1 : 1,
          child: Stack(
            key: _canvasKey,
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
          ),
        ),
        if (showGT) _buildGroundTruthPanel(),
      ],
    );
  }

  Widget _buildGroundTruthPanel() {
    final json = const JsonEncoder.withIndent('  ')
        .convert(widget.scene.exportGroundTruth());

    return Container(
      height: 260,
      decoration: const BoxDecoration(
        color: Color(0xF01E1E1E),
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D2D),
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                const Text(
                  'Ground Truth',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.scene.elements.length} elements',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                json,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final Scene scene;

  _ScenePainter(this.scene);

  @override
  void paint(Canvas canvas, Size size) {
    scene.layout(size);
    scene.layoutDebugButton(size);
    scene.paint(canvas, size);
    scene.paintDebugOverlay(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
