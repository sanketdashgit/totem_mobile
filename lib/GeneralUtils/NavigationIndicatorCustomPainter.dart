import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class NavigationIndicatorCustomPainter extends CustomPainter {

  Color color;

  NavigationIndicatorCustomPainter(Color color){
    this.color = color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 15;

    var path = Path();
    path.moveTo(0, 7); // Start
    path.quadraticBezierTo(size.width * 0.008, 0, size.width * 0.18, 0);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width * 0.82, 0);
    path.quadraticBezierTo(size.width * 0.99, 0, size.width, 7);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 7);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
