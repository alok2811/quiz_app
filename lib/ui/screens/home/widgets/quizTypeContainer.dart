import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class QuizTypeContainer extends StatelessWidget {
  final double heightPercentage;
  final double widthPercentage;
  final QuizType quizType;
  const QuizTypeContainer({Key? key, required this.quizType, required this.heightPercentage, required this.widthPercentage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * widthPercentage;
    final double height = MediaQuery.of(context).size.height * heightPercentage;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: width, height: height * 0.25, child: SvgPicture.asset(quizType.image)),
          SizedBox(
            height: 5.0,
          ),
          Text(
            AppLocalization.of(context)!.getTranslatedValues(quizType.title)!,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.125,
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            height: 4.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues(quizType.description)!,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                letterSpacing: -0.25,
                height: 1.1,
                fontSize: 12.5,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        boxShadow: [UiUtils.buildBoxShadow(offset: Offset(5, 5), blurRadius: 10)],
        borderRadius: BorderRadius.circular(20.0),
        color: Theme.of(context).backgroundColor,
      ),
      width: width,
      height: height,
    );
  }
}
