import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/cubits/getContestLeaderboardCubit.dart';
import 'package:ayuprep/features/quiz/quizRemoteDataSoure.dart';
import 'package:ayuprep/features/quiz/quizRepository.dart';
import 'package:ayuprep/ui/styles/colors.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class ContestLeaderBoardScreen extends StatefulWidget {
  final String? contestId;
  const ContestLeaderBoardScreen({Key? key, this.contestId}) : super(key: key);
  @override
  _ContestLeaderBoardScreen createState() => _ContestLeaderBoardScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<GetContestLeaderboardCubit>(
              create: (_) => GetContestLeaderboardCubit(QuizRepository()),
              child:
                  ContestLeaderBoardScreen(contestId: arguments!['contestId']),
            ));
  }
}

class _ContestLeaderBoardScreen extends State<ContestLeaderBoardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GetContestLeaderboardCubit>().getContestLeaderboard(
        userId: context.read<UserDetailsCubit>().getUserId(),
        contestId: widget.contestId);
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
              SizedBox(
                width: 5,
              ),
              Text(
                AppLocalization.of(context)!
                    .getTranslatedValues("contestLeaderBoardLbl")!,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            PageBackgroundGradientContainer(),
            leaderBoard(),
          ],
        ));
  }

  Widget leaderBoard() {
    return BlocConsumer<GetContestLeaderboardCubit, GetContestLeaderboardState>(
        bloc: context.read<GetContestLeaderboardCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is GetContestLeaderboardProgress ||
              state is GetContestLeaderboardInitial) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor)),
            );
          }
          if (state is GetContestLeaderboardFailure) {
            return ErrorContainer(
                errorMessage: state.errorMessage,
                onTapRetry: () {
                  context
                      .read<GetContestLeaderboardCubit>()
                      .getContestLeaderboard(
                          userId: context.read<UserDetailsCubit>().getUserId(),
                          contestId: widget.contestId);
                },
                showErrorImage: true);
          }
          final getContestLeaderboardList =
              (state as GetContestLeaderboardSuccess).getContestLeaderboardList;
          return Container(
              height: MediaQuery.of(context).size.height,
              child: Column(children: [
                Container(
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
                          getContestLeaderboardList.length > 1
                              ? Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: MediaQuery.of(context).size.height *
                                          .07),
                                  child: Column(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .115,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .22,
                                        child: Stack(
                                          children: [
                                            Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .1,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .22,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        width: 1.0,
                                                        color: Theme.of(context)
                                                            .backgroundColor)),
                                                child: CircleAvatar(
                                                    radius: constraints
                                                            .maxHeight *
                                                        (profileRadiusPercentage -
                                                            0.0535),
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                      getContestLeaderboardList[
                                                              1]
                                                          .profile!,
                                                    ))),
                                            Positioned(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .06,
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .07,
                                              child: CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  child: Text(
                                                    "2\u207f\u1d48",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .backgroundColor),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .2,
                                        child: Center(
                                          child: Text(
                                            getContestLeaderboardList[1].name ??
                                                "...",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ),
                                      ),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                          child: Center(
                                            child: Text(
                                              getContestLeaderboardList[1]
                                                      .score ??
                                                  "...",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          )),
                                    ],
                                  ),
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height * .1,
                                  width:
                                      MediaQuery.of(context).size.width * .22,
                                ),
                          Container(
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                    UiUtils.getImagePath("Rankone_icon.svg"),
                                    height: MediaQuery.of(context).size.height *
                                        .025,
                                    color: primaryColor,
                                    width: MediaQuery.of(context).size.width *
                                        .02),
                                Container(
                                  decoration:
                                      BoxDecoration(shape: BoxShape.circle),
                                  height:
                                      MediaQuery.of(context).size.height * .16,
                                  width:
                                      MediaQuery.of(context).size.width * .26,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .14,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .26,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                width: 3.0,
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: CircleAvatar(
                                              radius: constraints.maxHeight *
                                                  (profileRadiusPercentage -
                                                      0.0535),
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                getContestLeaderboardList[0]
                                                    .profile!,
                                              )),
                                        ),
                                      ),
                                      Positioned(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                .08,
                                        top:
                                            MediaQuery.of(context).size.height *
                                                .11,
                                        child: CircleAvatar(
                                            radius: 17,
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            child: Text(
                                              "1\u02e2\u1d57",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .backgroundColor),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * .2,
                                    child: Center(
                                      child: Text(
                                        getContestLeaderboardList[0].name ??
                                            "...",
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    )),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * .2,
                                    child: Center(
                                      child: Text(
                                        getContestLeaderboardList[0].score ??
                                            "...",
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          getContestLeaderboardList.length > 2
                              ? Container(
                                  padding: EdgeInsetsDirectional.only(
                                      top: MediaQuery.of(context).size.height *
                                          .07),
                                  child: Column(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .115,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .22,
                                        child: Stack(
                                          children: [
                                            Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .1,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .22,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        width: 1.0,
                                                        color: Theme.of(context)
                                                            .backgroundColor)),
                                                child: CircleAvatar(
                                                    radius: constraints
                                                            .maxHeight *
                                                        (profileRadiusPercentage -
                                                            0.0535),
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                      getContestLeaderboardList[
                                                                  2]
                                                              .profile ??
                                                          "",
                                                    ))),
                                            Positioned(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .06,
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .07,
                                                child: CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    child: Text(
                                                      "3\u02b3\u1d48",
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .backgroundColor),
                                                    ))),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                          child: Center(
                                            child: Text(
                                              getContestLeaderboardList[2]
                                                      .name ??
                                                  "...",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          )),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                          child: Center(
                                            child: Text(
                                              getContestLeaderboardList[2]
                                                      .score ??
                                                  "...",
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          )),
                                    ],
                                  ),
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height * .1,
                                  width:
                                      MediaQuery.of(context).size.width * .22,
                                )
                        ],
                      );
                    })),
                Container(
                  height: MediaQuery.of(context).size.height * .51,
                  padding: EdgeInsetsDirectional.only(start: 20, end: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: getContestLeaderboardList.length,
                    itemBuilder: (BuildContext context, int index) {
                      int i = index + 1;
                      return index > 2
                          ? Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                .01,
                                        start: 10),
                                    child: Column(children: <Widget>[
                                      Text(
                                        "$i",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Icon(Icons.arrow_drop_up,
                                          color: Theme.of(context).primaryColor)
                                    ]),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Card(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35.0),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      contentPadding:
                                          EdgeInsets.only(left: 0, right: 20),
                                      title: Text(
                                        getContestLeaderboardList[index].name!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      leading: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .12,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .3,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  getContestLeaderboardList[
                                                          index]
                                                      .profile!),
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      trailing: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .1,
                                        child: Text(
                                          UiUtils.formatNumber(int.parse(
                                              getContestLeaderboardList[index]
                                                      .score ??
                                                  "0")),
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
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: ListTile(
                      title: Text(
                        "My Rank",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: backgroundColor),
                      ),
                      leading: Wrap(children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .08,
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * .02),
                          child: Text(
                            QuizRemoteDataSource.rank,
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
                                    width: 1.0,
                                    color: Theme.of(context).backgroundColor),
                                image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                        QuizRemoteDataSource.profile)))),
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
                          QuizRemoteDataSource.score,
                          style: TextStyle(
                              color: Theme.of(context).backgroundColor),
                        )),
                      )),
                ),
              ]));
        });
  }
}
