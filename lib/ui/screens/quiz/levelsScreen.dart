import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/cubits/unlockedLevelCubit.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/quiz/quizRepository.dart';
import 'package:ayuprep/ui/widgets/bannerAdContainer.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class LevelsScreen extends StatefulWidget {
  final String maxLevel;
  final String categoryId;
  const LevelsScreen(
      {Key? key, required this.maxLevel, required this.categoryId})
      : super(key: key);

  @override
  _LevelsScreenState createState() => _LevelsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<UnlockedLevelCubit>(
              create: (_) => UnlockedLevelCubit(QuizRepository()),
              child: LevelsScreen(
                maxLevel: arguments['maxLevel'],
                categoryId: arguments['categoryId'],
              ),
            ));
  }
}

class _LevelsScreenState extends State<LevelsScreen> {
  @override
  void initState() {
    super.initState();
    getUnlockedLevelData();
  }

  void getUnlockedLevelData() {
    Future.delayed(Duration.zero, () {
      context.read<UnlockedLevelCubit>().fetchUnlockLevel(
            context.read<UserDetailsCubit>().getUserId(),
            widget.categoryId,
            "0",
          );
    });
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30, start: 20, end: 20),
      child: CustomBackButton(
        iconColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildLevels() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 75, start: 20, end: 20),
        child: BlocConsumer<UnlockedLevelCubit, UnlockedLevelState>(
          bloc: context.read<UnlockedLevelCubit>(),
          listener: (context, state) {
            if (state is UnlockedLevelFetchFailure) {
              if (state.errorMessage == unauthorizedAccessCode) {
                //
                UiUtils.showAlreadyLoggedInDialog(
                  context: context,
                );
              }
            }
          },
          builder: (context, state) {
            if (state is UnlockedLevelInitial ||
                state is UnlockedLevelFetchInProgress) {
              return Center(
                child: CircularProgressContainer(useWhiteLoader: false),
              );
            }
            if (state is UnlockedLevelFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: AppLocalization.of(context)!
                      .getTranslatedValues(
                          convertErrorCodeToLanguageKey(state.errorMessage))!,
                  onTapRetry: () {
                    getUnlockedLevelData();
                  },
                  showErrorImage: true,
                ),
              );
            }
            int unlockedLevel =
                (state as UnlockedLevelFetchSuccess).unlockedLevel;
            return ListView.builder(
                itemCount: int.parse(widget.maxLevel),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      //index start with 0 so we comparing (index + 1)
                      if ((index + 1) <= unlockedLevel) {
                        //replacing this page
                        Navigator.of(context)
                            .pushReplacementNamed(Routes.quiz, arguments: {
                          "numberOfPlayer": 1,
                          "quizType": QuizTypes.quizZone,
                          "categoryId": widget.categoryId,
                          "subcategoryId": "0",
                          "level": (index + 1).toString(),
                          "subcategoryMaxLevel": widget.maxLevel,
                          "unlockedLevel": unlockedLevel,
                          "contestId": "",
                          "comprehensionId": "",
                          "quizName": "Quiz Zone"
                        });
                      } else {
                        UiUtils.setSnackbar(
                            AppLocalization.of(context)!.getTranslatedValues(
                                convertErrorCodeToLanguageKey(
                                    levelLockedCode))!,
                            context,
                            false);
                      }
                    },
                    child: Opacity(
                      opacity: (index + 1) <= unlockedLevel ? 1.0 : 0.55,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Theme.of(context).primaryColor,
                        ),
                        alignment: Alignment.center,
                        height: 75.0,
                        margin: EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          AppLocalization.of(context)!
                                  .getTranslatedValues("levelLbl")! +
                              " ${index + 1}",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Theme.of(context).backgroundColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }

  Widget _buildBannerAd() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BannerAdContainer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageBackgroundGradientContainer(),
          _buildBackButton(),
          _buildLevels(),
          _buildBannerAd(),
        ],
      ),
    );
  }
}
