import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/ui/widgets/bannerAdContainer.dart';

import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';

import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class CategoryScreen extends StatefulWidget {
  final QuizTypes quizType;

  CategoryScreen({required this.quizType});

  @override
  _CategoryScreen createState() => _CategoryScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => CategoryScreen(
              quizType: arguments['quizType'] as QuizTypes,
            ));
  }
}

class _CategoryScreen extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    context.read<QuizCategoryCubit>().getQuizCategory(
          languageId: UiUtils.getCurrentQuestionLanguageId(context),
          type: UiUtils.getCategoryTypeNumberFromQuizType(widget.quizType),
          userId: context.read<UserDetailsCubit>().getUserId(),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageBackgroundGradientContainer(),
          Column(children: <Widget>[
            Expanded(flex: 2, child: back()),
            Expanded(flex: 15, child: showCategory()),
          ]),
          Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdContainer(),
          ),
        ],
      ),
    );
  }

  Widget back() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30, start: 20, end: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomBackButton(
            iconColor: Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }

  Widget showCategory() {
    return BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
        bloc: context.read<QuizCategoryCubit>(),
        listener: (context, state) {
          if (state is QuizCategoryFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              //
              UiUtils.showAlreadyLoggedInDialog(context: context);
            }
          }
        },
        builder: (context, state) {
          if (state is QuizCategoryProgress || state is QuizCategoryInitial) {
            return Center(
              child: CircularProgressContainer(
                useWhiteLoader: false,
              ),
            );
          }
          if (state is QuizCategoryFailure) {
            return ErrorContainer(
              showBackButton: false,
              errorMessageColor: Theme.of(context).primaryColor,
              showErrorImage: true,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage),
              ),
              onTapRetry: () {
                context.read<QuizCategoryCubit>().getQuizCategory(
                      languageId: UiUtils.getCurrentQuestionLanguageId(context),
                      type: UiUtils.getCategoryTypeNumberFromQuizType(
                          widget.quizType),
                      userId: context.read<UserDetailsCubit>().getUserId(),
                    );
              },
            );
          }
          final categoryList = (state as QuizCategorySuccess).categories;
          return ListView.builder(
            padding: EdgeInsets.only(
              bottom: 50,
            ),
            controller: scrollController,
            // scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: categoryList.length,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  if (widget.quizType == QuizTypes.quizZone) {
                    //noOf means how many subcategory it has
                    //if subcategory is 0 then check for level

                    if (categoryList[index].noOf == "0") {
                      //means this category does not have level
                      if (categoryList[index].maxLevel == "0") {
                        //direct move to quiz screen pass level as 0
                        Navigator.of(context)
                            .pushNamed(Routes.quiz, arguments: {
                          "numberOfPlayer": 1,
                          "quizType": QuizTypes.quizZone,
                          "categoryId": categoryList[index].id,
                          "subcategoryId": "",
                          "level": "0",
                          "subcategoryMaxLevel": "0",
                          "unlockedLevel": 0,
                          "contestId": "",
                          "comprehensionId": "",
                          "quizName": "Quiz Zone"
                        });
                      } else {
                        //navigate to level screen
                        Navigator.of(context)
                            .pushNamed(Routes.levels, arguments: {
                          "maxLevel": categoryList[index].maxLevel,
                          "categoryId": categoryList[index].id,
                        });
                      }
                    } else {
                      Navigator.of(context).pushNamed(
                          Routes.subcategoryAndLevel,
                          arguments: categoryList[index].id);
                    }
                  } else if (widget.quizType == QuizTypes.audioQuestions) {
                    //noOf means how many subcategory it has

                    if (categoryList[index].noOf == "0") {
                      //
                      Navigator.of(context).pushNamed(Routes.quiz, arguments: {
                        "numberOfPlayer": 1,
                        "quizType": QuizTypes.audioQuestions,
                        "categoryId": categoryList[index].id,
                        "isPlayed": categoryList[index].isPlayed,
                      });
                    } else {
                      //
                      Navigator.of(context)
                          .pushNamed(Routes.subCategory, arguments: {
                        "categoryId": categoryList[index].id,
                        "quizType": widget.quizType,
                      });
                    }
                  } else if (widget.quizType == QuizTypes.guessTheWord) {
                    //if therse is noo subcategory then get questions by category
                    if (categoryList[index].noOf == "0") {
                      print(
                          "Played this category : ${categoryList[index].isPlayed}");
                      Navigator.of(context)
                          .pushNamed(Routes.guessTheWord, arguments: {
                        "type": "category",
                        "typeId": categoryList[index].id,
                        "isPlayed": categoryList[index].isPlayed,
                      });
                    } else {
                      Navigator.of(context)
                          .pushNamed(Routes.subCategory, arguments: {
                        "categoryId": categoryList[index].id,
                        "quizType": widget.quizType,
                      });
                    }
                  } else if (widget.quizType == QuizTypes.funAndLearn) {
                    //if therse is no subcategory then get questions by category
                    if (categoryList[index].noOf == "0") {
                      Navigator.of(context)
                          .pushNamed(Routes.funAndLearnTitle, arguments: {
                        "type": "category",
                        "typeId": categoryList[index].id,
                      });
                    } else {
                      Navigator.of(context)
                          .pushNamed(Routes.subCategory, arguments: {
                        "categoryId": categoryList[index].id,
                        "quizType": widget.quizType,
                      });
                    }
                  }
                },
                child: Container(
                    height: 90,
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Theme.of(context).primaryColor),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        placeholder: (context, _) => SizedBox(),
                        imageUrl: categoryList[index].image!,
                        errorWidget: (context, imageUrl, _) => Icon(
                          Icons.error,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.navigate_next_outlined,
                        size: 40,
                        color: Theme.of(context).backgroundColor,
                      ),
                      title: Text(
                        categoryList[index].categoryName!,
                        style:
                            TextStyle(color: Theme.of(context).backgroundColor),
                      ),
                    )),
              );
            },
          );
        });
  }
}
