import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/profileManagement/profileManagementRepository.dart';
import 'package:ayuprep/features/quiz/cubits/contestCubit.dart';
import 'package:ayuprep/features/quiz/models/contest.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/quiz/quizRepository.dart';
import 'package:ayuprep/ui/styles/colors.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class ContestScreen extends StatefulWidget {
  @override
  _ContestScreen createState() => _ContestScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
              BlocProvider<ContestCubit>(
                create: (_) => ContestCubit(QuizRepository()),
              ),
              BlocProvider<UpdateScoreAndCoinsCubit>(
                create: (_) =>
                    UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
              ),
            ], child: ContestScreen()));
  }
}

class _ContestScreen extends State<ContestScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context
        .read<ContestCubit>()
        .getContest(context.read<UserDetailsCubit>().getUserId());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).backgroundColor,
                leading: CustomBackButton(
                  iconColor: Theme.of(context).primaryColor,
                ),
                centerTitle: true,
                title: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues("contestLbl")!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0),
                  ),
                ),
                bottom: TabBar(
                    labelPadding: EdgeInsetsDirectional.only(
                        top: MediaQuery.of(context).size.height * .03),
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.7),
                    labelStyle: Theme.of(context).textTheme.subtitle1,
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 5,
                    tabs: [
                      Tab(
                          text: AppLocalization.of(context)!
                              .getTranslatedValues("pastLbl")),
                      Tab(
                          text: AppLocalization.of(context)!
                              .getTranslatedValues("liveLbl")),
                      Tab(
                          text: AppLocalization.of(context)!
                              .getTranslatedValues("upcomingLbl")),
                    ])),
            body: Stack(
              children: [
                PageBackgroundGradientContainer(),
                BlocConsumer<ContestCubit, ContestState>(
                    bloc: context.read<ContestCubit>(),
                    listener: (context, state) {
                      if (state is ContestFailure) {
                        if (state.errorMessage == unauthorizedAccessCode) {
                          //
                          UiUtils.showAlreadyLoggedInDialog(
                            context: context,
                          );
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is ContestProgress || state is ContestInitial) {
                        return Center(
                            child: CircularProgressContainer(
                          useWhiteLoader: false,
                        ));
                      }
                      if (state is ContestFailure) {
                        print(state.errorMessage);
                        return ErrorContainer(
                          errorMessage: AppLocalization.of(context)!
                              .getTranslatedValues(
                                  convertErrorCodeToLanguageKey(
                                      state.errorMessage)),
                          onTapRetry: () {
                            context.read<ContestCubit>().getContest(
                                context.read<UserDetailsCubit>().getUserId());
                          },
                          showErrorImage: true,
                          errorMessageColor: Theme.of(context).primaryColor,
                        );
                      }
                      final contestList = (state as ContestSuccess).contestList;
                      return TabBarView(children: [
                        past(contestList.past),
                        live(contestList.live),
                        future(contestList.upcoming)
                      ]);
                    })
              ],
            ),
          );
        }));
  }

  Widget past(Contest data) {
    return data.errorMessage.isNotEmpty
        ? ErrorContainer(
            showBackButton: false,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(data.errorMessage))!,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () {
              context
                  .read<ContestCubit>()
                  .getContest(context.read<UserDetailsCubit>().getUserId());
            },
            showErrorImage: true)
        : ListView.builder(
            shrinkWrap: false,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  height: data.contestDetails[index].showDescription == false
                      ? MediaQuery.of(context).size.height * .3
                      : MediaQuery.of(context).size.height * .4,
                  margin: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      boxShadow: [
                        UiUtils.buildBoxShadow(
                            offset: Offset(5, 5), blurRadius: 10.0),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: contestDesign(data, index, 0));
            });
  }

  Widget live(Contest data) {
    return data.errorMessage.isNotEmpty
        ? ErrorContainer(
            showBackButton: false,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(data.errorMessage))!,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () {
              context
                  .read<ContestCubit>()
                  .getContest(context.read<UserDetailsCubit>().getUserId());
            },
            showErrorImage: true)
        : ListView.builder(
            shrinkWrap: false,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  height: data.contestDetails[index].showDescription == false
                      ? MediaQuery.of(context).size.height * .3
                      : MediaQuery.of(context).size.height * .4,
                  margin: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      boxShadow: [
                        UiUtils.buildBoxShadow(
                            offset: Offset(5, 5), blurRadius: 10.0),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: contestDesign(data, index, 1));
            });
  }

  Widget future(Contest data) {
    return data.errorMessage.isNotEmpty
        ? ErrorContainer(
            showBackButton: false,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(data.errorMessage))!,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () {
              context
                  .read<ContestCubit>()
                  .getContest(context.read<UserDetailsCubit>().getUserId());
            },
            showErrorImage: true)
        : ListView.builder(
            shrinkWrap: false,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  height: data.contestDetails[index].showDescription == false
                      ? MediaQuery.of(context).size.height * .3
                      : MediaQuery.of(context).size.height * .4,
                  margin: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      boxShadow: [
                        UiUtils.buildBoxShadow(
                            offset: Offset(5, 5), blurRadius: 10.0),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: contestDesign(data, index, 2));
            });
  }

  Widget contestDesign(dynamic data, int index, int type) {
    return Column(
      children: [
        Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: CachedNetworkImage(
                placeholder: (context, _) {
                  return Center(
                    child: CircularProgressContainer(
                      useWhiteLoader: false,
                    ),
                  );
                },
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  );
                },
                errorWidget: (context, image, error) {
                  print(error.toString());
                  return Center(
                    child: Icon(
                      Icons.error,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .15,
                imageUrl: data.contestDetails[index].image.toString(),
              ),
            )),
        Divider(
          color: Theme.of(context).primaryColor,
          height: 0.1,
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Theme.of(context)
                .backgroundColor, //height: MediaQuery.of(context).size.height*.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: Text(
                    data.contestDetails[index].name.toString(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        data.contestDetails[index].showDescription =
                            !data.contestDetails[index].showDescription!;
                      });
                    },
                    child: Icon(
                      data.contestDetails[index].showDescription!
                          ? Icons.keyboard_arrow_up_sharp
                          : Icons.keyboard_arrow_down_sharp,
                      color: Theme.of(context).primaryColor,
                      size: 40,
                    )),
              ],
            ),
          ),
        ),
        Divider(
          color: Theme.of(context).primaryColor,
          height: 0.1,
        ),
        data.contestDetails[index].showDescription!
            ? Container(
                padding: EdgeInsets.only(left: 10),
                color: Theme.of(context).backgroundColor,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Text(
                      data.contestDetails[index].description!,
                      style: TextStyle(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.6),
                          fontWeight: FontWeight.bold),
                    )))
            : Container(),
        Divider(
          color: Theme.of(context).primaryColor,
          height: 0.1,
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("entryFeesLbl")!,
                        style: TextStyle(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.6),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data.contestDetails[index].entry.toString(),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("endsOnLbl")!,
                        style: TextStyle(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.6),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data.contestDetails[index].endDate.toString(),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("playersLbl")!,
                        style: TextStyle(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.6),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data.contestDetails[index].participants.toString(),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    type == 0
                        ? TextButton(
                            style: TextButton.styleFrom(
                              primary: Theme.of(context).backgroundColor,
                              backgroundColor: Theme.of(context).primaryColor,
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1),
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * .1,
                                  MediaQuery.of(context).size.height * .05),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                  Routes.contestLeaderboard,
                                  arguments: {
                                    "contestId": data.contestDetails[index].id
                                  });
                            },
                            child: Text(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("leaderboardLbl")!,
                            ),
                          )
                        : type == 1
                            ? Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 10.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    onPrimary:
                                        Theme.of(context).backgroundColor,
                                    primary: Theme.of(context).primaryColor,
                                    side: BorderSide(
                                        color: primaryColor, width: 1),
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width * .2,
                                        MediaQuery.of(context).size.height *
                                            .05),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (int.parse(context
                                            .read<UserDetailsCubit>()
                                            .getCoins()!) >=
                                        int.parse(data
                                            .contestDetails[index].entry!)) {
                                      context
                                          .read<UpdateScoreAndCoinsCubit>()
                                          .updateCoins(
                                            context
                                                .read<UserDetailsCubit>()
                                                .getUserId(),
                                            int.parse(data
                                                .contestDetails[index].entry!),
                                            false,
                                            AppLocalization.of(context)!
                                                    .getTranslatedValues(
                                                        playedContestKey) ??
                                                "-",
                                          );

                                      context
                                          .read<UserDetailsCubit>()
                                          .updateCoins(
                                              addCoin: false,
                                              coins: int.parse(data
                                                  .contestDetails[index]
                                                  .entry!));
                                      Navigator.of(context)
                                          .pushReplacementNamed(Routes.quiz,
                                              arguments: {
                                            "numberOfPlayer": 1,
                                            "quizType": QuizTypes.contest,
                                            "contestId":
                                                data.contestDetails[index].id,
                                            "quizName": "Contest"
                                          });
                                    } else {
                                      UiUtils.setSnackbar(
                                          AppLocalization.of(context)!
                                              .getTranslatedValues(
                                                  "noCoinsMsg")!,
                                          context,
                                          false);
                                    }
                                  },
                                  child: Text(
                                    AppLocalization.of(context)!
                                        .getTranslatedValues("playLbl")!,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).backgroundColor),
                                  ),
                                ),
                              )
                            : Container()
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
