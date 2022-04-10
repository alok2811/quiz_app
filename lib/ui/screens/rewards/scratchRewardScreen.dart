import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/badges/badge.dart';
import 'package:ayuprep/features/badges/cubits/badgesCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/ui/screens/rewards/widgets/unlockedRewardContent.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:scratcher/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ScratchRewardScreen extends StatefulWidget {
  final Badge reward;
  ScratchRewardScreen({Key? key, required this.reward}) : super(key: key);

  @override
  _ScratchRewardScreenState createState() => _ScratchRewardScreenState();
}

class _ScratchRewardScreenState extends State<ScratchRewardScreen> {
  GlobalKey<ScratcherState> scratcherKey = GlobalKey<ScratcherState>();
  bool _showScratchHere = true;

  bool _goBack() {
    bool isFinished = scratcherKey.currentState?.isFinished ?? false;
    if (scratcherKey.currentState?.progress != 0.0 && !isFinished) {
      scratcherKey.currentState?.reveal(duration: Duration(milliseconds: 250));

      return false;
    }
    return true;
  }

  void unlockReward() {
    if (context.read<BadgesCubit>().isRewardUnlocked(widget.reward.type)) {
      return;
    }
    context.read<BadgesCubit>().unlockReward(widget.reward.type);

    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
          context.read<UserDetailsCubit>().getUserId(),
          int.parse(widget.reward.badgeReward),
          true,
          rewardByScratchingCardKey,
          type: widget.reward.type,
        );
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: int.parse(widget.reward.badgeReward),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(_goBack());
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.45),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * (0.05),
                  left: MediaQuery.of(context).size.width * (0.05),
                ),
                child: IconButton(
                  iconSize: 30,
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    if (_goBack()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Hero(
                tag: widget.reward.type,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Scratcher(
                        onChange: (value) {
                          if (value > 0.0 && _showScratchHere) {
                            setState(() {
                              _showScratchHere = false;
                            });
                          }

                          if (value == 100.0) {
                            unlockReward();
                          }
                        },
                        key: scratcherKey,
                        brushSize: 25,
                        threshold: 50,
                        accuracy: ScratchAccuracy.low,
                        color: Theme.of(context).primaryColor,
                        image: Image.asset(
                            UiUtils.getImagePath("scratchCardCover.png")),
                        child: UnlockedRewardContent(
                          reward: widget.reward,
                          increaseFont: true,
                        )),
                    height: MediaQuery.of(context).size.height * (0.4),
                    width: MediaQuery.of(context).size.width * (0.8),
                  ),
                ),
              ),
            ),
            _showScratchHere
                ? Align(
                    alignment: Alignment.center,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        child: Center(
                          child: Text(
                            AppLocalization.of(context)!
                                .getTranslatedValues(scratchHereKey)!,
                            style: TextStyle(
                                color: Theme.of(context).backgroundColor,
                                fontSize: 18.0),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.6),
                        ),
                        height: MediaQuery.of(context).size.height * (0.075),
                        width: MediaQuery.of(context).size.width * (0.8),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
