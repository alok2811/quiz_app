import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/leaderBoard/cubit/leaderBoardAllTimeCubit.dart';
import 'package:ayuprep/features/leaderBoard/cubit/leaderBoardDailyCubit.dart';
import 'package:ayuprep/features/leaderBoard/cubit/leaderBoardMonthlyCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/ui/styles/colors.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class LeaderBoardScreen extends StatefulWidget {
  @override
  _LeaderBoardScreen createState() => _LeaderBoardScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(providers: [
              BlocProvider<LeaderBoardMonthlyCubit>(
                  create: (context) => LeaderBoardMonthlyCubit()),
              BlocProvider<LeaderBoardDailyCubit>(
                  create: (context) => LeaderBoardDailyCubit()),
              BlocProvider<LeaderBoardAllTimeCubit>(
                  create: (context) => LeaderBoardAllTimeCubit(
                      // LeaderBoardRepository(),
                      )),
            ], child: LeaderBoardScreen()));
  }
}

class _LeaderBoardScreen extends State<LeaderBoardScreen> {
  ScrollController controllerM = ScrollController();
  ScrollController controllerA = ScrollController();
  ScrollController controllerD = ScrollController();
  @override
  void initState() {
    controllerM.addListener(scrollListenerM);
    controllerA.addListener(scrollListenerA);
    controllerD.addListener(scrollListenerD);
    Future.delayed(Duration.zero, () {
      context
          .read<LeaderBoardDailyCubit>()
          .fetchLeaderBoard("20", context.read<UserDetailsCubit>().getUserId());
    });
    Future.delayed(Duration.zero, () {
      context
          .read<LeaderBoardMonthlyCubit>()
          .fetchLeaderBoard("20", context.read<UserDetailsCubit>().getUserId());
    });
    Future.delayed(Duration.zero, () {
      context
          .read<LeaderBoardAllTimeCubit>()
          .fetchLeaderBoard("20", context.read<UserDetailsCubit>().getUserId());
    });

    super.initState();
  }

  @override
  void dispose() {
    controllerM.removeListener(scrollListenerM);
    controllerA.removeListener(scrollListenerA);
    controllerD.removeListener(scrollListenerD);
    super.dispose();
  }

  scrollListenerM() {
    if (controllerM.position.maxScrollExtent == controllerM.offset) {
      if (context.read<LeaderBoardMonthlyCubit>().hasMoreData()) {
        context.read<LeaderBoardMonthlyCubit>().fetchMoreLeaderBoardData(
            "20", context.read<UserDetailsCubit>().getUserId());
      }
    }
  }

  scrollListenerA() {
    if (controllerA.position.maxScrollExtent == controllerA.offset) {
      if (context.read<LeaderBoardAllTimeCubit>().hasMoreData()) {
        context.read<LeaderBoardAllTimeCubit>().fetchMoreLeaderBoardData(
            "20", context.read<UserDetailsCubit>().getUserId());
      }
    }
  }

  scrollListenerD() {
    if (controllerD.position.maxScrollExtent == controllerD.offset) {
      if (context.read<LeaderBoardDailyCubit>().hasMoreData()) {
        context.read<LeaderBoardDailyCubit>().fetchMoreLeaderBoardData(
            "20", context.read<UserDetailsCubit>().getUserId());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: CustomBackButton(
          iconColor: Theme.of(context).primaryColor,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
                UiUtils.getImagePath(
                  "leaderboard_dark.svg",
                ),
                height: MediaQuery.of(context).size.height * .025,
                width: MediaQuery.of(context).size.width * .03),
            SizedBox(width: 2),
            Text(
              AppLocalization.of(context)!
                  .getTranslatedValues("leaderboardLbl")!,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
      body: topDesign(),
    );
  }

  Widget topDesign() {
    return Stack(children: [
      PageBackgroundGradientContainer(),
      DefaultTabController(
          length: 3,
          child: Column(children: [
            TabBar(
              indicatorWeight: 0,
              indicatorPadding: EdgeInsets.all(10),
              labelColor: backgroundColor,
              unselectedLabelColor: Theme.of(context).colorScheme.secondary,
              labelStyle: Theme.of(context).textTheme.subtitle1,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Theme.of(context).primaryColor),
              tabs: [
                Tab(
                    text: AppLocalization.of(context)!
                        .getTranslatedValues("dailyLbl")),
                Tab(
                    text: AppLocalization.of(context)!
                        .getTranslatedValues("monthLbl")),
                Tab(
                    text: AppLocalization.of(context)!
                        .getTranslatedValues("allTimeLbl")),
              ],
            ),
            Expanded(
              child: TabBarView(children: [
                dailyShow(),
                monthlyShow(),
                allTimeShow(),
              ]),
            )
          ]))
    ]);
  }

  Widget dailyShow() {
    return BlocConsumer<LeaderBoardDailyCubit, LeaderBoardDailyState>(
        bloc: context.read<LeaderBoardDailyCubit>(),
        listener: (context, state) {
          if (state is LeaderBoardDailyFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              //
              UiUtils.showAlreadyLoggedInDialog(
                context: context,
              );
              return;
            }
          }
        },
        builder: (context, state) {
          if (state is LeaderBoardDailyProgress ||
              state is LeaderBoardDailyInitial) {
            return Center(
                child: CircularProgressContainer(
              useWhiteLoader: false,
            ));
          }
          if (state is LeaderBoardDailyFailure) {
            return ErrorContainer(
              showBackButton: false,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage))!,
              onTapRetry: () {
                context.read<LeaderBoardDailyCubit>().fetchMoreLeaderBoardData(
                    "20", context.read<UserDetailsCubit>().getUserId());
              },
              showErrorImage: true,
              errorMessageColor: Theme.of(context).primaryColor,
            );
          }
          final dailyList =
              (state as LeaderBoardDailySuccess).leaderBoardDetails;
          final hasMore = state.hasMore;
          return Container(
              height: MediaQuery.of(context).size.height * .6,
              child: Column(children: [
                circleProfile(dailyList),
                leaderBoardList(dailyList, controllerD, hasMore),
                //Spacer(),
                LeaderBoardDailyCubit.scoreD == "0"
                    ? Container()
                    : myRank(
                        LeaderBoardDailyCubit.rankD,
                        LeaderBoardDailyCubit.profileD,
                        LeaderBoardDailyCubit.scoreD,
                      )
              ]));
        });
  }

  Widget monthlyShow() {
    return BlocConsumer<LeaderBoardMonthlyCubit, LeaderBoardMonthlyState>(
        bloc: context.read<LeaderBoardMonthlyCubit>(),
        listener: (context, state) {
          if (state is LeaderBoardMonthlyFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              //
              UiUtils.showAlreadyLoggedInDialog(
                context: context,
              );
              return;
            }
          }
        },
        builder: (context, state) {
          if (state is LeaderBoardMonthlyProgress ||
              state is LeaderBoardAllTimeInitial) {
            return Center(
              child: CircularProgressContainer(
                useWhiteLoader: false,
              ),
            );
          }
          if (state is LeaderBoardMonthlyFailure) {
            return ErrorContainer(
              showBackButton: false,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage))!,
              onTapRetry: () {
                context
                    .read<LeaderBoardMonthlyCubit>()
                    .fetchMoreLeaderBoardData(
                        "20", context.read<UserDetailsCubit>().getUserId());
              },
              showErrorImage: true,
              errorMessageColor: Theme.of(context).primaryColor,
            );
          }
          final monthlyList =
              (state as LeaderBoardMonthlySuccess).leaderBoardDetails;
          final hasMore = state.hasMore;
          return Container(
              height: MediaQuery.of(context).size.height * .6,
              child: Column(children: [
                circleProfile(monthlyList),
                leaderBoardList(monthlyList, controllerM, hasMore),
                LeaderBoardMonthlyCubit.scoreM == "0"
                    ? Container()
                    : myRank(
                        LeaderBoardMonthlyCubit.rankM,
                        LeaderBoardMonthlyCubit.profileM,
                        LeaderBoardMonthlyCubit.scoreM)
              ]));
        });
  }

  Widget allTimeShow() {
    return BlocConsumer<LeaderBoardAllTimeCubit, LeaderBoardAllTimeState>(
        bloc: context.read<LeaderBoardAllTimeCubit>(),
        listener: (context, state) {
          if (state is LeaderBoardAllTimeFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              //
              UiUtils.showAlreadyLoggedInDialog(
                context: context,
              );
              return;
            }
          }
        },
        builder: (context, state) {
          if (state is LeaderBoardAllTimeProgress ||
              state is LeaderBoardAllTimeInitial) {
            return Center(
              child: CircularProgressContainer(
                useWhiteLoader: false,
              ),
            );
          }
          if (state is LeaderBoardAllTimeFailure) {
            return ErrorContainer(
              showBackButton: false,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage))!,
              onTapRetry: () {
                context
                    .read<LeaderBoardAllTimeCubit>()
                    .fetchMoreLeaderBoardData(
                        "20", context.read<UserDetailsCubit>().getUserId());
              },
              showErrorImage: true,
              errorMessageColor: Theme.of(context).primaryColor,
            );
          }
          final allTimeList =
              (state as LeaderBoardAllTimeSuccess).leaderBoardDetails;
          final hasMore = state.hasMore;
          return Container(
              height: MediaQuery.of(context).size.height * .6,
              child: Column(children: [
                circleProfile(allTimeList),
                leaderBoardList(allTimeList, controllerA, hasMore),
                LeaderBoardAllTimeCubit.scoreA == "0"
                    ? Container()
                    : myRank(
                        LeaderBoardAllTimeCubit.rankA,
                        LeaderBoardAllTimeCubit.profileA,
                        LeaderBoardAllTimeCubit.scoreA)
              ]));
        });
  }

  Widget circleProfile(List circleList) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .28,
        child: LayoutBuilder(builder: (context, constraints) {
          double profileRadiusPercentage = 0.0;
          if (constraints.maxHeight <
              UiUtils.profileHeightBreakPointResultScreen) {
            profileRadiusPercentage = 0.175;
          } else {
            profileRadiusPercentage = 0.2;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              circleList.length > 2
                  ? Container(
                      padding: EdgeInsetsDirectional.only(
                          top: MediaQuery.of(context).size.height * .07),
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * .115,
                            width: MediaQuery.of(context).size.width * .21,
                            child: Stack(
                              children: [
                                Container(
                                    height:
                                        MediaQuery.of(context).size.height * .1,
                                    width:
                                        MediaQuery.of(context).size.width * .21,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 1.0,
                                            color: Theme.of(context)
                                                .backgroundColor)),
                                    child: CircleAvatar(
                                        radius: constraints.maxHeight *
                                            (profileRadiusPercentage - 0.0535),
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          circleList[2]['profile'],
                                        ))),
                                PositionedDirectional(
                                  start:
                                      MediaQuery.of(context).size.width * .06,
                                  top: MediaQuery.of(context).size.height * .07,
                                  child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Text(
                                        "2\u207f\u1d48",
                                        style:
                                            TextStyle(color: backgroundColor),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * .2,
                              child: Center(
                                child: Text(
                                  circleList[2]['name']!.isNotEmpty
                                      ? circleList[2]['name']!
                                      : "...",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width * .15,
                              child: Center(
                                child: Text(
                                  circleList[2]['score']!.isNotEmpty
                                      ? circleList[2]['score']!
                                      : "...",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              )),
                        ],
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height * .1,
                      width: MediaQuery.of(context).size.width * .2,
                      // decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle, border: Border.all(width: 1.0, color: Theme.of(context).backgroundColor)),
                    ),
              circleList.length > 1
                  ? Container(
                      child: Column(
                        children: [
                          SvgPicture.asset(
                              UiUtils.getImagePath("Rankone_icon.svg"),
                              height: MediaQuery.of(context).size.height * .025,
                              color: Theme.of(context).primaryColor,
                              width: MediaQuery.of(context).size.width * .02),
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            height: MediaQuery.of(context).size.height * .16,
                            width: MediaQuery.of(context).size.width * .26,
                            child: Stack(
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * .14,
                                  width:
                                      MediaQuery.of(context).size.width * .26,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 3.0,
                                          color:
                                              Theme.of(context).primaryColor)),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: CircleAvatar(
                                        radius: constraints.maxHeight *
                                            (profileRadiusPercentage - 0.0535),
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          circleList[1]['profile']!,
                                        )),
                                  ),
                                ),
                                PositionedDirectional(
                                  start:
                                      MediaQuery.of(context).size.width * .08,
                                  top: MediaQuery.of(context).size.height * .11,
                                  child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Text(
                                        "1\u02e2\u1d57",
                                        style:
                                            TextStyle(color: backgroundColor),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * .2,
                              child: Center(
                                child: Text(
                                  circleList[1]['name']!.isNotEmpty
                                      ? circleList[1]['name']!
                                      : "...",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width * .15,
                              child: Center(
                                child: Text(
                                  circleList[1]['score']!.isNotEmpty
                                      ? circleList[1]['score']!
                                      : "...",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              )),
                        ],
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height * .1,
                      width: MediaQuery.of(context).size.width * .2,
                      // decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle, border: Border.all(width: 1.0, color: Theme.of(context).backgroundColor)),
                    ),
              circleList.length > 3
                  ? Container(
                      padding: EdgeInsetsDirectional.only(
                          top: MediaQuery.of(context).size.height * .07),
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * .115,
                            width: MediaQuery.of(context).size.width * .22,
                            child: Stack(
                              children: [
                                Container(
                                    height:
                                        MediaQuery.of(context).size.height * .1,
                                    width:
                                        MediaQuery.of(context).size.width * .22,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 1.0,
                                            color: Theme.of(context)
                                                .backgroundColor)),
                                    child: CircleAvatar(
                                        radius: constraints.maxHeight *
                                            (profileRadiusPercentage - 0.0535),
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          circleList[3]['profile']!,
                                        ))),
                                PositionedDirectional(
                                    start:
                                        MediaQuery.of(context).size.width * .06,
                                    top: MediaQuery.of(context).size.height *
                                        .07,
                                    child: CircleAvatar(
                                        radius: 15,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        child: Text(
                                          "3\u02b3\u1d48",
                                          style:
                                              TextStyle(color: backgroundColor),
                                        ))),
                              ],
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * .2,
                              child: Center(
                                child: Text(
                                  circleList[3]['name']!.isNotEmpty
                                      ? circleList[3]['name']!
                                      : "...",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width * .15,
                              child: Center(
                                child: Text(
                                  circleList[3]['score']!.isNotEmpty
                                      ? circleList[3]['score']!
                                      : "...",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              )),
                        ],
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height * .1,
                      width: MediaQuery.of(context).size.width * .22,
                      // decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle, border: Border.all(width: 1.0, color: Theme.of(context).backgroundColor)),
                    )
            ],
          );
        }));
  }

  Widget leaderBoardList(
      List leaderBoardList, ScrollController controller, bool hasMore) {
    return Expanded(
        child: Container(
      height: MediaQuery.of(context).size.height * .45,
      padding: EdgeInsetsDirectional.only(
          start: MediaQuery.of(context).size.width * .02,
          end: MediaQuery.of(context).size.width * .02),
      child: ListView.builder(
        controller: controller,
        shrinkWrap: true,
        itemCount: /*(offset < totals) ? leaderBoardList.length + 1 : */ leaderBoardList
            .length,
        itemBuilder: (BuildContext context, int index) {
          return index > 3
              ? (hasMore && index == (leaderBoardList.length - 1))
                  ? Center(
                      child: CircularProgressContainer(
                      useWhiteLoader: false,
                    ))
                  : Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              top: MediaQuery.of(context).size.height * .01,
                            ),
                            child: Column(children: <Widget>[
                              Text(
                                UiUtils.formatNumber(
                                    int.parse(index.toString())),
                                //  "$index",maxLines: 1,
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_up,
                                  color: Theme.of(context).primaryColor)
                            ]),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Card(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35.0),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding:
                                  EdgeInsetsDirectional.only(end: 20),
                              title: Text(
                                leaderBoardList[index]['name'] ?? "",
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: Container(
                                width: MediaQuery.of(context).size.width * .12,
                                height: MediaQuery.of(context).size.height * .3,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(leaderBoardList[index]
                                              ['profile'] ??
                                          ""),
                                      fit: BoxFit.cover),
                                ),
                              ),
                              trailing: Container(
                                width: MediaQuery.of(context).size.width * .1,
                                child: Text(
                                  UiUtils.formatNumber(int.parse(
                                      leaderBoardList[index]['score'] ?? "0")),
                                  // leaderBoardList[index]['score'] ?? "",
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
              : Container();
        },
      ),
    ));
  }

  Widget myRank(String rank, String profile, String score) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: ListTile(
          title: Text(
            AppLocalization.of(context)!.getTranslatedValues(myRankKey)!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: backgroundColor),
          ),
          leading: Wrap(children: [
            Container(
              width: MediaQuery.of(context).size.width * .08,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * .02),
              child: Text(
                rank,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: backgroundColor),
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height * .06,
                width: MediaQuery.of(context).size.width * .13,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 1.0, color: Theme.of(context).backgroundColor),
                    image: new DecorationImage(
                        fit: BoxFit.fill, image: NetworkImage(profile)))),
          ]),
          trailing: Container(
            height: MediaQuery.of(context).size.height * .06,
            width: MediaQuery.of(context).size.width * .25,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.0),
                  topLeft: Radius.circular(50.0),
                  bottomRight: Radius.circular(20.0),
                  topRight: Radius.circular(20.0)),
            ),
            child: Center(
                child: Text(
              score,
              style: TextStyle(color: Theme.of(context).backgroundColor),
            )),
          )),
    );
  }
}
