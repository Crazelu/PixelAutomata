import 'dart:ui';

class PixelInfo {
  PixelInfo({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });

  factory PixelInfo.fromMap(Map data) {
    return PixelInfo(
      x: data["x"],
      y: data["y"],
      size: data["size"],
      color: Color(data["color"]),
    );
  }

  final num x;
  final num y;
  final num size;
  final Color color;

  PixelInfo copyWith({num? x, num? y, Color? color}) {
    return PixelInfo(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size,
      color: color ?? this.color,
    );
  }

  void drawPixelOn(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        size.toDouble(),
        size.toDouble(),
      ),
      Paint()..color = color,
    );
  }

  Map<String, dynamic> toMap() => {
        "x": x,
        "y": y,
        "size": size,
        "color": color.value,
      };
}
