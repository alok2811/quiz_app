import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/badges/badge.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class UnlockedRewardContent extends StatelessWidget {
  final Badge reward;
  final bool increaseFont;
  const UnlockedRewardContent({Key? key, required this.reward, required this.increaseFont}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.85,
          child: SvgPicture.asset(
            UiUtils.getImagePath("celebration.svg"),
            color: Theme.of(context).backgroundColor,
            fit: BoxFit.fill,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  type: MaterialType.transparency,
                  child: Text(
                    "${reward.badgeReward} ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontSize: increaseFont ? 29 : 25,
                    ),
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: Text(
                    "${AppLocalization.of(context)!.getTranslatedValues(byUnlockingKey)!} ${reward.badgeLabel}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontSize: increaseFont ? 18 : 14,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
