import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/exam/cubits/completedExamsCubit.dart';
import 'package:ayuprep/features/exam/cubits/examsCubit.dart';
import 'package:ayuprep/features/exam/examRepository.dart';

import 'package:ayuprep/features/exam/models/exam.dart';
import 'package:ayuprep/features/exam/models/examResult.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';

import 'package:ayuprep/ui/screens/exam/widgets/examKeyBottomSheetContainer.dart';
import 'package:ayuprep/ui/screens/exam/widgets/examResultBottomSheetContainer.dart';

import 'package:ayuprep/ui/widgets/bannerAdContainer.dart';
import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class ExamsScreen extends StatefulWidget {
  ExamsScreen({Key? key}) : super(key: key);

  @override
  _ExamsScreenState createState() => _ExamsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<ExamsCubit>(create: (_) => ExamsCubit(ExamRepository())),
          BlocProvider<CompletedExamsCubit>(
              create: (_) => CompletedExamsCubit(ExamRepository())),
        ],
        child: ExamsScreen(),
      ),
    );
  }
}

class _ExamsScreenState extends State<ExamsScreen> {
  int _currentSelectedTab = 1; //1 and 2

  int currentSelectedQuestionIndex = 0;

  late ScrollController _completedExamScrollController = ScrollController()
    ..addListener(hasMoreResultScrollListener);

  void hasMoreResultScrollListener() {
    if (_completedExamScrollController.position.maxScrollExtent ==
        _completedExamScrollController.offset) {
      print("At the end of the list");
      if (context.read<CompletedExamsCubit>().hasMoreResult()) {
        //
        context.read<CompletedExamsCubit>().getMoreResult(
            userId: context.read<UserDetailsCubit>().getUserId(),
            languageId: UiUtils.getCurrentQuestionLanguageId(context));
      } else {
        print("No more result");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getExams();
    getCompletedExams();
  }

  @override
  void dispose() {
    _completedExamScrollController.removeListener(hasMoreResultScrollListener);
    _completedExamScrollController.dispose();
    super.dispose();
  }

  void getExams() {
    Future.delayed(Duration.zero, () {
      context.read<ExamsCubit>().getExams(
          userId: context.read<UserDetailsCubit>().getUserId(),
          languageId: UiUtils.getCurrentQuestionLanguageId(context));
    });
  }

  void getCompletedExams() {
    Future.delayed(Duration.zero, () {
      context.read<CompletedExamsCubit>().getCompletedExams(
          userId: context.read<UserDetailsCubit>().getUserId(),
          languageId: UiUtils.getCurrentQuestionLanguageId(context));
    });
  }

  void showExamKeyBottomSheet(
      BuildContext context, Exam exam) //Accept exam object as parameter
  {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        elevation: 5.0,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (context) {
          return ExamKeyBottomSheetContainer(
            navigateToExamScreen: navigateToExamScreen,
            exam: exam,
          );
        });
  }

  void showExamResultBottomSheet(BuildContext context,
      ExamResult examResult) //Accept exam object as parameter
  {
    showModalBottomSheet(
        isScrollControlled: true,
        elevation: 5.0,
        context: context,
        enableDrag: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: UiUtils.getBottomSheetRadius(),
        ),
        builder: (context) {
          return ExamResultBottomSheetContainer(
            examResult: examResult,
          );
        });
  }

  void navigateToExamScreen() async {
    Navigator.of(context).pop();

    Navigator.of(context).pushNamed(Routes.exam).then((value) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          print("Fetch exam details again");
          //fetch exams again with fresh status
          context.read<ExamsCubit>().getExams(
              userId: context.read<UserDetailsCubit>().getUserId(),
              languageId: UiUtils.getCurrentQuestionLanguageId(context));
          //fetch completed exam again with fresh status
          context.read<CompletedExamsCubit>().getCompletedExams(
              userId: context.read<UserDetailsCubit>().getUserId(),
              languageId: UiUtils.getCurrentQuestionLanguageId(context));
        }
      });
    });
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 25.0, bottom: 25.0),
              child: CustomBackButton(
                removeSnackBars: false,
                iconColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabContainer("Today", 1),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                _buildTabContainer("Completed", 2),
              ],
            ),
          ),
        ],
      ),
      height:
          MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage),
      decoration: BoxDecoration(
          boxShadow: [UiUtils.buildAppbarShadow()],
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0))),
    );
  }

  Widget _buildTabContainer(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSelectedTab = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context)
                .primaryColor
                .withOpacity(_currentSelectedTab == index ? 1.0 : 0.5),
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildExamResults() {
    return BlocConsumer<CompletedExamsCubit, CompletedExamsState>(
      listener: (context, state) {
        if (state is CompletedExamsFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      bloc: context.read<CompletedExamsCubit>(),
      builder: (context, state) {
        if (state is CompletedExamsFetchInProgress ||
            state is CompletedExamsInitial) {
          return Center(
            child: CircularProgressContainer(
              useWhiteLoader: false,
            ),
          );
        }
        if (state is CompletedExamsFetchFailure) {
          return Center(
            child: ErrorContainer(
                errorMessageColor: Theme.of(context).primaryColor,
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage)),
                onTapRetry: () {
                  getCompletedExams();
                },
                showErrorImage: true),
          );
        }
        return ListView.builder(
          controller: _completedExamScrollController,
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * (0.05),
            left: MediaQuery.of(context).size.width * (0.05),
            top: MediaQuery.of(context).size.height *
                    UiUtils.appBarHeightPercentage +
                10,
            bottom: MediaQuery.of(context).size.height * 0.075,
          ),
          itemCount:
              (state as CompletedExamsFetchSuccess).completedExams.length,
          itemBuilder: (context, index) {
            return _buildResultContainer(
              examResult: state.completedExams[index],
              hasMoreResultFetchError: state.hasMoreFetchError,
              index: index,
              totalExamResults: state.completedExams.length,
              hasMore: state.hasMore,
            );
          },
        );
      },
    );
  }

  Widget _buildTodayExams() {
    return BlocConsumer<ExamsCubit, ExamsState>(
      listener: (contexe, state) {
        if (state is ExamsFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      bloc: context.read<ExamsCubit>(),
      builder: (context, state) {
        if (state is ExamsFetchInProgress || state is ExamsInitial) {
          return Center(
            child: CircularProgressContainer(
              useWhiteLoader: false,
            ),
          );
        }
        if (state is ExamsFetchFailure) {
          return Center(
            child: ErrorContainer(
                errorMessageColor: Theme.of(context).primaryColor,
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage)),
                onTapRetry: () {
                  getExams();
                },
                showErrorImage: true),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * (0.05),
            left: MediaQuery.of(context).size.width * (0.05),
            top: MediaQuery.of(context).size.height *
                    UiUtils.appBarHeightPercentage +
                10,
            bottom: MediaQuery.of(context).size.height * 0.075,
          ),
          itemCount: (state as ExamsFetchSuccess).exams.length,
          itemBuilder: (context, index) {
            return _buildTodayExamContainer(state.exams[index]);
          },
        );
      },
    );
  }

  Widget _buildTodayExamContainer(Exam exam) {
    return GestureDetector(
      onTap: () {
        showExamKeyBottomSheet(context, exam);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10.0)),
        height: MediaQuery.of(context).size.height * (0.1),
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * (0.6),
                  child: Text(
                    exam.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontSize: 17.25,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  "${exam.totalMarks} ${AppLocalization.of(context)!.getTranslatedValues(markKey)!}",
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontSize: 17.25,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * (0.5),
                  child: Text(
                    exam.date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor.withOpacity(0.8),
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  UiUtils.convertMinuteIntoHHMM(int.parse(exam.duration)),
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContainer({
    required ExamResult examResult,
    required int index,
    required int totalExamResults,
    required bool hasMoreResultFetchError,
    required bool hasMore,
  }) {
    if (index == totalExamResults - 1) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreResultFetchError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: IconButton(
                  onPressed: () {
                    context.read<CompletedExamsCubit>().getMoreResult(
                        userId: context.read<UserDetailsCubit>().getUserId(),
                        languageId:
                            UiUtils.getCurrentQuestionLanguageId(context));
                  },
                  icon: Icon(
                    Icons.error,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          );
        } else {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: CircularProgressContainer(
                useWhiteLoader: false,
                heightAndWidth: 40,
              ),
            ),
          );
        }
      }
    }
    return GestureDetector(
      onTap: () {
        showExamResultBottomSheet(context, examResult);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10.0)),
        height: MediaQuery.of(context).size.height * (0.1),
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * (0.5),
                  child: Text(
                    "${examResult.title}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontSize: 17.25,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * (0.5),
                  child: Text(
                    "${examResult.date}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${examResult.obtainedMarks()}/${examResult.totalMarks} ${AppLocalization.of(context)!.getTranslatedValues(markKey)!} ",
                style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                  fontSize: 15,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          Align(
            alignment: Alignment.topCenter,
            child: _currentSelectedTab == 1
                ? _buildTodayExams()
                : _buildExamResults(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
          Align(alignment: Alignment.bottomCenter, child: BannerAdContainer()),
        ],
      ),
    );
  }
}
