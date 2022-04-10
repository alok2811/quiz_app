import 'package:flutter/material.dart';

class QuizPlayAreaBackgroundContainer extends StatelessWidget {
  final double? heightPercentage;
  QuizPlayAreaBackgroundContainer({Key? key, this.heightPercentage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * (heightPercentage ?? 0.885),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius:
            BorderRadiusDirectional.only(bottomEnd: Radius.circular(100)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
    );
  }
}
