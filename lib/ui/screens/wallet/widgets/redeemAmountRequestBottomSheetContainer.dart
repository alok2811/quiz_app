import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/wallet/cubits/paymentRequestCubit.dart';
import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:lottie/lottie.dart';

class RedeemAmountRequestBottomSheetContainer extends StatefulWidget {
  final double redeemableAmount;
  final int deductedCoins;
  final PaymentRequestCubit paymentRequestCubit;
  RedeemAmountRequestBottomSheetContainer(
      {Key? key,
      required this.deductedCoins,
      required this.redeemableAmount,
      required this.paymentRequestCubit})
      : super(key: key);

  @override
  _RedeemAmountRequestBottomSheetContainerState createState() =>
      _RedeemAmountRequestBottomSheetContainerState();
}

class _RedeemAmountRequestBottomSheetContainerState
    extends State<RedeemAmountRequestBottomSheetContainer>
    with TickerProviderStateMixin {
  //
  late List<TextEditingController> _inputDetailsControllers =
      payoutMethods[_selectedPaymentMethodIndex]
          .inputDetailsFromUser
          .map((e) => TextEditingController())
          .toList();
  //
  late double _selectPaymentMethodDx = 0;

  late int _selectedPaymentMethodIndex = 0;
  late int _enterPayoutMethodDx = 1;
  late String _errorMessage = "";

  @override
  void dispose() {
    _inputDetailsControllers.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  Widget _buildPaymentSelectMethodContainer({required int paymentMethodIndex}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethodIndex = paymentMethodIndex;
          _inputDetailsControllers.clear();
          payoutMethods[_selectedPaymentMethodIndex]
              .inputDetailsFromUser
              .forEach((element) {
            _inputDetailsControllers.add(TextEditingController());
          });
        });
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: SvgPicture.asset(
          payoutMethods[paymentMethodIndex].image,
          color: Theme.of(context).backgroundColor,
        ),
        width: MediaQuery.of(context).size.width * (0.175),
        height: MediaQuery.of(context).size.width * (0.175),
        color: _selectedPaymentMethodIndex == paymentMethodIndex
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildInputDetailsContainer(int inputDetailsIndex) {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      margin: EdgeInsets.symmetric(
          vertical: 5.0, horizontal: MediaQuery.of(context).size.width * (0.1)),
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(25.0)),
      height: MediaQuery.of(context).size.height * (0.05),
      child: TextField(
        controller: _inputDetailsControllers[inputDetailsIndex],
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).primaryColor),
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: payoutMethods[_selectedPaymentMethodIndex]
                .inputDetailsFromUser[inputDetailsIndex],
            hintStyle: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).primaryColor,
            )),
      ),
    );
  }

  Widget _buildEnterPayoutMethodDetailsContainer() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..setEntry(
            0, 3, MediaQuery.of(context).size.width * _enterPayoutMethodDx),
      duration: Duration(milliseconds: 500),
      child: BlocConsumer<PaymentRequestCubit, PaymentRequestState>(
        listener: (context, state) {
          if (state is PaymentRequestFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              UiUtils.showAlreadyLoggedInDialog(context: context);
              return;
            }
            setState(() {
              _errorMessage = AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage))!;
            });
          } else if (state is PaymentRequestSuccess) {
            context.read<UserDetailsCubit>().updateCoins(
                  addCoin: false,
                  coins: widget.deductedCoins,
                );
          }
        },
        bloc: widget.paymentRequestCubit,
        builder: (context, state) {
          if (state is PaymentRequestSuccess) {
            return Column(
              children: [
                //
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.025),
                ),
                Container(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues(successfullyRequestedKey)!,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20.0),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.025),
                ),
                Container(
                  child: LottieBuilder.asset(
                    "assets/animations/success.json",
                    fit: BoxFit.cover,
                    animate: true,
                    height: MediaQuery.of(context).size.height * (0.2),
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.025),
                ),
                CustomRoundedButton(
                  widthPercentage: 0.525,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: AppLocalization.of(context)!
                      .getTranslatedValues(trackRequestKey),
                  radius: 15.0,
                  showBorder: false,
                  titleColor: Theme.of(context).backgroundColor,
                  fontWeight: FontWeight.bold,
                  textSize: 17.0,
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  height: 40.0,
                ),
              ],
            );
          }
          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.015),
              ),
              //
              Container(
                alignment: Alignment.center,
                child: Text(
                  "${AppLocalization.of(context)!.getTranslatedValues(payoutMethodKey)!} - ${payoutMethods[_selectedPaymentMethodIndex].type}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 20.0),
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * (0.025),
              ),

              for (var i = 0;
                  i <
                      payoutMethods[_selectedPaymentMethodIndex]
                          .inputDetailsFromUser
                          .length;
                  i++)
                _buildInputDetailsContainer(i),

              SizedBox(
                height: MediaQuery.of(context).size.height * (0.01),
              ),

              AnimatedOpacity(
                  opacity: _errorMessage.isEmpty ? 0 : 1.0,
                  duration: Duration(milliseconds: 250),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  )),

              SizedBox(
                height: MediaQuery.of(context).size.height * (0.0125),
              ),

              CustomRoundedButton(
                widthPercentage: 0.525,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: state is PaymentRequestInProgress
                    ? AppLocalization.of(context)!
                        .getTranslatedValues(requestingKey)
                    : AppLocalization.of(context)!
                        .getTranslatedValues(makeRequestKey),
                radius: 15.0,
                showBorder: false,
                titleColor: Theme.of(context).backgroundColor,
                fontWeight: FontWeight.bold,
                textSize: 17.0,
                onTap: () {
                  bool isAnyInputFieldEmpty = false;
                  for (var textEditingController in _inputDetailsControllers) {
                    if (textEditingController.text.trim().isEmpty) {
                      isAnyInputFieldEmpty = true;

                      break;
                    }
                  }

                  if (isAnyInputFieldEmpty) {
                    setState(() {
                      _errorMessage = AppLocalization.of(context)!
                          .getTranslatedValues(pleaseFillAllDataKey)!;
                    });
                    return;
                  }

                  widget.paymentRequestCubit.makePaymentRequest(
                      userId: context.read<UserDetailsCubit>().getUserId(),
                      paymentType:
                          payoutMethods[_selectedPaymentMethodIndex].type,
                      paymentAddress: jsonEncode(_inputDetailsControllers
                          .map((e) => e.text.trim())
                          .toList()),
                      paymentAmount: widget.redeemableAmount.toString(),
                      coinUsed: widget.deductedCoins.toString(),
                      details: "Redeem Request");
                },
                height: 40.0,
              ),

              Container(
                child: TextButton(
                    onPressed: () {
                      //
                      setState(() {
                        _selectPaymentMethodDx = 0;
                        _enterPayoutMethodDx = 1;
                        _errorMessage = "";
                      });
                    },
                    child: Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues(changePayoutMethodKey)!,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    )),
              )
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildPayoutSelectMethosContainer() {
    List<Widget> children = [];
    for (var i = 0; i < payoutMethods.length; i++) {
      children.add(_buildPaymentSelectMethodContainer(paymentMethodIndex: i));
    }
    return children;
  }

  Widget _buildSelectPayoutOption() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..setEntry(
            0, 3, MediaQuery.of(context).size.width * _selectPaymentMethodDx),
      duration: Duration(milliseconds: 500),
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(0.0, -20.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues(redeemableAmountKey)!,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20.0),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "\$${widget.redeemableAmount}",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 22.0),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "${widget.deductedCoins} ${AppLocalization.of(context)!.getTranslatedValues(coinsWillBeDeductedKey)}",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20.0),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(0.0, -10.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(selectPayoutOptionKey)!,
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20.0),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.55) * (0.05),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: _buildPayoutSelectMethosContainer(),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.55) * (0.075),
          ),
          CustomRoundedButton(
            widthPercentage: 0.4,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle:
                AppLocalization.of(context)!.getTranslatedValues(continueLbl),
            radius: 15.0,
            showBorder: false,
            titleColor: Theme.of(context).backgroundColor,
            fontWeight: FontWeight.bold,
            textSize: 17.0,
            onTap: () {
              //
              setState(() {
                _selectPaymentMethodDx = -1;
                _enterPayoutMethodDx = 0;
              });
            },
            height: 40.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * (0.8)),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          gradient: UiUtils.buildLinerGradient([
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).canvasColor
          ], Alignment.topCenter, Alignment.bottomCenter)),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.all(10.0),
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        onPressed: () {
                          if (widget.paymentRequestCubit.state
                              is PaymentRequestInProgress) {
                            return;
                          }
                          //if state is PaymentRequestSuccess then update coins and transaction
                          Navigator.of(context).pop(widget.paymentRequestCubit
                              .state is PaymentRequestSuccess);
                        },
                        icon: Icon(
                          Icons.close,
                          size: 28.0,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                ],
              ),
              Stack(
                children: [
                  _buildSelectPayoutOption(),
                  _buildEnterPayoutMethodDetailsContainer(),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.05),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
