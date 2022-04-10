import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/badges/badge.dart';
import 'package:ayuprep/features/badges/cubits/badgesCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/statistic/cubits/statisticsCubit.dart';

import 'package:ayuprep/ui/styles/colors.dart';
import 'package:ayuprep/ui/widgets/badgesIconContainer.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/roundedAppbar.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({Key? key}) : super(key: key);

  static Route<BadgesScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BadgesScreen(),
    );
  }

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      UiUtils.updateBadgesLocally(context);
      //
      context
          .read<StatisticCubit>()
          .getStatistic(context.read<UserDetailsCubit>().getUserId());
    });

    super.initState();
  }

  void showBadgeDetails(BuildContext context, Badge badge) {
    showModalBottomSheet(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        )),
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    height: MediaQuery.of(context).size.height * (0.25),
                    width: MediaQuery.of(context).size.width * (0.3),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return BadgesIconContainer(
                        badge: badge,
                        constraints: constraints,
                        addTopPadding: true,
                      );
                    })),
                Transform.translate(
                  offset:
                      Offset(0, MediaQuery.of(context).size.height * (-0.05)),
                  child: Column(
                    children: [
                      Text(
                        "${badge.badgeLabel}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: badge.status == "0"
                              ? badgeLockedColor
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22.5,
                        ),
                      ),
                      SizedBox(
                        height: 2.5,
                      ),
                      Text(
                        "${badge.badgeNote}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(
                        height: 2.5,
                      ),
                      //
                      badge.type == "big_thing" && badge.status == "0"
                          ? BlocBuilder<StatisticCubit, StatisticState>(
                              bloc: context.read<StatisticCubit>(),
                              builder: (context, state) {
                                if (state is StatisticInitial ||
                                    state is StatisticFetchInProgress) {
                                  return Center(
                                    child: Container(
                                      height: 15.0,
                                      width: 15.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  );
                                }
                                if (state is StatisticFetchFailure) {
                                  return Container();
                                }
                                final statisticDetails =
                                    (state as StatisticFetchSuccess)
                                        .statisticModel;
                                final answerToGo = int.parse(
                                        badge.badgeCounter) -
                                    int.parse(statisticDetails.correctAnswers);
                                return Column(
                                  children: [
                                    Text(
                                      "${AppLocalization.of(context)!.getTranslatedValues(needMoreKey)!} $answerToGo ${AppLocalization.of(context)!.getTranslatedValues(correctAnswerToUnlockKey)!}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                  ],
                                );
                              },
                            )
                          : Container(),

                      Text(
                        "${AppLocalization.of(context)!.getTranslatedValues(getKey)!} ${badge.badgeReward} ${AppLocalization.of(context)!.getTranslatedValues(coinsUnlockingByBadgeKey)!}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                gradient: UiUtils.buildLinerGradient([
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).canvasColor
                ], Alignment.topCenter, Alignment.bottomCenter)),
          );
        });
  }

  List<Badge> _organizedBadges(List<Badge> badges) {
    List<Badge> lockedBadges =
        badges.where((element) => element.status == "0").toList();
    List<Badge> unlockedBadges = badges
        .where((element) => element.status == "1" || element.status == "2")
        .toList();
    unlockedBadges.addAll(lockedBadges);
    return unlockedBadges;
  }

  Widget _buildBadges(BuildContext context) {
    return BlocConsumer<BadgesCubit, BadgesState>(
      listener: (context, state) {
        if (state is BadgesFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      bloc: context.read<BadgesCubit>(),
      builder: (context, state) {
        if (state is BadgesFetchInProgress || state is BadgesInitial) {
          return Center(
            child: CircularProgressContainer(
              useWhiteLoader: false,
            ),
          );
        }
        if (state is BadgesFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage)),
              onTapRetry: () {
                context.read<BadgesCubit>().getBadges(
                    userId: context.read<UserDetailsCubit>().getUserId(),
                    refreshBadges: true);
              },
              showErrorImage: true,
            ),
          );
        }
        final List<Badge> badges =
            _organizedBadges((state as BadgesFetchSuccess).badges);
        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          displacement: MediaQuery.of(context).size.height *
                  (UiUtils.appBarHeightPercentage + 0.025) +
              20,
          onRefresh: () async {
            context.read<BadgesCubit>().getBadges(
                userId: context.read<UserDetailsCubit>().getUserId(),
                refreshBadges: true);
          },
          child: GridView.builder(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height *
                    (UiUtils.appBarHeightPercentage + 0.025),
                left: 15.0,
                right: 15.0,
                bottom: 20.0,
              ),
              itemCount: badges.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 7.5,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.575,
              ),
              itemBuilder: (context, index) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTap: () {
                        showBadgeDetails(context, badges[index]);
                      },
                      child: Container(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: constraints.maxWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: constraints.maxHeight * (0.4),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        badges[index].badgeLabel,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: badges[index].status == "0"
                                              ? badgeLockedColor
                                              : Theme.of(context)
                                                  .primaryColor, //
                                          fontSize: 14,
                                          height: 1.175,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                height: constraints.maxHeight * (0.65),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                            BadgesIconContainer(
                              badge: badges[index],
                              constraints: constraints,
                              addTopPadding: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildBadges(context),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: RoundedAppbar(
              title:
                  AppLocalization.of(context)!.getTranslatedValues(badgesKey)!,
            ),
          ),
        ],
      ),
    );
  }
}
