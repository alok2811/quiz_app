import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';

import 'package:ayuprep/utils/uiUtils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class BannerAdContainer extends StatefulWidget {
  @override
  _BannerAdContainer createState() => _BannerAdContainer();
}

class _BannerAdContainer extends State<BannerAdContainer> {
  BannerAd? _googleBannerAd;
  FacebookBannerAd? _facebookBannerAd;

  @override
  void initState() {
    super.initState();
    _initBannerAd();
  }

  @override
  void dispose() {
    _googleBannerAd?.dispose();

    super.dispose();
  }

  void _initBannerAd() {
    Future.delayed(Duration.zero, () {
      final systemConfigCubit = context.read<SystemConfigCubit>();
      if (systemConfigCubit.isAdsEnable()) {
        //is google ad enable or not
        print(systemConfigCubit.isGoogleAdEnable());
        if (systemConfigCubit.isGoogleAdEnable()) {
          _createGoogleBannerAd();
        } else {
          _createFacebookBannerAd();
        }
      }
    });
  }

  void _createFacebookBannerAd() async {
    _facebookBannerAd = FacebookBannerAd(
      bannerSize: BannerSize.STANDARD,
      placementId: context.read<SystemConfigCubit>().faceBookBannerId(),
      listener: (result, value) {
        print("$result -> $value");
      },
    );
    setState(() {});
  }

  Future<void> _createGoogleBannerAd() async {
    final BannerAd banner = BannerAd(
      request: AdRequest(),
      adUnitId: context.read<SystemConfigCubit>().googleBannerId(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded');
          setState(() {
            _googleBannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed'),
      ),
      size: AdSize.banner,
    );
    banner.load();
  }

  @override
  Widget build(BuildContext context) {
    final systemConfigCubit = context.read<SystemConfigCubit>();
    if (systemConfigCubit.isAdsEnable()) {
      if (systemConfigCubit.isGoogleAdEnable()) {
        return _googleBannerAd != null
            ? Container(
                decoration: BoxDecoration(
                  gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter),
                ),
                width: MediaQuery.of(context).size.width,
                height: _googleBannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _googleBannerAd!),
              )
            : Container();
      }
      return _facebookBannerAd == null ? Container() : _facebookBannerAd!;
    }
    return Container();
  }
}
