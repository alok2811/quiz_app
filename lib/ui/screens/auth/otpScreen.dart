import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';

import 'package:ayuprep/features/auth/authRepository.dart';
import 'package:ayuprep/features/auth/cubits/authCubit.dart';
import 'package:ayuprep/features/auth/cubits/signInCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/ui/screens/auth/widgets/resendOtpTimerContainer.dart';
import 'package:ayuprep/ui/screens/auth/widgets/termsAndCondition.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

const int otpTimeOutSeconds = 60;

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreen createState() => _OtpScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<SignInCubit>(
              child: OtpScreen(),
              create: (_) => SignInCubit(AuthRepository()),
            ));
  }
}

class _OtpScreen extends State<OtpScreen> {
  TextEditingController phoneNumberController = TextEditingController();

  CountryCode? selectedCountrycode;
  final TextEditingController smsCodeEditingController =
      TextEditingController();

  final GlobalKey<ResendOtpTimerContainerState> resendOtpTimerContainerKey =
      GlobalKey<ResendOtpTimerContainerState>();

  bool codeSent = false;
  bool hasError = false;
  String errorMessage = "";
  bool isLoading = false;
  String userVerificationId = "";

  bool enableResendOtpButton = false;

  void signInWithPhoneNumber({required String phoneNumber}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(seconds: otpTimeOutSeconds),
      phoneNumber: '${selectedCountrycode!.dialCode} $phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) {
        print("Phone number verified");
      },
      verificationFailed: (FirebaseAuthException e) {
        //if otp code does not verify
        print("Firebase Auth error------------");
        print(e.message);
        print("---------------------");
        UiUtils.setSnackbar(
            AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(defaultErrorMessageCode))!,
            context,
            false);

        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        print("Code sent successfully");
        setState(() {
          codeSent = true;
          userVerificationId = verificationId;
          isLoading = false;
        });

        Future.delayed(Duration(milliseconds: 75)).then((value) {
          resendOtpTimerContainerKey.currentState?.setResendOtpTimer();
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Widget _buildOTPSentToPhoneNumber() {
    if (codeSent) {
      return Column(
        children: [
          //
          Text(
            AppLocalization.of(context)!.getTranslatedValues(otpSendLbl)!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16.0,
            ),
          ),
          Text(
            '${selectedCountrycode!.dialCode} ${phoneNumberController.text.trim()}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16.0,
            ),
          ),
        ],
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (isLoading) {
          print("Is loading is true");
          return Future.value(false);
        }
        if (context.read<SignInCubit>().state is SignInProgress) {
          return Future.value(false);
        }

        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            PageBackgroundGradientContainer(),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * (0.075)),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .07,
                    ),
                    _buildClockAnimation(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.1),
                    ),
                    _buildOTPSentToPhoneNumber(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.04),
                    ),
                    codeSent
                        ? _buildSmsCodeContainer()
                        : _buildMobileNumberWithCountryCode(),
                    codeSent
                        ? _buildSubmitOtpContainer()
                        : _buildRequestOtpContainer(),
                    codeSent ? _buildResendText() : Container(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.025),
                    ),
                    TermsAndCondition(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget otpLabelIos() {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: CustomBackButton(
              iconColor: Theme.of(context).primaryColor,
            )),
        Expanded(
          flex: 10,
          child: Text(
            AppLocalization.of(context)!
                .getTranslatedValues('otpVerificationLbl')!,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget otpLabel() {
    return Text(
      AppLocalization.of(context)!.getTranslatedValues('otpVerificationLbl')!,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _buildClockAnimation() {
    return Container(
      transformAlignment: Alignment.topCenter,
      child: Lottie.asset("assets/animations/login.json",
          height: MediaQuery.of(context).size.height * .25,
          width: MediaQuery.of(context).size.width * 3),
    );
  }

  Widget _buildMobileNumberWithCountryCode() {
    final border = UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
      ),
    );
    return Row(
      children: [
        IgnorePointer(
          ignoring: isLoading,
          child: CountryCodePicker(
            onInit: (countryCode) {
              selectedCountrycode = countryCode;
            },
            onChanged: (countryCode) {
              selectedCountrycode = countryCode;
            },
            initialSelection: initialCountryCode,
            showCountryOnly: false,
            alignLeft: false,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Flexible(
          child: TextField(
            controller: phoneNumberController,
            keyboardType: TextInputType.number,
            cursorColor: Theme.of(context).primaryColor,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
            decoration: InputDecoration(
              border: border,
              enabledBorder: border,
              errorBorder: border,
              focusedBorder: border,
              focusedErrorBorder: border,
              isDense: true,
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.6)),
              hintText: "+91 999-999-999",
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSmsCodeContainer() {
    return PinCodeTextField(
      onChanged: (value) {},
      keyboardType: TextInputType.number,
      appContext: context,
      length: 6,
      obscureText: false,
      textStyle: TextStyle(
        color: Theme.of(context).primaryColor,
      ),
      pinTheme: PinTheme(
        selectedFillColor: Theme.of(context).colorScheme.secondary,
        inactiveColor: Theme.of(context).backgroundColor,
        activeColor: Theme.of(context).backgroundColor,
        inactiveFillColor: Theme.of(context).backgroundColor,
        selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 50,
        fieldWidth: 40,
        activeFillColor: Theme.of(context).backgroundColor,
      ),
      cursorColor: Theme.of(context).backgroundColor,
      animationDuration: Duration(milliseconds: 300),
      //backgroundColor:  Theme.of(context).backgroundColor,
      enableActiveFill: true,
      controller: smsCodeEditingController,
    );
  }

  Widget _buildSubmitOtpContainer() {
    return BlocConsumer<SignInCubit, SignInState>(
      bloc: context.read<SignInCubit>(),
      builder: (context, state) {
        if (state is SignInProgress) {
          return CircularProgressContainer(
            useWhiteLoader: false,
            heightAndWidth: 50.0,
          );
        }

        return Container(
          padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * (0.07),
              left: MediaQuery.of(context).size.width * (0.07),
              top: MediaQuery.of(context).size.width * (0.04)),
          width: MediaQuery.of(context).size.width,
          child: CupertinoButton(
            borderRadius: BorderRadius.circular(15),
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues(submitBtn)!,
              style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              if (smsCodeEditingController.text.trim().length == 6) {
                //
                context.read<SignInCubit>().signInUser(
                      AuthProvider.mobile,
                      smsCode: smsCodeEditingController.text.trim(),
                      verificationId: userVerificationId,
                    );
              }
            },
          ),
        );
      },
      listener: (context, state) {
        if (state is SignInSuccess) {
          //update auth details
          context.read<AuthCubit>().updateAuthDetails(
              authProvider: AuthProvider.mobile,
              authStatus: true,
              firebaseId: state.user.uid,
              isNewUser: state.isNewUser);

          if (state.isNewUser) {
            context.read<UserDetailsCubit>().fetchUserDetails(state.user.uid);
            Navigator.of(context).pop();
            Navigator.of(context)
                .pushReplacementNamed(Routes.selectProfile, arguments: true);
          } else {
            context.read<UserDetailsCubit>().fetchUserDetails(state.user.uid);
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(Routes.home);
          }
        } else if (state is SignInFailure) {
          UiUtils.setSnackbar(
              AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage))!,
              context,
              false);
        }
      },
    );
  }

  Widget _buildRequestOtpContainer() {
    if (isLoading) {
      return CircularProgressContainer(
        useWhiteLoader: false,
        heightAndWidth: 50.0,
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .07,
          vertical: MediaQuery.of(context).size.height * .04),
      width: MediaQuery.of(context).size.width,
      child: CupertinoButton(
        borderRadius: BorderRadius.circular(15),
        child: Text(
          AppLocalization.of(context)!.getTranslatedValues("requestOtpLbl")!,
          style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: () async {
          if (phoneNumberController.text.trim().length < 6) {
            UiUtils.setSnackbar(
                AppLocalization.of(context)!.getTranslatedValues(validMobMsg)!,
                context,
                false);
          } else {
            setState(() {
              isLoading = true;
            });
            signInWithPhoneNumber(
                phoneNumber: phoneNumberController.text.trim());
          }
        },
      ),
    );
  }

  Widget _buildResendText() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ResendOtpTimerContainer(
              key: resendOtpTimerContainerKey,
              enableResendOtpButton: () {
                setState(() {
                  enableResendOtpButton = true;
                });
              }),
          TextButton(
            onPressed: enableResendOtpButton
                ? () async {
                    print("Resend otp ");
                    setState(() {
                      isLoading = false;
                      enableResendOtpButton = false;
                    });
                    resendOtpTimerContainerKey.currentState?.cancelOtpTimer();
                    signInWithPhoneNumber(
                        phoneNumber: phoneNumberController.text.trim());
                  }
                : null,
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues("resendBtn")!,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
