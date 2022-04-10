import 'package:facebook_audience_network/ad/ad_interstitial.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class InterstitialAdState {}

class InterstitialAdInitial extends InterstitialAdState {}

class InterstitialAdLoaded extends InterstitialAdState {}

class InterstitialAdLoadInProgress extends InterstitialAdState {}

class InterstitialAdFailToLoad extends InterstitialAdState {}

class InterstitialAdCubit extends Cubit<InterstitialAdState> {
  InterstitialAdCubit() : super(InterstitialAdInitial());

  InterstitialAd? _interstitialAd;

  InterstitialAd? get interstitialAd => _interstitialAd;

  void _createGoogleInterstitialAd(BuildContext context) {
    InterstitialAd.load(
        adUnitId: context.read<SystemConfigCubit>().googleInterstitialAdId(),
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print("InterstitialAd Ad loaded successfully");
            _interstitialAd = ad;
            emit(InterstitialAdLoaded());
          },
          onAdFailedToLoad: (LoadAdError error) {
            print(error);
            emit(InterstitialAdFailToLoad());
          },
        ));
  }

  void _createFacebookInterstitialAd(BuildContext context) async {
    await FacebookInterstitialAd.destroyInterstitialAd();
    FacebookInterstitialAd.loadInterstitialAd(
        placementId: context.read<SystemConfigCubit>().faceBookInterstitialAdId(),
        listener: (result, value) {
          if (result == InterstitialAdResult.LOADED) {
            print("Facebook ad loaded");
            emit(InterstitialAdLoaded());
          }
          if (result == InterstitialAdResult.ERROR) {
            print("Facebook ad error : $value");
            print("---------------------");
            emit(InterstitialAdFailToLoad());
          }
          //if ad dismissed and becomes invalidate
          if (result == InterstitialAdResult.DISMISSED && value["invalidated"] == true) {
            createInterstitialAd(context);
          }
        });
  }

  void createInterstitialAd(BuildContext context) {
    if (context.read<SystemConfigCubit>().isAdsEnable()) {
      emit(InterstitialAdLoadInProgress());
      if (context.read<SystemConfigCubit>().isGoogleAdEnable()) {
        _createGoogleInterstitialAd(context);
      } else {
        _createFacebookInterstitialAd(context);
      }
    }
  }

  void showAd(BuildContext context) {
    //if ad is enable
    if (context.read<SystemConfigCubit>().isAdsEnable()) {
      //if ad loaded succesfully
      if (state is InterstitialAdLoaded) {
        //show google interstitial ad
        if (context.read<SystemConfigCubit>().isGoogleAdEnable()) {
          interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {},
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              createInterstitialAd(context);
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
              createInterstitialAd(context);
            },
          );
          interstitialAd?.show();
        } else {
          //show facebook interstitial ad
          FacebookInterstitialAd.showInterstitialAd();
        }
      } else if (state is InterstitialAdFailToLoad) {
        createInterstitialAd(context);
      }
    }
  }

  @override
  Future<void> close() async {
    _interstitialAd?.dispose();
    return super.close();
  }
}
