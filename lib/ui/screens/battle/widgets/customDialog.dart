import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class CustomDialog extends StatelessWidget {
  final double? height; //in multiplication of device height
  final Widget child;
  final Function? onBackButtonPress;
  final Function? onWillPop;
  final double? topPadding;
  CustomDialog(
      {Key? key,
      this.height,
      required this.child,
      this.topPadding,
      this.onBackButtonPress,
      this.onWillPop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop == null
          ? () {
              return Future.value(true);
            }
          : onWillPop as Future<bool> Function()?,
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: UiUtils.dailogBlurSigma, sigmaY: UiUtils.dailogBlurSigma),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * (0.075),
                      top: 20.0,
                    ),
                    child: IconButton(
                        onPressed: onBackButtonPress == null
                            ? () {
                                Navigator.of(context).pop();
                              }
                            : onBackButtonPress as void Function()?,
                        iconSize: 40.0,
                        icon: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).primaryColor,
                        ))),
                SizedBox(
                  height:
                      topPadding ?? MediaQuery.of(context).size.height * (0.02),
                ),
                Center(
                  child: Container(
                    child: child,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(UiUtils.dailogRadius)),
                    height: height ??
                        MediaQuery.of(context).size.height *
                            UiUtils.dailogHeightPercentage,
                    width: MediaQuery.of(context).size.width *
                        UiUtils.dailogWidthPercentage,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
