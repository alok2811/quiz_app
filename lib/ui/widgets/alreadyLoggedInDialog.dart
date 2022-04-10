import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class AlreadyLoggedInDialog extends StatelessWidget {
  final Function? onAlreadyLoggedInCallBack;
  const AlreadyLoggedInDialog({Key? key, this.onAlreadyLoggedInCallBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * (0.5),
            height: MediaQuery.of(context).size.width * (0.5),
            child: SvgPicture.asset(
              UiUtils.getImagePath("already_login.svg"),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Text(
            "Already logged in other device",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          SizedBox(
            height: 15.0,
          ),
          GestureDetector(
            onTap: () {
              onAlreadyLoggedInCallBack?.call();
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacementNamed(Routes.login);
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: Theme.of(context).primaryColor)),
              height: 40.0,
              child: Text(
                AppLocalization.of(context)!.getTranslatedValues(okayLbl)!,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}
