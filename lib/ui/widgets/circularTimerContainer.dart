import 'dart:math';

import 'package:flutter/material.dart';

class CircularTimerContainer extends StatelessWidget {
  final double heightAndWidth;

  final AnimationController timerAnimationController;
  CircularTimerContainer({Key? key, required this.timerAnimationController, required this.heightAndWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: heightAndWidth,
          width: heightAndWidth,
          child: CustomPaint(
            painter: CircleCustomPainter(
              color: Theme.of(context).backgroundColor,
              radiusPercentage: 0.5,
              strokeWidth: 3,
            ),
          ),
        ),
        Container(
          height: heightAndWidth,
          width: heightAndWidth,
          child: AnimatedBuilder(
              builder: (context, _) {
                return CustomPaint(
                  painter: ArcCustomPainter(
                    sweepAngle: 360 * timerAnimationController.value,
                    color: Theme.of(context).primaryColor,
                    radiusPercentage: 0.5,
                    strokeWidth: 3,
                  ),
                );
              },
              animation: timerAnimationController),
        ),
      ],
    );
  }
}

class CircleCustomPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radiusPercentage;
  CircleCustomPainter({required this.color, required this.radiusPercentage, required this.strokeWidth});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * (0.5), size.height * (0.5));
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, size.width * radiusPercentage, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //generally it return false but when parent widget is changing
    //or animating it should return true
    return false;
  }
}

class ArcCustomPainter extends CustomPainter {
  final double sweepAngle;
  final Color color;
  final double radiusPercentage;
  final double strokeWidth;

  ArcCustomPainter({required this.sweepAngle, required this.color, required this.radiusPercentage, required this.strokeWidth});

  double _degreeToRadian() {
    return (sweepAngle * pi) / 180.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(Rect.fromCircle(center: Offset(size.width * (0.5), size.height * (0.5)), radius: size.width * radiusPercentage), 3 * (pi / 2), _degreeToRadian(), false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
