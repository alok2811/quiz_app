import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/quiz/models/comprehension.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/ui/widgets/horizontalTimerContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/stringLabels.dart';

class FunAndLearnScreen extends StatefulWidget {
  final QuizTypes quizType;
  final Comprehension comprehension;

  const FunAndLearnScreen(
      {Key? key, required this.quizType, required this.comprehension})
      : super(key: key);
  @override
  _FunAndLearnScreen createState() => _FunAndLearnScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
        builder: (_) => FunAndLearnScreen(
              quizType: arguments!['quizType'] as QuizTypes,
              comprehension: arguments['comprehension'],
            ));
  }
}

class _FunAndLearnScreen extends State<FunAndLearnScreen>
    with TickerProviderStateMixin {
  final double topPartHeightPrecentage = 0.275;
  final double userDetailsHeightPrecentage = 0.115;
  late AnimationController timerAnimationController;

  @override
  void initState() {
    timerAnimationController = AnimationController(
        vsync: this,
        duration:
            Duration(seconds: comprehensionParagraphReadingTimeInSeconds));
    timerAnimationController
        .forward()
        .then((value) => navigateToQuestionScreen()); //navigateTo
    super.initState();
  }

  @override
  void dispose() {
    timerAnimationController.dispose();
    super.dispose();
  }

  void navigateToQuestionScreen() {
    Navigator.of(context).pushReplacementNamed(Routes.quiz, arguments: {
      "numberOfPlayer": 1,
      "quizType": QuizTypes.funAndLearn,
      "comprehension": widget.comprehension,
      "quizName": "Fun 'N'Learn",
    });
  }

  Widget _buildStartButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 20.0,
          left: MediaQuery.of(context).size.width * (0.075),
          right: MediaQuery.of(context).size.width * (0.075),
        ),
        child: CustomRoundedButton(
          widthPercentage: MediaQuery.of(context).size.width * (0.85),
          backgroundColor: Theme.of(context).primaryColor,
          buttonTitle:
              AppLocalization.of(context)!.getTranslatedValues(letsStart)!,
          radius: 5,
          onTap: () {
            timerAnimationController.stop();
            navigateToQuestionScreen();
          },
          titleColor: Theme.of(context).backgroundColor,
          showBorder: false,
          height: 40.0,
          elevation: 5.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
          margin: EdgeInsetsDirectional.only(
            start: 20,
            end: 20,
            top: 40.0,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80),
            child: Html(data: widget.comprehension.detail),
          )),
    );
  }

  Widget _buildTimerAndBackButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomBackButton(),
          Spacer(),
          Transform.translate(
            offset: Offset(-8.0, 0),
            child: HorizontalTimerContainer(
                timerAnimationController: timerAnimationController),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: [
          PageBackgroundGradientContainer(),
          _buildTimerAndBackButton(),
          _buildParagraph(),
          _buildStartButton(),
        ],
      ),
    ));
  }
}
