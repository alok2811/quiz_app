import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class AppUnderMaintenanceDialog extends StatelessWidget {
  const AppUnderMaintenanceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.275),
              width: MediaQuery.of(context).size.width * (0.8),
              child: SvgPicture.asset(
                  UiUtils.getImagePath("undermaintenance.svg")),
            ),
            Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(appUnderMaintenanceKey)!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColor),
            )
          ],
        ),
      ),
    );
  }
}
