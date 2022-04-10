import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:ayuprep/features/quiz/cubits/subCategoryCubit.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';

import 'dart:math' as math;

import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/ui/widgets/roundedAppbar.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class SelfChallengeScreen extends StatefulWidget {
  SelfChallengeScreen({Key? key}) : super(key: key);

  @override
  _SelfChallengeScreenState createState() => _SelfChallengeScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => SelfChallengeScreen());
  }
}

class _SelfChallengeScreenState extends State<SelfChallengeScreen> {
  static String _defaultSelectedCategoryValue = selectCategoryKey;
  static String _defaultSelectedSubcategoryValue = selectSubCategoryKey;

  //to display category and suncategory
  String? selectedCategory = _defaultSelectedCategoryValue;
  String? selectedSubcategory = _defaultSelectedSubcategoryValue;

  //id to pass for selfChallengeQuestionsScreen
  String? selectedCategoryId = "";
  String? selectedSubcategoryId = "";

  //minutes for self challenge
  int? selectedMinutes;

  //nunber of questions
  int? selectedNumberOfQuestions;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      context.read<QuizCategoryCubit>().getQuizCategory(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: UiUtils.getCategoryTypeNumberFromQuizType(
                QuizTypes.selfChallenge),
            userId: context.read<UserDetailsCubit>().getUserId(),
          );
    });
  }

  Widget _buildDropdownIcon() {
    return Transform.rotate(
      angle: math.pi / 2,
      child: Icon(
        Icons.arrow_forward_ios,
        size: 20,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  //using for category and subcategory
  Widget _buildDropdown({
    required bool forCategory,
    required List<Map<String, String?>>
        values, //keys of value will be name and id
    required String keyValue, // need to have this keyValues for fade animation
  }) {
    return DropdownButton<String>(
        key: Key(keyValue),
        dropdownColor: Theme.of(context)
            .primaryColor, //same as background of dropdown color
        style:
            TextStyle(color: Theme.of(context).backgroundColor, fontSize: 16.0),
        isExpanded: true,
        onChanged: (value) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          if (!forCategory) {
            // if it's for subcategory

            //if no subcategory selected then do nothing
            if (value != _defaultSelectedSubcategoryValue) {
              int index =
                  values.indexWhere((element) => element['name'] == value);
              setState(() {
                selectedSubcategory = value;
                selectedSubcategoryId = values[index]['id'];
              });
            }
          } else {
            //if no category selected then do nothing
            if (value != _defaultSelectedCategoryValue) {
              int index =
                  values.indexWhere((element) => element['name'] == value);
              setState(() {
                selectedCategory = value;
                selectedCategoryId = values[index]['id'];
                selectedSubcategory = _defaultSelectedSubcategoryValue; //
              });

              context.read<SubCategoryCubit>().fetchSubCategory(
                    selectedCategoryId!,
                    context.read<UserDetailsCubit>().getUserId(),
                  );
            } else {
              context.read<QuizCategoryCubit>().getQuizCategory(
                    languageId: UiUtils.getCurrentQuestionLanguageId(context),
                    type: UiUtils.getCategoryTypeNumberFromQuizType(
                        QuizTypes.selfChallenge),
                    userId: context.read<UserDetailsCubit>().getUserId(),
                  );
            }
          }
        },
        icon: _buildDropdownIcon(),
        underline: SizedBox(),
        //values is map of name and id. only passing name to dropdown
        items: values.map((e) => e['name']).toList().map((name) {
          return DropdownMenuItem(
            child: name! == selectCategoryKey || name == selectSubCategoryKey
                ? Text(AppLocalization.of(context)!.getTranslatedValues(name)!)
                : Text(name),
            value: name,
          );
        }).toList(),
        value: forCategory ? selectedCategory : selectedSubcategory);
  }

  //dropdown container with border
  Widget _buildDropdownContainer(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * (0.8),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10.0)),
      child: child,
    );
  }

  //for selecting time and question
  Widget _buildSelectTimeAndQuestionContainer(
      {bool? forSelectQuestion,
      int? value,
      Color? textColor,
      Color? backgroundColor,
      required Color borderColor}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (forSelectQuestion!) {
            selectedNumberOfQuestions = value;
          } else {
            selectedMinutes = value;
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: 10.0),
        height: 30.0,
        width: 45.0,
        child: Text(
          "$value",
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.w500, fontSize: 18),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _buildTitleContainer(String title) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.8),
      alignment: Alignment.centerLeft,
      child: Text(
        "$title",
        style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).backgroundColor),
      ),
    );
  }

  Widget _buildAppbar() {
    return Align(
      alignment: Alignment.topCenter,
      child: RoundedAppbar(
        removeSnackBars: true,
        title:
            AppLocalization.of(context)!.getTranslatedValues("selfChallenge")!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        //await Future.delayed(Duration.zero);
        return Future.value(true);
      },
      child: Scaffold(
        //backgroundColor: bgColorGradient,
        body: Stack(
          children: [
            PageBackgroundGradientContainer(),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * (0.15)),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 35.0, bottom: 25.0),
                  child: Column(
                    children: [
                      //to build category dropdown
                      BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
                        bloc: context.read<QuizCategoryCubit>(),
                        listener: (context, state) {
                          if (state is QuizCategorySuccess) {
                            setState(() {
                              selectedCategory =
                                  state.categories.first.categoryName;
                              selectedCategoryId = state.categories.first.id;
                            });
                            context.read<SubCategoryCubit>().fetchSubCategory(
                                  state.categories.first.id!,
                                  context.read<UserDetailsCubit>().getUserId(),
                                );
                          }
                          if (state is QuizCategoryFailure) {
                            if (state.errorMessage == unauthorizedAccessCode) {
                              //
                              UiUtils.showAlreadyLoggedInDialog(
                                context: context,
                              );
                              return;
                            }

                            UiUtils.setSnackbar(
                                AppLocalization.of(context)!
                                    .getTranslatedValues(
                                        convertErrorCodeToLanguageKey(
                                            state.errorMessage))!,
                                context,
                                true,
                                duration: Duration(days: 365),
                                onPressedAction: () {
                              //to get categories
                              context.read<QuizCategoryCubit>().getQuizCategory(
                                    languageId:
                                        UiUtils.getCurrentQuestionLanguageId(
                                            context),
                                    type: UiUtils
                                        .getCategoryTypeNumberFromQuizType(
                                            QuizTypes.selfChallenge),
                                    userId: context
                                        .read<UserDetailsCubit>()
                                        .getUserId(),
                                  );
                            });
                          }
                        },
                        builder: (context, state) {
                          return _buildDropdownContainer(AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            child: state is QuizCategorySuccess
                                ? _buildDropdown(
                                    forCategory: true,
                                    values: state.categories
                                        .map((e) => {
                                              "name": e.categoryName,
                                              "id": e.id
                                            })
                                        .toList(),
                                    keyValue: "selectCategorySuccess")
                                : Opacity(
                                    opacity: 0.75,
                                    child: _buildDropdown(
                                        forCategory: true,
                                        values: [
                                          {
                                            "name":
                                                _defaultSelectedCategoryValue,
                                            "id": "0"
                                          }
                                        ],
                                        keyValue: "selectCategory"),
                                  ),
                          ));
                        },
                      ),
                      SizedBox(
                        height: 25.0,
                      ),

                      //to build sub category dropdown
                      BlocConsumer<SubCategoryCubit, SubCategoryState>(
                        bloc: context.read<SubCategoryCubit>(),
                        listener: (context, state) {
                          if (state is SubCategoryFetchSuccess) {
                            setState(() {
                              selectedSubcategory =
                                  state.subcategoryList.first.subcategoryName;
                              selectedSubcategoryId =
                                  state.subcategoryList.first.id;
                            });
                          } else if (state is SubCategoryFetchFailure) {
                            if (state.errorMessage == unauthorizedAccessCode) {
                              //
                              UiUtils.showAlreadyLoggedInDialog(
                                context: context,
                              );
                              return;
                            }
                            UiUtils.setSnackbar(
                                AppLocalization.of(context)!
                                    .getTranslatedValues(
                                        convertErrorCodeToLanguageKey(
                                            state.errorMessage))!,
                                context,
                                true,
                                duration: Duration(days: 365),
                                onPressedAction: () {
                              //load subcategory again
                              context.read<SubCategoryCubit>().fetchSubCategory(
                                    selectedCategoryId!,
                                    context
                                        .read<UserDetailsCubit>()
                                        .getUserId(),
                                  );
                            });
                          }
                        },
                        builder: (context, state) {
                          return _buildDropdownContainer(AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            child: state is SubCategoryFetchSuccess
                                ? _buildDropdown(
                                    forCategory: false,
                                    values: state.subcategoryList
                                        .map((e) => {
                                              "name": e.subcategoryName,
                                              "id": e.id
                                            })
                                        .toList(),
                                    keyValue:
                                        "selectSubcategorySuccess${state.categoryId}")
                                : Opacity(
                                    opacity: 0.75,
                                    child: _buildDropdown(
                                        forCategory: false,
                                        values: [
                                          {
                                            "name":
                                                _defaultSelectedSubcategoryValue
                                          }
                                        ],
                                        keyValue: "selectSubcategory"),
                                  ),
                          ));
                        },
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Theme.of(context).primaryColor,
                        ),
                        padding: EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width * (0.8),
                        child: Column(
                          children: [
                            _buildTitleContainer(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("selectNoQusLbl")!,
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Container(
                              height: 50,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.generate(
                                        10, (index) => (index + 1) * 5)
                                    .map((e) =>
                                        _buildSelectTimeAndQuestionContainer(
                                          forSelectQuestion: true,
                                          value: e,
                                          borderColor:
                                              selectedNumberOfQuestions == e
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                  : Colors.grey.shade400,
                                          backgroundColor:
                                              selectedNumberOfQuestions == e
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                  : Colors.grey.shade100,
                                          textColor:
                                              selectedNumberOfQuestions == e
                                                  ? Theme.of(context)
                                                      .backgroundColor
                                                  : Theme.of(context)
                                                      .primaryColor,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 25.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Theme.of(context).primaryColor,
                        ),
                        padding: EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width * (0.8),
                        child: Column(
                          children: [
                            _buildTitleContainer(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("selectTimeLbl")!,
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Container(
                              height: 50,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.generate(
                                        selfChallengeMaxMinutes ~/ 3,
                                        (index) => (index + 1) * 3)
                                    .map((e) =>
                                        _buildSelectTimeAndQuestionContainer(
                                            forSelectQuestion: false,
                                            value: e,
                                            backgroundColor:
                                                selectedMinutes == e
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                    : Colors.grey.shade100,
                                            textColor: selectedMinutes == e
                                                ? Theme
                                                        .of(context)
                                                    .backgroundColor
                                                : Theme.of(context)
                                                    .primaryColor,
                                            borderColor: selectedMinutes == e
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                : Colors.grey.shade400))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      CustomRoundedButton(
                        elevation: 5.0,
                        widthPercentage: 0.3,
                        backgroundColor: Theme.of(context).primaryColor,
                        buttonTitle: AppLocalization.of(context)!
                            .getTranslatedValues("startLbl")!
                            .toUpperCase(),
                        fontWeight: FontWeight.bold,
                        radius: 5.0,
                        onTap: () {
                          if (selectedCategory !=
                                  _defaultSelectedCategoryValue &&
                              selectedSubcategory !=
                                  _defaultSelectedSubcategoryValue &&
                              selectedMinutes != null &&
                              selectedNumberOfQuestions != null) {
                            //to see what keys to pass in arguments see static function route of SelfChallengeQuesitonsScreen
                            Navigator.of(context).pushNamed(
                                Routes.selfChallengeQuestions,
                                arguments: {
                                  "numberOfQuestions":
                                      selectedNumberOfQuestions.toString(),
                                  "categoryId": "", //catetoryId
                                  "minutes": selectedMinutes,
                                  "subcategoryId": selectedSubcategoryId,
                                });
                          } else {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            UiUtils.setSnackbar(
                                AppLocalization.of(context)!
                                    .getTranslatedValues(
                                        convertErrorCodeToLanguageKey(
                                            selectAllValuesCode))!,
                                context,
                                false);
                          }
                        },
                        showBorder: false,
                        titleColor: Theme.of(context).backgroundColor,
                        shadowColor:
                            Theme.of(context).primaryColor.withOpacity(0.5),
                        height: 40,
                      )
                    ],
                  ),
                ),
              ),
            ),
            _buildAppbar()
          ],
        ),
      ),
    );
  }
}
