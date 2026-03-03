import 'package:flutter/material.dart';
class DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5;
    const dashSpace = 3;
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Color(0XFF84B8FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double startAngle = 0;
    final circumference = 2 * 3.1416 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        dashWidth / radius,
        false,
        paint,
      );
      startAngle += (dashWidth + dashSpace) / radius;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}