import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/cubits/unlockedLevelCubit.dart';
import 'package:ayuprep/features/quiz/cubits/subCategoryCubit.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/quiz/models/subcategory.dart';
import 'package:ayuprep/features/quiz/quizRepository.dart';
import 'package:ayuprep/ui/widgets/bannerAdContainer.dart';

import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';

import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class SubCategoryAndLevelScreen extends StatefulWidget {
  final String? category;
  const SubCategoryAndLevelScreen({Key? key, this.category}) : super(key: key);
  @override
  _SubCategoryAndLevelScreen createState() => _SubCategoryAndLevelScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<SubCategoryCubit>(
                  create: (_) => SubCategoryCubit(QuizRepository()),
                ),
                BlocProvider<UnlockedLevelCubit>(
                  create: (_) => UnlockedLevelCubit(QuizRepository()),
                ),
              ],
              child: SubCategoryAndLevelScreen(
                  category: routeSettings.arguments as String?),
            ));
  }
}

class _SubCategoryAndLevelScreen extends State<SubCategoryAndLevelScreen> {
  PageController? pageController;
  int currentIndex = 0;

  @override
  void initState() {
    pageController = PageController(viewportFraction: 0.635);
    context.read<SubCategoryCubit>().fetchSubCategory(
          widget.category!,
          context.read<UserDetailsCubit>().getUserId(),
        );
    super.initState();
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  Widget _buildBackAndLanguageButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 50, start: 20, end: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomBackButton(
            iconColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLevels(
      UnlockedLevelState state, List<Subcategory> subcategoryList) {
    if (state is UnlockedLevelInitial) {
      return Container();
    }
    if (state is UnlockedLevelFetchInProgress) {
      return Center(
        child: CircularProgressContainer(
          useWhiteLoader: false,
        ),
      );
    }
    if (state is UnlockedLevelFetchFailure) {
      return Center(
        child: ErrorContainer(
          errorMessage: AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(state.errorMessage)),
          topMargin: 0.0,
          onTapRetry: () {
            //fetch unlocked level for current selected subcategory
            context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                context.read<UserDetailsCubit>().getUserId(),
                widget.category,
                subcategoryList[currentIndex].id);
          },
          showErrorImage: false,
        ),
      ); //
    }
    int unlockedLevel = (state as UnlockedLevelFetchSuccess).unlockedLevel;

    return ListView.builder(
        padding: EdgeInsets.only(bottom: 50.0),
        itemCount: int.parse(subcategoryList[currentIndex].maxLevel!),
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
                  "categoryId": "",
                  "subcategoryId": subcategoryList[currentIndex].id,
                  "level": (index + 1).toString(),
                  "subcategoryMaxLevel": subcategoryList[currentIndex].maxLevel,
                  "unlockedLevel": unlockedLevel,
                  "contestId": "",
                  "comprehensionId": "",
                  "quizName": "Quiz Zone"
                });
              } else {
                UiUtils.setSnackbar(
                    AppLocalization.of(context)!.getTranslatedValues(
                        convertErrorCodeToLanguageKey(levelLockedCode))!,
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
                margin: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          Column(
            children: <Widget>[
              _buildBackAndLanguageButton(),
              SizedBox(
                height: 35.0,
              ),
              Flexible(
                child: BlocConsumer<SubCategoryCubit, SubCategoryState>(
                    bloc: context.read<SubCategoryCubit>(),
                    listener: (context, state) {
                      if (state is SubCategoryFetchSuccess) {
                        if (currentIndex == 0) {
                          context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                              context.read<UserDetailsCubit>().getUserId(),
                              widget.category,
                              state.subcategoryList.first.id);
                        }
                      } else if (state is SubCategoryFetchFailure) {
                        if (state.errorMessage == unauthorizedAccessCode) {
                          //
                          UiUtils.showAlreadyLoggedInDialog(
                            context: context,
                          );
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is SubCategoryFetchInProgress ||
                          state is SubCategoryInitial) {
                        return Center(
                          child: CircularProgressContainer(
                            useWhiteLoader: false,
                          ),
                        );
                      }
                      if (state is SubCategoryFetchFailure) {
                        return ErrorContainer(
                          errorMessageColor: Theme.of(context).primaryColor,
                          errorMessage: AppLocalization.of(context)!
                              .getTranslatedValues(
                                  convertErrorCodeToLanguageKey(
                                      state.errorMessage)),
                          showErrorImage: true,
                          onTapRetry: () {
                            context.read<SubCategoryCubit>().fetchSubCategory(
                                  widget.category!,
                                  context.read<UserDetailsCubit>().getUserId(),
                                );
                          },
                        );
                      }
                      final subCategoryList =
                          (state as SubCategoryFetchSuccess).subcategoryList;

                      return Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * (0.2),
                            child: PageView.builder(
                                itemCount: subCategoryList.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                  //fetch unlocked level for current selected subcategory
                                  context
                                      .read<UnlockedLevelCubit>()
                                      .fetchUnlockLevel(
                                          context
                                              .read<UserDetailsCubit>()
                                              .getUserId(),
                                          widget.category,
                                          subCategoryList[index].id);
                                },
                                controller: pageController,
                                itemBuilder: (context, index) {
                                  return SubcategoryContainer(
                                    subcategory: subCategoryList[index],
                                    currentIndex: currentIndex,
                                    index: index,
                                  );
                                }),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                          Flexible(
                              child: ClipRRect(
                            borderRadius: BorderRadius.circular(25.0),
                            child: BlocConsumer<UnlockedLevelCubit,
                                UnlockedLevelState>(
                              listener: (context, state) {
                                if (state is UnlockedLevelFetchFailure) {
                                  if (state.errorMessage ==
                                      unauthorizedAccessCode) {
                                    //
                                    UiUtils.showAlreadyLoggedInDialog(
                                      context: context,
                                    );
                                  }
                                }
                              },
                              builder: (context, state) {
                                return AnimatedSwitcher(
                                  duration: Duration(milliseconds: 500),
                                  child: _buildLevels(state, subCategoryList),
                                );
                              },
                            ),
                          )),
                        ],
                      );
                    }),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdContainer(),
          ),
        ],
      ),
    );
  }
}

class SubcategoryContainer extends StatefulWidget {
  final int index;
  final int currentIndex;
  final Subcategory subcategory;
  SubcategoryContainer(
      {Key? key,
      required this.currentIndex,
      required this.index,
      required this.subcategory})
      : super(key: key);

  @override
  _SubcategoryContainerState createState() => _SubcategoryContainerState();
}

class _SubcategoryContainerState extends State<SubcategoryContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    if (widget.index == widget.currentIndex) {
      animationController.forward();
    }
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SubcategoryContainer oldWidget) {
    if (widget.currentIndex == widget.index) {
      animationController.forward();
    } else {
      animationController.reverse();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (_, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.primaries.first.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20.0)),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.subcategory.subcategoryName!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.0,
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 22.0,
                  ),
                ),
                Text(
                  "${AppLocalization.of(context)!.getTranslatedValues(questionsKey)!} : ${widget.subcategory.noOfQue!}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
