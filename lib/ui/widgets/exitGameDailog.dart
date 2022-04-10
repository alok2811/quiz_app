import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/ui/styles/colors.dart';

class ExitGameDailog extends StatelessWidget {
  final Function? onTapYes;
  const ExitGameDailog({Key? key, this.onTapYes}) : super(key: key);

  void onPressed(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        backgroundColor: Theme.of(context).backgroundColor,
        content: Text(
          AppLocalization.of(context)!.getTranslatedValues("quizExitLbl")!,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        actions: [
          CupertinoButton(
              child: Text(
                AppLocalization.of(context)!.getTranslatedValues("yesBtn")!,
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
              onPressed: () {
                if (onTapYes != null) {
                  onTapYes!();
                } else {
                  Navigator.of(context).pop();

                  Navigator.of(context).pop();
                }
              }),
          CupertinoButton(
              child: Text(AppLocalization.of(context)!.getTranslatedValues("noBtn")!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }
}
