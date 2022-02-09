import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';


class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = bottomNavigationBGColor
      ..strokeWidth = 15;

    var path = Path();
    path.moveTo(0, 25); // Start
    path.quadraticBezierTo(size.width * 0.008, 0, size.width * 0.08, 0);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.43, 20);
    // path.arcToPoint(Offset(size.width * 0.59, 4),
    //     radius: Radius.circular(9), clockwise: false);
    path.quadraticBezierTo(size.width * 0.50, 45, size.width *  0.57, 20);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width * 0.92, 0);
    path.quadraticBezierTo(size.width * 0.99, 0, size.width, 25);
    path.lineTo(size.width, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.99, size.height, size.width * 0.92, size.height);
    path.lineTo(size.width * 0.08, size.height);
    path.quadraticBezierTo(
        size.width * 0.008, size.height, 0, size.height * 0.70);
    path.lineTo(0, 20);
    // canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
