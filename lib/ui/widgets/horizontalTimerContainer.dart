import 'package:flutter/material.dart';
import 'package:ayuprep/ui/styles/colors.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class HorizontalTimerContainer extends StatelessWidget {
  final AnimationController timerAnimationController;

  HorizontalTimerContainer({Key? key, required this.timerAnimationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          alignment: Alignment.topRight,
          height: 10.0,
          width: MediaQuery.of(context).size.width *
              (UiUtils.quesitonContainerWidthPercentage - 0.1),
        ),
        AnimatedBuilder(
          animation: timerAnimationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                  color: timerAnimationController.value >= 0.8
                      ? hurryUpTimerColor
                      : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              alignment: Alignment.topRight,
              height: 10.0,
              width: MediaQuery.of(context).size.width *
                  (UiUtils.quesitonContainerWidthPercentage - 0.1) *
                  (1.0 - timerAnimationController.value),
            );
          },
        ),
      ],
    );
  }
}
