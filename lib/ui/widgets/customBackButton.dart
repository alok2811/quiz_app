import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final bool? removeSnackBars;
  final Color? iconColor;
  final Function? onTap;

  const CustomBackButton(
      {Key? key, this.removeSnackBars, this.iconColor, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: this.onTap == null
            ? () {
                Navigator.pop(context);
                if (removeSnackBars != null && removeSnackBars!) {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                }
              }
            : () {
                onTap?.call();
              },
        child: Container(
            padding: EdgeInsets.all(8.0),
            decoration:
                BoxDecoration(border: Border.all(color: Colors.transparent)),
            child: Icon(
              Icons.arrow_back_ios,
              size: 22.5,
              color: iconColor ?? Theme.of(context).primaryColor,
            )));
  }
}
