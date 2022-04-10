import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/settings/settingsCubit.dart';
import 'package:ayuprep/ui/styles/colors.dart';

class FontSizeDialog extends StatefulWidget {
  final SettingsCubit bloc;
  FontSizeDialog({required this.bloc});
  @override
  _FontSizeDialog createState() => _FontSizeDialog();
}

class _FontSizeDialog extends State<FontSizeDialog> {
  double textSize = 14;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        child: AlertDialog(
      backgroundColor: pageBackgroundColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 70, vertical: 300),
      title: Center(
        child: Text(
          AppLocalization.of(context)!.getTranslatedValues("fontSizeLbl")!,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      content: StatefulBuilder(
          builder: (context, state) => FittedBox(
                child: Slider(
                  label: (textSize).toStringAsFixed(0),
                  value: textSize,
                  activeColor: primaryColor,
                  inactiveColor: primaryColor,
                  min: 14,
                  max: 25,
                  divisions: 10,
                  onChanged: (value) {
                    state(() {
                      textSize = value;
                      widget.bloc.changeFontSize(textSize);
                      print(textSize);
                    });
                  },
                ),
              )),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 20,
            primary: primaryColor,
            shadowColor: backgroundColor.withOpacity(0.8),
            side: BorderSide(width: 1.0, color: primaryColor),
            minimumSize: Size(100, 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          onPressed: () {
            widget.bloc.changeFontSize(textSize);
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues("okayLbl")!,
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
            ),
          ),
        )
      ],
    ));
  }
}
