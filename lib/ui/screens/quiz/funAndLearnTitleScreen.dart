import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/app/routes.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/cubits/comprehensionCubit.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/ui/widgets/bannerAdContainer.dart';

import 'package:ayuprep/ui/widgets/circularProgressContainner.dart';
import 'package:ayuprep/ui/widgets/customBackButton.dart';
import 'package:ayuprep/ui/widgets/errorContainer.dart';
import 'package:ayuprep/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:ayuprep/utils/errorMessageKeys.dart';
import 'package:ayuprep/utils/uiUtils.dart';

class FunAndLearnTitleScreen extends StatefulWidget {
  final String type;
  final String typeId;

  const FunAndLearnTitleScreen(
      {Key? key, required this.type, required this.typeId})
      : super(key: key);
  @override
  _FunAndLearnTitleScreen createState() => _FunAndLearnTitleScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => FunAndLearnTitleScreen(
              type: arguments['type'],
              typeId: arguments['typeId'],
            ));
  }
}

class _FunAndLearnTitleScreen extends State<FunAndLearnTitleScreen> {
  @override
  void initState() {
    super.initState();
    getComprehension();
  }

  void getComprehension() {
    Future.delayed(Duration.zero, () {
      context.read<ComprehensionCubit>().getComprehension(
            userId: context.read<UserDetailsCubit>().getUserId(),
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: widget.type,
            typeId: widget.typeId,
          );
    });
  }

  Widget _buildBackButton() {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: EdgeInsetsDirectional.only(top: 15.0, start: 20),
        child: CustomBackButton(
          iconColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * (0.085),
        ),
        child: BlocConsumer<ComprehensionCubit, ComprehensionState>(
            bloc: context.read<ComprehensionCubit>(),
            listener: (context, state) {
              if (state is ComprehensionFailure) {
                if (state.errorMessage == unauthorizedAccessCode) {
                  //
                  UiUtils.showAlreadyLoggedInDialog(
                    context: context,
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is ComprehensionProgress ||
                  state is ComprehensionInitial) {
                return Center(
                  child: CircularProgressContainer(
                    useWhiteLoader: false,
                  ),
                );
              }
              if (state is ComprehensionFailure) {
                return ErrorContainer(
                  errorMessage: AppLocalization.of(context)!
                      .getTranslatedValues(
                          convertErrorCodeToLanguageKey(state.errorMessage)),
                  onTapRetry: () {
                    getComprehension();
                  },
                  showErrorImage: true,
                  errorMessageColor: Theme.of(context).primaryColor,
                );
              }
              final comprehensions =
                  (state as ComprehensionSuccess).getComprehension;
              return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(bottom: 15.0),
                  itemCount: comprehensions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        print("Played : ${comprehensions[index].isPlayed}");
                        Navigator.of(context).pushNamed(Routes.funAndLearn,
                            arguments: {
                              "comprehension": comprehensions[index],
                              "quizType": QuizTypes.funAndLearn
                            });
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(),
                            Text(
                              comprehensions[index].title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Theme.of(context).backgroundColor,
                              ),
                            ),
                            Spacer(),
                            Container(
                              height: 90,
                              width: 100,
                              padding: EdgeInsets.all(5),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Center(
                                    child: Text(
                                  "${comprehensions[index].noOfQue}\n" +
                                      AppLocalization.of(context)!
                                          .getTranslatedValues("questionLbl")!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      height: 1.0),
                                )),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: Stack(
        children: [
          PageBackgroundGradientContainer(),
          _buildBackButton(),
          _buildTitle(),
          Align(alignment: Alignment.bottomCenter, child: BannerAdContainer()),
        ],
      ),
    ));
  }
}
