import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ayuprep/features/badges/badge.dart';
import 'package:ayuprep/ui/styles/colors.dart';

class BadgesIconContainer extends StatelessWidget {
  final Badge badge;
  final BoxConstraints constraints;
  final bool addTopPadding;

  BadgesIconContainer({Key? key, required this.badge, required this.constraints, required this.addTopPadding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight * (addTopPadding ? 0.085 : 0),
            ),
            child: CustomPaint(
              painter: HexagonCustomPainter(color: badge.status == "0" ? badgeLockedColor : Theme.of(context).primaryColor, paintingStyle: PaintingStyle.fill),
              child: Container(
                width: constraints.maxWidth * (0.875),
                height: constraints.maxHeight * (0.6), //65
              ),
            ),
          ),
        ),
        Align(
          alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight * (addTopPadding ? 0.135 : 0), //outer hexagon top padding + differnce of inner and outer height
            ),
            child: CustomPaint(
              painter: HexagonCustomPainter(color: Theme.of(context).backgroundColor, paintingStyle: PaintingStyle.stroke), //
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(12.5),
                  child: CachedNetworkImage(imageUrl: badge.badgeIcon),
                ),
                width: constraints.maxWidth * (0.725),
                height: constraints.maxHeight * (0.5), //55
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HexagonCustomPainter extends CustomPainter {
  final Color color;
  final PaintingStyle paintingStyle;
  HexagonCustomPainter({required this.color, required this.paintingStyle});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = paintingStyle;

    if (paintingStyle == PaintingStyle.stroke) {
      paint.strokeWidth = 2.5;
    }
    Path path = Path();
    path.moveTo(size.width * (0.5), 0);
    path.lineTo(size.width, size.height * (0.25));
    path.lineTo(size.width, size.height * (0.75));
    path.lineTo(size.width * (0.5), size.height);
    path.lineTo(0, size.height * (0.75));
    path.lineTo(0, size.height * (0.25));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
