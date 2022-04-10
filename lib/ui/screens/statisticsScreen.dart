import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/auth/cubits/authCubit.dart';

import 'package:ayuprep/features/badges/cubits/badgesCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/profileManagement/models/userProfile.dart';
import 'package:ayuprep/features/statistic/cubits/statisticsCubit.dart';
import 'package:ayuprep/features/statistic/models/statisticModel.dart';
import 'package:ayuprep/features/statistic/statisticRepository.dart';
import 'package:ayuprep/ui/widgets/badgesIconContainer.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';

import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/ui/widgets/roundedAppbar.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsScreen extends StatefulWidget {
  StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();

  static Route<StatisticsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<StatisticCubit>(
            child: StatisticsScreen(),
            create: (_) => StatisticCubit(StatisticRepository())));
  }
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final statisticsDetailsContainerHeightPercentage = 0.145;
  final statisticsDetailsContainerBorderRadius = 20.0;
  final statisticsDetailsTitleFontsize = 16.0;
  final showTotalBadgesCounter = 4;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context
          .read<StatisticCubit>()
          .getStatisticWithBattle(context.read<UserDetailsCubit>().getUserId());
    });
  }

  Widget _buildCollectedBadgesContainer() {
    return BlocBuilder<BadgesCubit, BadgesState>(
      bloc: context.read<BadgesCubit>(),
      builder: (context, state) {
        final child = state is BadgesFetchSuccess
            ? context.read<BadgesCubit>().getUnlockedBadges().isEmpty
                ? Container()
                : Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            AppLocalization.of(context)!
                                .getTranslatedValues(collectedBadgesKey)!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontSize: statisticsDetailsTitleFontsize),
                          ),
                          Spacer(),
                          context
                                      .read<BadgesCubit>()
                                      .getUnlockedBadges()
                                      .length >
                                  showTotalBadgesCounter
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(Routes.badges);
                                  },
                                  child: Text(
                                    AppLocalization.of(context)!
                                        .getTranslatedValues(viewAllKey)!,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            width: 5.0,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: (context
                                          .read<BadgesCubit>()
                                          .getUnlockedBadges()
                                          .length <
                                      showTotalBadgesCounter
                                  ? context
                                      .read<BadgesCubit>()
                                      .getUnlockedBadges()
                                  : context
                                      .read<BadgesCubit>()
                                      .getUnlockedBadges()
                                      .sublist(0, showTotalBadgesCounter))
                              .map(
                                (badge) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: BadgesIconContainer(
                                    addTopPadding: false,
                                    badge: badge,
                                    constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context)
                                                .size
                                                .height *
                                            statisticsDetailsContainerHeightPercentage,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                (0.2)),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        height: MediaQuery.of(context).size.height *
                            (statisticsDetailsContainerHeightPercentage),
                        decoration: BoxDecoration(
                            boxShadow: [
                              UiUtils.buildBoxShadow(
                                  blurRadius: 3.0,
                                  color: Colors.black.withOpacity(0.2),
                                  offset: Offset(2.5, 2.5)),
                            ],
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(
                                statisticsDetailsContainerBorderRadius)),
                      ),
                    ],
                  )
            : Container();

        return AnimatedSwitcher(
            child: child, duration: Duration(milliseconds: 500));
      },
    );
  }

  //Details in column form data and label of the data
  Widget _buildStatisticsDetailsContainer(
      {required String data, required String dataLabel}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: statisticsDetailsTitleFontsize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          dataLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizDetailsContainer() {
    UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 5.0,
            ),
            Text(
              AppLocalization.of(context)!.getTranslatedValues(quizDetailsKey)!,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontSize: statisticsDetailsTitleFontsize),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          child: LayoutBuilder(builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: constraints.maxHeight * (0.65),
                  width: constraints.maxWidth * (0.3),
                  child: _buildStatisticsDetailsContainer(
                      data: UiUtils.formatNumber(
                          int.parse(userProfile.allTimeRank!)),
                      dataLabel: AppLocalization.of(context)!
                          .getTranslatedValues(rankLbl)!),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                    right: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    left: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  )),
                  height: constraints.maxHeight * (0.65),
                  width: constraints.maxWidth * (0.3),
                  child: _buildStatisticsDetailsContainer(
                      data: UiUtils.formatNumber(int.parse(userProfile.coins!)),
                      dataLabel: AppLocalization.of(context)!
                          .getTranslatedValues(coinsLbl)!),
                ),
                Container(
                  height: constraints.maxHeight * (0.65),
                  width: constraints.maxWidth * (0.3),
                  child: _buildStatisticsDetailsContainer(
                      data: UiUtils.formatNumber(
                          int.parse(userProfile.allTimeScore!)),
                      dataLabel: AppLocalization.of(context)!
                          .getTranslatedValues(scoreLbl)!),
                ),
              ],
            );
          }),
          height: MediaQuery.of(context).size.height *
              (statisticsDetailsContainerHeightPercentage),
          decoration: BoxDecoration(
              boxShadow: [
                UiUtils.buildBoxShadow(
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(2.5, 2.5)),
              ],
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(
                  statisticsDetailsContainerBorderRadius)),
        ),
      ],
    );
  }

  Widget _buildQuestionDetailsContainer() {
    StatisticModel statisticModel =
        context.read<StatisticCubit>().getStatisticsDetails();
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 5.0,
            ),
            Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(questionDetailsKey)!,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontSize: statisticsDetailsTitleFontsize),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          child: LayoutBuilder(builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: constraints.maxHeight * (0.65),
                  width: constraints.maxWidth * (0.3),
                  child: _buildStatisticsDetailsContainer(
                      data: statisticModel.answeredQuestions,
                      dataLabel: AppLocalization.of(context)!
                          .getTranslatedValues(attemptedLbl)!),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                    right: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    left: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  )),
                  height: constraints.maxHeight * (0.65),
                  width: constraints.maxWidth * (0.3),
                  child: _buildStatisticsDetailsContainer(
                      data: statisticModel.correctAnswers,
                      dataLabel: AppLocalization.of(context)!
                          .getTranslatedValues(correctKey)!),
                ),
                Container(
                  height: constraints.maxHeight * (0.65),
                  width: constraints.maxWidth * (0.3),
                  child: _buildStatisticsDetailsContainer(
                      data: (int.parse(statisticModel.answeredQuestions) -
                              int.parse(statisticModel.correctAnswers))
                          .toString(),
                      dataLabel: AppLocalization.of(context)!
                          .getTranslatedValues(incorrectKey)!),
                ),
              ],
            );
          }),
          height: MediaQuery.of(context).size.height *
              (statisticsDetailsContainerHeightPercentage),
          decoration: BoxDecoration(
              boxShadow: [
                UiUtils.buildBoxShadow(
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(2.5, 2.5)),
              ],
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(
                  statisticsDetailsContainerBorderRadius)),
        ),
      ],
    );
  }

  Widget _buildBattleStatisticsContainer() {
    StatisticModel statisticModel =
        context.read<StatisticCubit>().getStatisticsDetails();
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 5.0,
            ),
            Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(battleStatisticsKey)!,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontSize: statisticsDetailsTitleFontsize),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          child: LayoutBuilder(builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: constraints.maxHeight * (0.65),
                  width: constraints.maxWidth * (0.3),
                  child: _buildStatisticsDetailsContainer(
                      data: statisticModel.calculatePlayedBattles().toString(),
                      dataLabel: AppLocalization.of(context)!
                          .getTranslatedValues(playedKey)!),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                    right: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    left: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  )),
                  height: constraints.maxHeight * (0.65),
                  width: constraints.maxWidth * (0.3),
                  child: _buildStatisticsDetailsContainer(
                      data: statisticModel.battleVictories,
                      dataLabel: AppLocalization.of(context)!
                          .getTranslatedValues(wonKey)!),
                ),
                Container(
                  height: constraints.maxHeight * (0.65),
                  width: constraints.maxWidth * (0.3),
                  child: _buildStatisticsDetailsContainer(
                      data: statisticModel.battleLoose,
                      dataLabel: AppLocalization.of(context)!
                          .getTranslatedValues(lostKey)!),
                ),
              ],
            );
          }),
          height: MediaQuery.of(context).size.height *
              (statisticsDetailsContainerHeightPercentage),
          decoration: BoxDecoration(
              boxShadow: [
                UiUtils.buildBoxShadow(
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(2.5, 2.5)),
              ],
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(
                  statisticsDetailsContainerBorderRadius)),
        ),
      ],
    );
  }

  Widget _buildStatisticsContainer(
      {required bool showQuestionAndBattleStatistics}) {
    UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();

    return SingleChildScrollView(
      padding: EdgeInsets.only(
          right: MediaQuery.of(context).size.width * (0.05),
          left: MediaQuery.of(context).size.width * (0.05),
          top: MediaQuery.of(context).size.height *
              (UiUtils.appBarHeightPercentage)),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * (0.18)),
              border: Border.all(
                color: Theme.of(context).primaryColor,
              ),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          CachedNetworkImageProvider(userProfile.profileUrl!)),
                  shape: BoxShape.circle),
            ),
            height: MediaQuery.of(context).size.width * (0.36),
            width: MediaQuery.of(context).size.width * (0.36),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.02),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "${AppLocalization.of(context)!.getTranslatedValues(helloKey)!}, ${userProfile.name}",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              context.read<AuthCubit>().getAuthProvider() == AuthProvider.mobile
                  ? userProfile.mobileNumber!
                  : userProfile.email!,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (0.125),
            ),
            child: Divider(
              thickness: 1.5,
              height: 30.0,
              color: Theme.of(context).primaryColor,
            ),
          ),
          _buildCollectedBadgesContainer(),
          SizedBox(
            height: 20.0,
          ),
          _buildQuizDetailsContainer(),
          SizedBox(
            height: 20.0,
          ),
          showQuestionAndBattleStatistics
              ? Column(
                  children: [
                    _buildQuestionDetailsContainer(),
                    SizedBox(
                      height: 20.0,
                    ),
                    _buildBattleStatisticsContainer(),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                )
              : Container()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          BlocConsumer<StatisticCubit, StatisticState>(
              listener: (context, state) {
            if (state is StatisticFetchFailure) {
              if (state.errorMessageCode == unauthorizedAccessCode) {
                UiUtils.showAlreadyLoggedInDialog(context: context);
              }
            }
          }, builder: (context, state) {
            if (state is StatisticFetchSuccess) {
              return Align(
                alignment: Alignment.topCenter,
                child: _buildStatisticsContainer(
                  showQuestionAndBattleStatistics: true,
                ),
              );
            }
            if (state is StatisticFetchFailure) {
              return Align(
                alignment: Alignment.topCenter,
                child: _buildStatisticsContainer(
                  showQuestionAndBattleStatistics: false,
                ),
              );
            }

            return Center(
              child: CircularProgressContainer(
                useWhiteLoader: false,
              ),
            );
          }),
          Align(
            alignment: Alignment.topCenter,
            child: RoundedAppbar(
                title: AppLocalization.of(context)!
                    .getTranslatedValues(statisticsLabelKey)!),
          ),
        ],
      ),
    );
  }
}
