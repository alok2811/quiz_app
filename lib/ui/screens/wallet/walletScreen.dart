import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:ayuprep/features/wallet/cubits/paymentRequestCubit.dart';
import 'package:ayuprep/features/wallet/cubits/transactionsCubit.dart';
import 'package:ayuprep/features/wallet/models/paymentRequest.dart';
import 'package:ayuprep/features/wallet/walletRepository.dart';
import 'package:ayuprep/ui/screens/wallet/widgets/redeemAmountRequestBottomSheetContainer.dart';
import 'package:ayuprep/ui/styles/colors.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletScreen extends StatefulWidget {
  WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
              //
              BlocProvider<PaymentRequestCubit>(
                create: (_) => PaymentRequestCubit(
                  WalletRepository(),
                ),
              ),

              BlocProvider<TransactionsCubit>(
                create: (_) => TransactionsCubit(
                  WalletRepository(),
                ),
              ),
            ], child: WalletScreen()));
  }
}

class _WalletScreenState extends State<WalletScreen> {
  int _currentSelectedTab = 1;

  TextEditingController? redeemableAmountTextEditingController;

  late ScrollController _transactionsScrollController = ScrollController()
    ..addListener(hasMoreTransactionsScrollListener);

  void hasMoreTransactionsScrollListener() {
    if (_transactionsScrollController.position.maxScrollExtent ==
        _transactionsScrollController.offset) {
      print("At the end of the list");
      if (context.read<TransactionsCubit>().hasMoreTransactions()) {
        //
        context.read<TransactionsCubit>().getMoreTransactions(
            userId: context.read<UserDetailsCubit>().getUserId());
      } else {
        print("No more transactions");
      }
    }
  }

  void fetchTransactions() {
    context
        .read<TransactionsCubit>()
        .getTransactions(userId: context.read<UserDetailsCubit>().getUserId());
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchTransactions();
      //
      redeemableAmountTextEditingController = TextEditingController(
        text: UiUtils.calculateAmountPerCoins(
          userCoins: double.parse(context.read<UserDetailsCubit>().getCoins()!)
              .toInt(),
          amount: context
              .read<SystemConfigCubit>()
              .coinAmount(), //per x coin y amount
          coins: context.read<SystemConfigCubit>().perCoin(), //per x coins
        ).toString(),
      );

      setState(() {});
    });
  }

  //
  double _minimumReedemableAmount() {
    return UiUtils.calculateAmountPerCoins(
      userCoins: context.read<SystemConfigCubit>().minimumcoinLimit(),
      amount: context.read<SystemConfigCubit>().coinAmount(),
      coins: context.read<SystemConfigCubit>().perCoin(),
    );
  }

  //

  @override
  void dispose() {
    redeemableAmountTextEditingController?.dispose();
    _transactionsScrollController
        .removeListener(hasMoreTransactionsScrollListener);
    _transactionsScrollController.dispose();
    super.dispose();
  }

  void showRedeemRequestAmountBottomSheet(
      {required int deductedCoins, required double redeemableAmount}) {
    //
    showModalBottomSheet<bool>(
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        elevation: 5.0,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (_) {
          return RedeemAmountRequestBottomSheetContainer(
            paymentRequestCubit: context.read<PaymentRequestCubit>(),
            deductedCoins: deductedCoins,
            redeemableAmount: redeemableAmount,
          );
        }).then((value) {
      if (value != null && value) {
        fetchTransactions();
        redeemableAmountTextEditingController?.text =
            UiUtils.calculateAmountPerCoins(
                    userCoins:
                        int.parse(context.read<UserDetailsCubit>().getCoins()!),
                    amount: context.read<SystemConfigCubit>().coinAmount(),
                    coins: context.read<SystemConfigCubit>().perCoin())
                .toString();

        setState(() {
          _currentSelectedTab = 2;
        });
      }
    });
  }

  Widget _buildTabContainer(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSelectedTab = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context)
                .primaryColor
                .withOpacity(_currentSelectedTab == index ? 1.0 : 0.5),
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 25.0, bottom: 35.0),
              child: CustomBackButton(
                removeSnackBars: false,
                iconColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: 37.5),
              child: Text(
                  AppLocalization.of(context)!.getTranslatedValues(walletKey)!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 21.0, color: Theme.of(context).primaryColor)),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabContainer(
                    AppLocalization.of(context)!
                        .getTranslatedValues(requestKey)!,
                    1),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                _buildTabContainer(
                    AppLocalization.of(context)!
                        .getTranslatedValues(transactionKey)!,
                    2),
              ],
            ),
          ),
        ],
      ),
      height:
          MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage),
      decoration: BoxDecoration(
          boxShadow: [UiUtils.buildAppbarShadow()],
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0))),
    );
  }

  Widget _buildWalletRequestNoteContainer(String note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 7.5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(3)),
          ),
          SizedBox(
            width: 10.0,
          ),
          Flexible(
              child: Text(
            note,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              height: 1.2,
            ),
          ))
        ],
      ),
    );
  }

  //Build request tab
  Widget _buildRequestContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height *
            (UiUtils.appBarHeightPercentage + 0.05),
        left: MediaQuery.of(context).size.width * (0.05),
        right: MediaQuery.of(context).size.width * (0.05),
      ),
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
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30.0,
                ),
                Text("\$",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 30.0)),
                SizedBox(
                  width: 5.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (0.2),
                  child: TextField(
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 30.0),
                    keyboardType: TextInputType.number,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: "00",
                        hintStyle: TextStyle(
                          fontSize: 25.0,
                          color: Theme.of(context).primaryColor,
                        )),
                    controller: redeemableAmountTextEditingController,
                  ),
                ),
              ],
            ),
          ),

          Container(
            alignment: Alignment.center,
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues(totalCoinsKey)!,
              style: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.75),
                  fontSize: 20.0),
            ),
          ),

          //User's coins
          BlocBuilder<UserDetailsCubit, UserDetailsState>(
            bloc: context.read<UserDetailsCubit>(),
            builder: (context, state) {
              if (state is UserDetailsFetchSuccess) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    "${context.read<UserDetailsCubit>().getCoins()}",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20.0),
                  ),
                );
              }

              return SizedBox();
            },
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),
          //
          CustomRoundedButton(
            widthPercentage: 0.4,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle: AppLocalization.of(context)!
                    .getTranslatedValues(redeemNowKey) ??
                "",
            radius: 15.0,
            showBorder: false,
            titleColor: Theme.of(context).backgroundColor,
            fontWeight: FontWeight.bold,
            textSize: 17.0,
            onTap: () {
              if (redeemableAmountTextEditingController!.text.trim().isEmpty) {
                return;
              }

              if (double.parse(
                      redeemableAmountTextEditingController!.text.trim()) <
                  _minimumReedemableAmount()) {
                //

                UiUtils.setSnackbar(
                    "${AppLocalization.of(context)!.getTranslatedValues(minimumRedeemableAmountKey)} \$${_minimumReedemableAmount()} ",
                    context,
                    false);
                return;
              }
              double maxRedeemableAmount = UiUtils.calculateAmountPerCoins(
                userCoins:
                    int.parse(context.read<UserDetailsCubit>().getCoins()!),
                amount: context
                    .read<SystemConfigCubit>()
                    .coinAmount(), //per x coin y amount
                coins:
                    context.read<SystemConfigCubit>().perCoin(), //per x coins
              );
              if (double.parse(
                      redeemableAmountTextEditingController!.text.trim()) >
                  maxRedeemableAmount) {
                //

                UiUtils.setSnackbar(
                    AppLocalization.of(context)!
                        .getTranslatedValues(notEnoughCoinsToRedeemAmountKey)!,
                    context,
                    false);
                return;
              }

              showRedeemRequestAmountBottomSheet(
                deductedCoins:
                    UiUtils.calculateDeductedCoinsForRedeemableAmount(
                  amount: context
                      .read<SystemConfigCubit>()
                      .coinAmount(), //per x coin y amount
                  coins:
                      context.read<SystemConfigCubit>().perCoin(), //per x coins
                  userEnteredAmount: double.parse(
                    redeemableAmountTextEditingController!.text.trim(),
                  ),
                ),
                redeemableAmount: double.parse(
                    redeemableAmountTextEditingController!.text.trim()),
              );
            },
            height: 50.0,
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * (0.03),
          ),

          Divider(
            height: 1.5,
            color: Theme.of(context).primaryColor,
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),

          //
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues(notesKey)!,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18.0),
                    )),
                Column(
                  children: walletRequestNotes
                      .map((e) => _buildWalletRequestNoteContainer(e))
                      .toList(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionContainer({
    required PaymentRequest paymentRequest,
    required int index,
    required int totalTransactions,
    required bool hasMoreTransactionsFetchError,
    required bool hasMore,
  }) {
    if (index == totalTransactions - 1) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreTransactionsFetchError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: IconButton(
                  onPressed: () {
                    context.read<TransactionsCubit>().getMoreTransactions(
                        userId: context.read<UserDetailsCubit>().getUserId());
                  },
                  icon: Icon(
                    Icons.error,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          );
        } else {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: CircularProgressContainer(
                useWhiteLoader: false,
                heightAndWidth: 40,
              ),
            ),
          );
        }
      }
    }

    //
    return GestureDetector(
      onTap: () {
        //
      },
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Container(
          child: Row(
            children: [
              Container(
                width: boxConstraints.maxWidth * (0.66),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      paymentRequest.details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16.5),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Text(paymentRequest.paymentType,
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.875))),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * (0.0175),
                        ),
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 2,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * (0.0175),
                        ),
                        Text(
                          paymentRequest.date.length < 11
                              ? paymentRequest.date
                              : paymentRequest.date.substring(0, 11),
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.875)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                width: boxConstraints.maxWidth * 0.28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 1.0),
                      margin: EdgeInsets.only(
                          left: boxConstraints.maxWidth * 0.3 * (0.4)),
                      color: Theme.of(context).primaryColor,
                      alignment: Alignment.center,
                      child: Text(
                        "\$${UiUtils.formatNumber(double.parse(paymentRequest.paymentAmount).toInt())}",
                        style: TextStyle(
                            color: Theme.of(context).backgroundColor,
                            fontSize: 15),
                      ),
                    ),
                    Spacer(),
                    Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues(paymentRequest.status == "0"
                              ? pendingKey
                              : paymentRequest.status == "1"
                                  ? completedKey
                                  : wrongDetailsKey)!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: paymentRequest.status == "0"
                              ? Theme.of(context).primaryColor
                              : paymentRequest.status == "1"
                                  ? addCoinColor
                                  : hurryUpTimerColor,
                          fontSize: 12.0),
                    ),
                  ],
                ),
              )
            ],
          ),
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (0.0265),
              vertical: 15),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 3.5,
                    offset: Offset(2.5, 3.5),
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.15))
              ],
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(10.0)),
          height: MediaQuery.of(context).size.height *
              UiUtils.getTransactionContainerHeight(
                  MediaQuery.of(context).size.height), //
          margin: EdgeInsets.symmetric(vertical: 10.0),
        );
      }),
    );
  }

  Widget _buildTransactionListContainer() {
    return BlocConsumer<TransactionsCubit, TransactionsState>(
      listener: (context, state) {
        if (state is TransactionsFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      builder: (context, state) {
        if (state is TransactionsFetchInProgress ||
            state is TransactionsFetchInitial) {
          return Center(
            child: CircularProgressContainer(useWhiteLoader: false),
          );
        }
        if (state is TransactionsFetchFailure) {
          return Center(
            child: ErrorContainer(
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage)),
                onTapRetry: () {
                  fetchTransactions();
                },
                showErrorImage: true),
          );
        }

        return SingleChildScrollView(
          controller: _transactionsScrollController,
          child: Column(
            children: [
              //

              Container(
                alignment: Alignment.center,
                child: Text(
                  "${AppLocalization.of(context)!.getTranslatedValues(totalEarningsKey)!} : \$${context.read<TransactionsCubit>().calculateTotalEarnings()}",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18.0,
                  ),
                ),
                width: MediaQuery.of(context).size.width * (0.75),
                height: MediaQuery.of(context).size.height * (0.065),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 3.5,
                          offset: Offset(2.5, 2.5),
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.15))
                    ],
                    color: Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.015),
              ),

              for (var i = 0;
                  i <
                      (state as TransactionsFetchSuccess)
                          .paymentRequests
                          .length;
                  i++)
                _buildTransactionContainer(
                    paymentRequest: state.paymentRequests[i],
                    index: i,
                    totalTransactions: state.paymentRequests.length,
                    hasMoreTransactionsFetchError: state.hasMoreFetchError,
                    hasMore: state.hasMore)
            ],
          ),
          padding: EdgeInsets.only(
              bottom: 20.0,
              top: MediaQuery.of(context).size.height *
                  (UiUtils.appBarHeightPercentage + 0.025),
              left: MediaQuery.of(context).size.width * (0.05),
              right: MediaQuery.of(context).size.width * (0.05)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          Align(
            alignment: Alignment.topCenter,
            child: _currentSelectedTab == 1
                ? _buildRequestContainer()
                : _buildTransactionListContainer(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
        ],
      ),
    );
  }
}
