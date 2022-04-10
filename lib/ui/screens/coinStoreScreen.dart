import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/inAppPurchase/inAppPurchaseCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/profileManagement/profileManagementRepository.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/ui/widgets/roundedAppbar.dart';
import 'package:ayuprep/utils/inAppPurchaseProducts.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CoinStoreScreen extends StatefulWidget {
  CoinStoreScreen({Key? key}) : super(key: key);

  @override
  _CoinStoreScreenState createState() => _CoinStoreScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(providers: [
              BlocProvider<InAppPurchaseCubit>(
                  create: (context) => InAppPurchaseCubit(
                      productIds: inAppPurchaseProducts.values.toList())),
              BlocProvider<UpdateScoreAndCoinsCubit>(
                  create: (context) =>
                      UpdateScoreAndCoinsCubit(ProfileManagementRepository())),
            ], child: CoinStoreScreen()));
  }
}

class _CoinStoreScreenState extends State<CoinStoreScreen>
    with SingleTickerProviderStateMixin {
  bool canGoBack = true;

  void initPurchase() {
    context
        .read<InAppPurchaseCubit>()
        .initializePurchase(inAppPurchaseProducts.values.toList());
  }

  Widget _buildProducts(List<ProductDetails> products) {
    return GridView.builder(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height *
            (UiUtils.appBarHeightPercentage + 0.05),
        left: 20.0,
        right: 20.0,
      ),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 10.0,
      ),
      itemBuilder: (context, index) {
        var coins = inAppPurchaseProducts.keys
            .where((element) =>
                inAppPurchaseProducts[element] == products[index].id)
            .toList()
            .first;

        return GestureDetector(
          onTap: () {
            canGoBack = false;
            context
                .read<InAppPurchaseCubit>()
                .buyConsumableProducts(products[index]);
          },
          child: Container(
            child: Column(
              children: [
                Flexible(
                  flex: 3,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "$coins ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!}",
                      style: TextStyle(
                        color: Theme.of(context).backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                    ),
                  ),
                ),
                Flexible(
                    flex: 7,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(25.0),
                      child:
                          SvgPicture.asset("assets/images/coins/04_coins.svg"),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                        ),
                      ),
                    )),
              ],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        final InAppPurchaseCubit inAppPurchaseCubit =
            context.read<InAppPurchaseCubit>();
        if (inAppPurchaseCubit.state is InAppPurchaseProcessInProgress) {
          return Future.value(false);
        }
        if (!canGoBack) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageBackgroundGradientContainer(),
            Align(
              alignment: Alignment.topCenter,
              child: BlocConsumer<InAppPurchaseCubit, InAppPurchaseState>(
                bloc: context.read<InAppPurchaseCubit>(),
                listener: (context, state) {
                  print("State change to ${state.toString()}");
                  if (state is InAppPurchaseProcessSuccess) {
                    var coins = inAppPurchaseProducts.keys
                        .where((element) =>
                            inAppPurchaseProducts[element] ==
                            state.purchasedProductId)
                        .toList()
                        .first;
                    context.read<UserDetailsCubit>().updateCoins(
                          addCoin: true,
                          coins: coins,
                        );
                    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                          context.read<UserDetailsCubit>().getUserId(),
                          coins,
                          true,
                          boughtCoinsKey,
                        );
                    UiUtils.setSnackbar(
                        AppLocalization.of(context)!
                            .getTranslatedValues(coinsBoughtSuccessKey)!,
                        context,
                        false);
                    canGoBack = true;
                  } else if (state is InAppPurchaseProcessFailure) {
                    canGoBack = true;
                    UiUtils.setSnackbar(
                        AppLocalization.of(context)!
                            .getTranslatedValues(state.errorMessage)!,
                        context,
                        false);
                  }
                },
                builder: (context, state) {
                  //initial state of cubit
                  if (state is InAppPurchaseInitial ||
                      state is InAppPurchaseLoading) {
                    return Center(
                      child: CircularProgressContainer(
                        useWhiteLoader: false,
                      ),
                    );
                  }

                  //if occurred problem while fetching product details
                  //from appstore or playstore
                  if (state is InAppPurchaseFailure) {
                    //
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: AppLocalization.of(context)!
                            .getTranslatedValues(state.errorMessage)!,
                        onTapRetry: () {
                          initPurchase();
                        },
                        showErrorImage: true,
                      ),
                    );
                  }

                  if (state is InAppPurchaseNotAvailable) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: AppLocalization.of(context)!
                            .getTranslatedValues(inAppPurchaseUnavailableKey)!,
                        onTapRetry: () {
                          initPurchase();
                        },
                        showErrorImage: true,
                      ),
                    );
                  }

                  //if any error occurred in while making in-app purchase
                  if (state is InAppPurchaseProcessFailure) {
                    return _buildProducts(state.products);
                  }
                  //
                  if (state is InAppPurchaseAvailable) {
                    return _buildProducts(state.products);
                  }
                  //
                  if (state is InAppPurchaseProcessSuccess) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseProcessInProgress) {
                    return _buildProducts(state.products);
                  }

                  return Container();
                },
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: RoundedAppbar(
                title: AppLocalization.of(context)!
                    .getTranslatedValues(coinStoreKey)!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
