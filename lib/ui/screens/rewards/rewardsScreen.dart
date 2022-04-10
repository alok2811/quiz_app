import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/badges/badge.dart';
import 'package:ayuprep/features/badges/cubits/badgesCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/profileManagement/profileManagementRepository.dart';
import 'package:ayuprep/ui/screens/rewards/scratchRewardScreen.dart';
import 'package:ayuprep/ui/screens/rewards/widgets/unlockedRewardContent.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/roundedAppbar.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class RewardsScreen extends StatefulWidget {
  RewardsScreen({
    Key? key,
  }) : super(key: key);

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
              child: RewardsScreen(),
              create: (_) =>
                  UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
            ));
  }

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  Widget _buildRewardContainer(Badge reward) {
    return GestureDetector(
      onTap: () {
        if (reward.status == "1") {
          Navigator.of(context).push(PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 400),
            opaque: false,
            pageBuilder: (context, firstAnimation, secondAnimation) {
              return FadeTransition(
                opacity: firstAnimation,
                child: BlocProvider<UpdateScoreAndCoinsCubit>(
                  create: (context) =>
                      UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
                  child: ScratchRewardScreen(
                    reward: reward,
                  ),
                ),
              );
            },
          ));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: reward.status == "2"
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).primaryColor,
        ),
        child: reward.status == "2"
            ? UnlockedRewardContent(
                reward: reward,
                increaseFont: false,
              )
            : Stack(
                children: [
                  Image.asset(
                    UiUtils.getImagePath("scratchCardCover.png"),
                    fit: BoxFit.cover,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRewards() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height *
                    UiUtils.appBarHeightPercentage +
                25.0,
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<BadgesCubit, BadgesState>(
                    bloc: context.read<BadgesCubit>(),
                    builder: (context, state) {
                      return Text(
                        "${context.read<BadgesCubit>().getRewardedCoins()} ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!}",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                        ),
                      );
                    },
                  ),
                  Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues(totalRewardsEarnedKey)!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                height: 55.0,
                width: 55.0,
                child: SvgPicture.asset(UiUtils.getImagePath("giftbox.svg")),
              )
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            child: Divider(
              color: Theme.of(context).primaryColor,
              height: 5,
            ),
          ),
        ),
        BlocBuilder<BadgesCubit, BadgesState>(
          bloc: context.read<BadgesCubit>(),
          builder: (context, state) {
            if (state is BadgesFetchFailure) {
              return SliverToBoxAdapter(
                child: Center(
                  child: ErrorContainer(
                      errorMessage: AppLocalization.of(context)!
                          .getTranslatedValues(convertErrorCodeToLanguageKey(
                              state.errorMessage))!,
                      onTapRetry: () {
                        context.read<BadgesCubit>().getBadges(
                            userId:
                                context.read<UserDetailsCubit>().getUserId(),
                            refreshBadges: true);
                      },
                      showErrorImage: true),
                ),
              );
            }

            if (state is BadgesFetchSuccess) {
              final rewards = context.read<BadgesCubit>().getRewards();
              //ifthere is no rewards
              if (rewards.isEmpty) {
                return SliverToBoxAdapter(
                  child: Text(AppLocalization.of(context)!
                      .getTranslatedValues(noRewardsKey)!),
                );
              }

              //create grid count
              return SliverGrid.count(
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
                children: [
                  ...rewards
                      .map((reward) => Hero(
                            tag: reward.type,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: _buildRewardContainer(reward),
                            ),
                          ))
                      .toList(),
                ],
                crossAxisCount: 2,
              );
            }

            return SliverToBoxAdapter(
              child: Center(
                child: CircularProgressContainer(useWhiteLoader: false),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<BadgesCubit, BadgesState>(
        listener: (context, state) {
          //
          if (state is BadgesFetchFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              UiUtils.showAlreadyLoggedInDialog(context: context);
            }
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * (0.075)),
              child: _buildRewards(),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: RoundedAppbar(
                title: AppLocalization.of(context)!
                    .getTranslatedValues(rewardsLbl)!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
