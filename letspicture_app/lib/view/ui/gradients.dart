import 'dart:math' as math;

import 'package:flutter/material.dart';

const Gradient mainGradient = LinearGradient(colors: [
  Color(0xFFF27300),
  Color(0xFFDE005C),
  Color(0xFFF27300),
  Color(0xFFDE005C),
], stops: [
  0.0,
  0.333,
  0.666,
  1.0
]);

const Gradient negativeActionGradient = LinearGradient(
  colors: [
    Color(0xFFA70239),
    Color(0xFFF07F1C),
  ],
  stops: [0.0, 1.0],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Gradient positiveActionGradient = LinearGradient(
  colors: [
    Color(0xFF09729F),
    Color(0xFF1CF043),
  ],
  stops: [0.0, 1.0],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Gradient creatingGradient = LinearGradient(colors: [
  Color(0xFFF27300),
  Color(0xFFDE005C),
], stops: [
  0.0,
  1.0
]);

const Gradient sweepGradient = SweepGradient(colors: [
  Color(0xFFF27300),
  Color(0xFFDE005C),
  Color(0xFFF27300),
]);

class HorizontalGradientPainter extends CustomPainter {
  const HorizontalGradientPainter(this.offset, this.width) : super();

  final double offset;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final double height = size.height;

    final double finalOffset = offset * width * 2;

    final Rect rect = Rect.fromLTWH(-finalOffset, 0.0, width * 6, height);

    final Paint paint = Paint()..shader = mainGradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(HorizontalGradientPainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}

class BorderGradientPainter extends CustomPainter {
  final double angle;
  final double borderWidth;
  final Color color;

  const BorderGradientPainter({this.angle, this.borderWidth, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double height = size.height;
    final double width = size.width;

    final double zoomFactor = math.pi;

    final double finalWidth = width * zoomFactor;
    final double finalHeight = height * zoomFactor;

    final double x = (finalWidth - width) / 2;
    final double y = (finalHeight - height) / 2;

    final double translateX = width / 2;
    final double translateY = height / 2;

    final Rect rect = Rect.fromLTWH(
        -(x + translateX), -(y + translateY), finalWidth, finalHeight);

    final Paint paint = Paint()..shader = sweepGradient.createShader(rect);

    canvas.save();
    canvas.translate(translateX, translateY);
    canvas.rotate(angle);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(BorderGradientPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.color != color;
  }
}

/// Bottom gradients for bottom menu on edition screen
class MenuGradientPainter extends CustomPainter {
  const MenuGradientPainter(
      {this.center = const Alignment(0.0, -1.0),
      this.fadeLength,
      this.radiusMultiplier})
      : super();

  final Alignment center;
  final double fadeLength;
  final double radiusMultiplier;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final double firstStop = 1 - (fadeLength / height);

    final radius = height / width;

    final Rect rect = Rect.fromLTWH(0.0, 0.0, width, height);

    final Gradient gradient = RadialGradient(
      colors: <Color>[
        Colors.black.withOpacity(0.0),
        Colors.black.withOpacity(1.0),
      ],
      stops: [
        firstStop,
        1.0,
      ],
      radius: radius * radiusMultiplier,
      center: center,
    );

    final Paint paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(MenuGradientPainter oldDelegate) {
    return true; //this != oldDelegate;
  }
}
