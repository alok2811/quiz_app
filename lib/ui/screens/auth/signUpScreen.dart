import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/auth/authRepository.dart';
import 'package:ayuprep/features/auth/cubits/authCubit.dart';
import 'package:ayuprep/features/auth/cubits/signUpCubit.dart';
import 'package:ayuprep/ui/screens/auth/widgets/termsAndCondition.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:ayuprep/utils/validators.dart';
import 'package:lottie/lottie.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true, _obscureTextCn = true, isLoading = false;
  TextEditingController edtEmail = TextEditingController();
  TextEditingController edtPwd = TextEditingController();
  TextEditingController edtCPwd = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpCubit>(
      create: (_) => SignUpCubit(AuthRepository()),
      child: Builder(
          builder: (context) => Scaffold(
                body: Stack(
                  children: [
                    PageBackgroundGradientContainer(),
                    SingleChildScrollView(
                      child: form(),
                    ),
                  ],
                ),
              )),
    );
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: MediaQuery.of(context).size.width * .08, end: MediaQuery.of(context).size.width * .08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .07,
            ),
            signUpText(),
            SizedBox(
              height: MediaQuery.of(context).size.height * .05,
            ),
            showTopImage(),
            SizedBox(
              height: MediaQuery.of(context).size.height * .05,
            ),
            showEmail(),
            SizedBox(
              height: MediaQuery.of(context).size.height * .02,
            ),
            showPassword(),
            SizedBox(
              height: MediaQuery.of(context).size.height * .02,
            ),
            showCnfPassword(),
            SizedBox(
              height: MediaQuery.of(context).size.height * .02,
            ),
            showSignup(),
            showGoSignIn(),
            TermsAndCondition(),
          ],
        ),
      ),
    );
  }

  Widget signUpText() {
    return Text(
      AppLocalization.of(context)!.getTranslatedValues("signUpLbl")!,
      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget showTopImage() {
    return Container(
      transformAlignment: Alignment.topCenter,
      child: Lottie.asset("assets/animations/login.json", height: MediaQuery.of(context).size.height * .25, width: MediaQuery.of(context).size.width * 3),
    );
  }

  Widget showEmail() {
    return TextFormField(
      controller: edtEmail,
      keyboardType: TextInputType.emailAddress,
      validator: (val) => Validators.validateEmail(val!, AppLocalization.of(context)!.getTranslatedValues('emailRequiredMsg')!, AppLocalization.of(context)!.getTranslatedValues('VALID_EMAIL')),
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      decoration: InputDecoration(
        fillColor: Theme.of(context).backgroundColor,
        filled: true,
        border: InputBorder.none,
        hintText: AppLocalization.of(context)!.getTranslatedValues('emailLbl')! + "*",
        contentPadding: EdgeInsets.all(15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: new BorderSide(
            color: Theme.of(context).backgroundColor,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: new BorderSide(
            color: Theme.of(context).backgroundColor,
          ),
        ),
      ),
    );
  }

  Widget showPassword() {
    return TextFormField(
      controller: edtPwd,
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      obscureText: _obscureText,
      obscuringCharacter: "*",
      validator: (val) => val!.isEmpty ? '${AppLocalization.of(context)!.getTranslatedValues('pwdLengthMsg')}' : null,
      decoration: InputDecoration(
        fillColor: Theme.of(context).backgroundColor,
        filled: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(10),
        hintText: AppLocalization.of(context)!.getTranslatedValues('pwdLbl')! + "*",
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: new BorderSide(
            color: Theme.of(context).backgroundColor,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: new BorderSide(
            color: Theme.of(context).backgroundColor,
          ),
        ),
        suffixIcon: GestureDetector(
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }

  Widget showCnfPassword() {
    return TextFormField(
      controller: edtCPwd,
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      obscureText: _obscureTextCn,
      obscuringCharacter: "*",
      validator: (val) => val != edtPwd.text ? '${AppLocalization.of(context)!.getTranslatedValues('cnPwdNotMatchMsg')}' : null,
      decoration: InputDecoration(
        fillColor: Theme.of(context).backgroundColor,
        filled: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(15),
        hintText: AppLocalization.of(context)!.getTranslatedValues('cnPwdLbl')! + "*",
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: new BorderSide(
            color: Theme.of(context).backgroundColor,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: new BorderSide(
            color: Theme.of(context).backgroundColor,
          ),
        ),
        suffixIcon: GestureDetector(
          child: Icon(
            _obscureTextCn ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onTap: () {
            setState(() {
              _obscureTextCn = !_obscureTextCn;
            });
          },
        ),
      ),
    );
  }

  Widget showGoSignIn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          AppLocalization.of(context)!.getTranslatedValues('alreadyAccountLbl')!,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
        ),
        SizedBox(width: 2),
        CupertinoButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.login);
          },
          padding: EdgeInsets.all(0),
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues('loginLbl')!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget showSignup() {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 300,
            child: BlocConsumer<SignUpCubit, SignUpState>(
              listener: (context, state) async {
                if (state is SignUpSuccess) {
                  //on signup success navigate user to sign in screen
                  UiUtils.setSnackbar("${AppLocalization.of(context)!.getTranslatedValues('emailVerify')} ${edtEmail.text.trim()}", context, false);
                  setState(() {
                    Navigator.pop(context);
                  });
                } else if (state is SignUpFailure) {
                  //show error message
                  UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessage))!, context, false);
                }
              },
              builder: (context, state) {
                return CupertinoButton(
                  child: state is SignUpProgress
                      ? Center(
                          child: CircularProgressContainer(
                          heightAndWidth: 40,
                          useWhiteLoader: true,
                        ))
                      : Text(
                          AppLocalization.of(context)!.getTranslatedValues('signUpLbl')!,
                          style: TextStyle(color: Theme.of(context).backgroundColor),
                        ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      //calling signup user
                      context.read<SignUpCubit>().signUpUser(AuthProvider.email, edtEmail.text.trim(), edtPwd.text.trim());
                      resetForm();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  resetForm() {
    setState(() {
      isLoading = false;
      edtEmail.text = "";
      edtPwd.text = "";
      edtCPwd.text = "";
      _formKey.currentState!.reset();
    });
  }
}
