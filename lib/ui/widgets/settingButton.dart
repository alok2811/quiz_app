import 'package:flutter/material.dart';

class SettingButton extends StatelessWidget {
  final Function onPressed;
  final Color? iconColor;
  const SettingButton({Key? key, required this.onPressed, this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.transparent,
            ),
          ),
          child: Icon(
            Icons.settings,
            size: 22.5,
            color: iconColor ?? Theme.of(context).backgroundColor,
          )),
      onTap: () {
        onPressed();
      },
    );
  }
}
