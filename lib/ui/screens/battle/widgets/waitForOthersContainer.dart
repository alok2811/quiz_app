import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/ui/screens/battle/widgets/rectangleUserProfileContainer.dart';
import 'package:ayuprep/ui/widgets/questionBackgroundCard.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class WaitForOthersContainer extends StatelessWidget {
  const WaitForOthersContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            MediaQuery.of(context).size.height *
                RectangleUserProfileContainer.userDetailsHeightPercentage *
                2.75,
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          QuestionBackgroundCard(
              heightPercentage:
                  UiUtils.questionContainerHeightPercentage - 0.045,
              opacity: 0.7,
              topMarginPercentage: 0.05,
              widthPercentage: 0.65),
          QuestionBackgroundCard(
              heightPercentage:
                  UiUtils.questionContainerHeightPercentage - 0.045,
              opacity: 0.85,
              topMarginPercentage: 0.03,
              widthPercentage: 0.75),
          Container(
            child: Center(
              child: Text(AppLocalization.of(context)!
                  .getTranslatedValues('waitOtherComplete')!),
            ),
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            width: MediaQuery.of(context).size.width * (0.85),
            height: MediaQuery.of(context).size.height *
                UiUtils.questionContainerHeightPercentage,
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(25)),
          )
        ],
      ),
    );
  }
}
