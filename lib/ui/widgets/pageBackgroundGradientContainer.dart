import 'package:flutter/material.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class PageBackgroundGradientContainer extends StatelessWidget {
  const PageBackgroundGradientContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter),
      ),
    );
  }
}
