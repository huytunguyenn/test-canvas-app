import 'dart:ui';

enum ElementType { button, textField, label, checkbox, card }

class CanvasElement {
  final String id;
  final ElementType type;
  Rect bounds;
  String label;
  String value;
  bool enabled;
  bool checked;
  bool focused;

  CanvasElement({
    required this.id,
    required this.type,
    this.bounds = Rect.zero,
    this.label = '',
    this.value = '',
    this.enabled = true,
    this.checked = false,
    this.focused = false,
  });

  bool hitTest(Offset point) => bounds.contains(point);

  Map<String, dynamic> toGroundTruth() => {
        'id': id,
        'type': type.name,
        'bounds': {
          'left': bounds.left,
          'top': bounds.top,
          'width': bounds.width,
          'height': bounds.height,
        },
        'label': label,
        'value': value,
        'enabled': enabled,
        'checked': checked,
        'focused': focused,
      };
}
