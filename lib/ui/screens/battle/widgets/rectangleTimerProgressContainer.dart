import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ayuprep/ui/screens/battle/widgets/rectangleUserProfileContainer.dart';

class RectangleTimerProgressContainer extends StatefulWidget {
  final AnimationController animationController;
  final Color color;
  RectangleTimerProgressContainer(
      {Key? key, required this.animationController, required this.color})
      : super(key: key);

  @override
  _RectangleTimerProgressContainerState createState() =>
      _RectangleTimerProgressContainerState();
}

class _RectangleTimerProgressContainerState
    extends State<RectangleTimerProgressContainer> {
  late Animation<double> _animation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: widget.animationController,
    curve: Interval(0.0, 0.2),
  ));

  late Animation<double> _firstCurveAnimation =
      Tween<double>(begin: 0.0, end: 90.0).animate(CurvedAnimation(
    parent: widget.animationController,
    curve: Interval(0.2, 0.25),
  ));

  late Animation<double> _secondPointAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: widget.animationController,
    curve: Interval(0.25, 0.45),
  ));
  late Animation<double> _secondCurveAnimation =
      Tween<double>(begin: 0.0, end: 90.0).animate(CurvedAnimation(
    parent: widget.animationController,
    curve: Interval(0.45, 0.5),
  ));
  late Animation<double> _thirdAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: widget.animationController,
    curve: Interval(0.5, 0.7),
  ));
  late Animation<double> _thirdCurveAnimation =
      Tween<double>(begin: 0.0, end: 90.0).animate(CurvedAnimation(
    parent: widget.animationController,
    curve: Interval(0.7, 0.75),
  ));
  late Animation<double> _fourthPointAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: widget.animationController,
    curve: Interval(0.75, 0.95),
  ));
  late Animation<double> _fourhtCurveAnimation =
      Tween<double>(begin: 0.0, end: 90.0).animate(CurvedAnimation(
    parent: widget.animationController,
    curve: Interval(0.95, 1.0),
  ));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return CustomPaint(
          child: Container(
            width: MediaQuery.of(context).size.width *
                RectangleUserProfileContainer.userDetailsWidthPercentage,
            height: MediaQuery.of(context).size.height *
                RectangleUserProfileContainer.userDetailsHeightPercentage,
          ),
          painter: RectanglePainter(
            color: widget.color,
            paintingStyle: PaintingStyle.stroke,
            points: [
              _animation.value,
              _firstCurveAnimation.value,
              _secondPointAnimation.value,
              _secondCurveAnimation.value,
              _thirdAnimation.value,
              _thirdCurveAnimation.value,
              _fourthPointAnimation.value,
              _fourhtCurveAnimation.value,
            ],
            animationControllerValue: widget.animationController.value,
            curveRadius: 10,
          ),
        );
      },
    );
  }
}
