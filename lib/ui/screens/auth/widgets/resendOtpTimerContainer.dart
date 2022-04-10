import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/ui/screens/auth/otpScreen.dart';

class ResendOtpTimerContainer extends StatefulWidget {
  final Function enableResendOtpButton;
  ResendOtpTimerContainer({Key? key, required this.enableResendOtpButton}) : super(key: key);

  @override
  ResendOtpTimerContainerState createState() => ResendOtpTimerContainerState();
}

class ResendOtpTimerContainerState extends State<ResendOtpTimerContainer> {
  Timer? resendOtpTimer;
  int resendOtpTimeInSeconds = otpTimeOutSeconds - 1;

  //
  void setResendOtpTimer() {
    print("Start resend otp timer");
    print("------------------------------------");
    setState(() {
      resendOtpTimeInSeconds = otpTimeOutSeconds - 1;
    });
    resendOtpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendOtpTimeInSeconds == 0) {
        timer.cancel();
        widget.enableResendOtpButton();
      } else {
        resendOtpTimeInSeconds--;
        setState(() {});
      }
    });
  }

  void cancelOtpTimer() {
    resendOtpTimer?.cancel();
  }

  @override
  void dispose() {
    cancelOtpTimer();
    super.dispose();
  }

//to get time to display in text widget
  String getTime() {
    String secondsAsString = resendOtpTimeInSeconds < 10 ? " 0$resendOtpTimeInSeconds" : resendOtpTimeInSeconds.toString();
    return " $secondsAsString";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalization.of(context)!.getTranslatedValues('resetLbl')! + getTime(),
      style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.normal),
    );
  }
}
