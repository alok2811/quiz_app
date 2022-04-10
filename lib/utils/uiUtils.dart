import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/auth/cubits/authCubit.dart';
import 'package:ayuprep/features/badges/cubits/badgesCubit.dart';
import 'package:ayuprep/features/battleRoom/battleRoomRepository.dart';
import 'package:ayuprep/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:ayuprep/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:ayuprep/features/exam/cubits/examCubit.dart';
import 'package:ayuprep/features/localization/appLocalizationCubit.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/profileManagement/profileManagementLocalDataSource.dart';

import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:ayuprep/ui/styles/theme/appTheme.dart';
import 'package:ayuprep/ui/widgets/alreadyLoggedInDialog.dart';

import 'package:ayuprep/ui/widgets/errorMessageDialog.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/stringLabels.dart';

import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

//Need to optimize and seprate the ui and other logic related process

class UiUtils {
  static double questionContainerHeightPercentage = 0.725;
  static double quizTypeMaxHeightPercentage = 0.275;
  static double quizTypeMinHeightPercentage = 0.185;
  static double quesitonContainerWidthPercentage = 0.85;

  static double profileHeightBreakPointResultScreen = 355.0;

  static double bottomMenuPercentage = 0.075;

  static double dailogHeightPercentage = 0.65;
  static double dailogWidthPercentage = 0.85;

  static double dailogBlurSigma = 6.0;
  static double dailogRadius = 40.0;
  static double appBarHeightPercentage = 0.16;
  static double bottomSheetRadius = 20;

  static List<String> needToUpdateBadgesLocally = [];

  static String buildGuessTheWordQuestionAnswer(List<String> submittedAnswer) {
    String answer = "";
    submittedAnswer.forEach((element) {
      if (element.isNotEmpty) {
        answer = answer + element;
      }
    });
    return answer;
  }

  static String convertMinuteIntoHHMM(int totalMinutes,
      {bool? showHourAndMinute}) {
    String hours = (totalMinutes ~/ 60).toString().length == 1
        ? "0${(totalMinutes ~/ 60)}"
        : (totalMinutes ~/ 60).toString();
    String minutes = (totalMinutes % 60).toString().length == 1
        ? "0${(totalMinutes % 60)}"
        : (totalMinutes % 60).toString();
    bool showHourAndMinutePostText = showHourAndMinute ?? true;
    return "$hours:$minutes " + (showHourAndMinutePostText ? "hh:mm" : "");
  }

  static BorderRadius getBottomSheetRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(bottomSheetRadius),
      topRight: Radius.circular(bottomSheetRadius),
    );
  }

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    // print(message.notification);
    if (message.data['type'].toString() == "badges") {
      needToUpdateBadgesLocally.add(message.data['badge_type'].toString());
    } else if (message.data['type'].toString() == "payment_request") {
      //
      ProfileManagementLocalDataSource.updateReversedCoins(
          double.parse(message.data['coins'].toString()).toInt());
    }
  }

  static void updateBadgesLocally(BuildContext context) {
    needToUpdateBadgesLocally.forEach((badgeType) {
      context.read<BadgesCubit>().unlockBadge(badgeType);
    });
    needToUpdateBadgesLocally.clear();
  }

  static void needToUpdateCoinsLocally(BuildContext context) async {
    //

    int coins = await ProfileManagementLocalDataSource.getUpdateReversedCoins();
    print("Need to upddate coins by $coins");
    if (coins != 0) {
      context.read<UserDetailsCubit>().updateCoins(addCoin: true, coins: coins);
    }
  }

  static void setSnackbar(String msg, BuildContext context, bool showAction,
      {Function? onPressedAction, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(msg,
          textAlign: showAction ? TextAlign.start : TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.0)),
      behavior: SnackBarBehavior.fixed,
      duration: duration ?? Duration(seconds: 2),
      backgroundColor: Theme.of(context).primaryColor,
      action: showAction
          ? SnackBarAction(
              label: "Retry",
              onPressed: onPressedAction as void Function(),
              textColor: Theme.of(context).backgroundColor,
            )
          : null,
      elevation: 2.0,
    ));
  }

  static void errorMessageDialog(BuildContext context, String? errorMessage) {
    showDialog(
        context: context,
        builder: (_) => ErrorMessageDialog(errorMessage: errorMessage));
  }

  static String getImagePath(String imageName) {
    return "assets/images/$imageName";
  }

  static String getprofileImagePath(String imageName) {
    return "assets/images/profile/$imageName";
  }

  static String getEmojiPath(String emojiName) {
    return "assets/images/emojis/$emojiName";
  }

  static BoxShadow buildBoxShadow(
      {Offset? offset, double? blurRadius, Color? color}) {
    return BoxShadow(
      color: color ?? Colors.black.withOpacity(0.1),
      blurRadius: blurRadius ?? 10.0,
      offset: offset ?? Offset(5.0, 5.0),
    );
  }

  static BoxShadow buildAppbarShadow() {
    return buildBoxShadow(
        blurRadius: 5.0,
        color: Colors.black.withOpacity(0.3),
        offset: Offset.zero);
  }

  static LinearGradient buildLinerGradient(
      List<Color> colors, Alignment begin, Alignment end) {
    return LinearGradient(colors: colors, begin: begin, end: end);
  }

  static String getCurrentQuestionLanguageId(BuildContext context) {
    final currentLanguage = context.read<AppLocalizationCubit>().state.language;
    if (context.read<SystemConfigCubit>().getLanguageMode() == "1") {
      final supporatedLanguage =
          context.read<SystemConfigCubit>().getSupportedLanguages();
      final supporatedLanguageIndex = supporatedLanguage.indexWhere((element) =>
          getLocaleFromLanguageCode(element.languageCode) == currentLanguage);

      return supporatedLanguageIndex == -1
          ? defaultLanguageCode
          : supporatedLanguage[supporatedLanguageIndex].id;
    }

    return defaultQuestionLanguageId;
  }

  static double getTransactionContainerHeight(double dheight) {
    if (dheight >= 800) {
      return 0.1;
    }
    if (dheight >= 700) {
      return 0.11;
    }
    if (dheight >= 600) {
      return 0.12;
    }
    return 0.1275;
  }

  static double getQuestionContainerTopPaddingPercentage(double dheight) {
    if (dheight >= 800) {
      return 0.06;
    }
    if (dheight >= 700) {
      return 0.065;
    }
    if (dheight >= 600) {
      return 0.07;
    }
    return 0.075;
  }

  static Locale getLocaleFromLanguageCode(String languageCode) {
    List<String> result = languageCode.split("-");
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static String formatNumber(int number) {
    return NumberFormat.compact().format(number).toLowerCase();
  }

  //This method will determine how much coins will user get after
  //completing the quiz
  static int coinsBasedOnWinPercentage(double percentage, QuizTypes quizType) {
    //if percentage is more than maxCoinsWinningPercentage then user will earn maxWinningCoins
    //
    //if percentage is less than maxCoinsWinningPercentage
    //coin value will deduct from maxWinning coins
    //earned coins = (maxWinningCoins - ((maxCoinsWinningPercentage - percentage)/ 10))

    //For example: if percentage is 70 then user will
    //earn 3 coins if maxWinningCoins is 4

    int earnedCoins = 0;
    if (percentage >= maxCoinsWinningPercentage) {
      earnedCoins = quizType == QuizTypes.guessTheWord
          ? guessTheWordMaxWinningCoins
          : maxWinningCoins;
    } else {
      int maxCoins = quizType == QuizTypes.guessTheWord
          ? guessTheWordMaxWinningCoins
          : maxWinningCoins;

      earnedCoins =
          (maxCoins - ((maxCoinsWinningPercentage - percentage) / 10)).toInt();
    }
    if (earnedCoins < 0) {
      earnedCoins = 0;
    }
    return earnedCoins;
  }

  static String getCategoryTypeNumberFromQuizType(QuizTypes quizType) {
    //quiz_zone=1, fun_n_learn=2, guess_the_word=3, audio_question=4
    if (quizType == QuizTypes.audioQuestions) {
      return "4";
    }
    if (quizType == QuizTypes.guessTheWord) {
      return "3";
    }
    if (quizType == QuizTypes.funAndLearn) {
      return "2";
    }
    return "1";
  }

  //calculate amount per coins based on users coins
  static double calculateAmountPerCoins(
      {required int userCoins, required int amount, required int coins}) {
    return (amount * userCoins) / coins;
  }

  //calculate coins based on entered amount
  static int calculateDeductedCoinsForRedeemableAmount(
      {required double userEnteredAmount,
      required int amount,
      required int coins}) {
    return (coins * userEnteredAmount) ~/ amount;
  }

  static Future<bool> forceUpdate(String updatedVersion) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
    if (updatedVersion.isEmpty) {
      return false;
    }

    bool updateBasedOnVersion = _shouldUpdateBasedOnVersion(
        currentVersion.split("+").first, updatedVersion.split("+").first);

    if (updatedVersion.split("+").length == 1 ||
        currentVersion.split("+").length == 1) {
      return updateBasedOnVersion;
    }

    bool updateBasedOnBuildNumber = _shouldUpdateBasedOnBuildNumber(
        currentVersion.split("+").last, updatedVersion.split("+").last);

    return (updateBasedOnVersion || updateBasedOnBuildNumber);
  }

  static bool _shouldUpdateBasedOnVersion(
      String currentVersion, String updatedVersion) {
    List<int> currentVersionList =
        currentVersion.split(".").map((e) => int.parse(e)).toList();
    List<int> updatedVersionList =
        updatedVersion.split(".").map((e) => int.parse(e)).toList();

    if (updatedVersionList[0] > currentVersionList[0]) {
      return true;
    }
    if (updatedVersionList[1] > currentVersionList[1]) {
      return true;
    }
    if (updatedVersionList[2] > currentVersionList[2]) {
      return true;
    }

    return false;
  }

  static bool _shouldUpdateBasedOnBuildNumber(
      String currentBuildNumber, String updatedBuildNumber) {
    return int.parse(updatedBuildNumber) > int.parse(currentBuildNumber);
  }

  static void vibrate() {
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
  }

  static void fetchBookmarkAndBadges(
      {required BuildContext context, required String userId}) {
    //fetch bookmark quiz zone
    if (context.read<BookmarkCubit>().state is! BookmarkFetchSuccess) {
      print("Fetch bookmark details");
      context.read<BookmarkCubit>().getBookmark(userId);
      //delete any unused gruop battle room which is created by this user
      BattleRoomRepository().deleteUnusedBattleRoom(userId);
    }

    //fetch guess the word bookmark
    if (context.read<GuessTheWordBookmarkCubit>().state
        is! GuessTheWordBookmarkFetchSuccess) {
      print("Fetch guess the word bookmark details");
      context.read<GuessTheWordBookmarkCubit>().getBookmark(userId);
    }

    //fetch audio question bookmark
    if (context.read<AudioQuestionBookmarkCubit>().state
        is! AudioQuestionBookmarkFetchSuccess) {
      print("Fetch audio question bookmark details");
      context.read<AudioQuestionBookmarkCubit>().getBookmark(userId);
    }

    if (context.read<BadgesCubit>().state is! BadgesFetchSuccess) {
      print("Fetch badges details");
      //get badges for given user
      context.read<BadgesCubit>().getBadges(userId: userId);

      //complete any pennding exam
      context.read<ExamCubit>().completePendingExams(userId: userId);
    }
  }

  static int determineBattleCorrectAnswerPoints(
      double animationControllerValue) {
    double secondsTakenToAnswer =
        (questionDurationInSeconds * animationControllerValue);

    print("Took ${secondsTakenToAnswer}s to give the answer");

    //improve points system here if needed
    if (secondsTakenToAnswer <= 2) {
      return correctAnswerPointsForBattle + extraPointForQuickestAnswer;
    } else if (secondsTakenToAnswer <= 4) {
      return correctAnswerPointsForBattle + extraPointForSecondQuickestAnswer;
    }
    return correctAnswerPointsForBattle;
  }

  static double timeTakenToSubmitAnswer(
      {required double animationControllerValue, required QuizTypes quizType}) {
    double secondsTakenToAnswer;

    if (quizType == QuizTypes.guessTheWord) {
      secondsTakenToAnswer =
          (guessTheWordQuestionDurationInSeconds * animationControllerValue);
    } else {
      secondsTakenToAnswer =
          (questionDurationInSeconds * animationControllerValue);
    }
    return secondsTakenToAnswer;
  }

  static String getThemeLabelFromAppTheme(AppTheme appTheme) {
    if (appTheme == AppTheme.Dark) {
      return darkThemeKey;
    }
    return lightThemeKey;
  }

  static AppTheme getAppThemeFromLabel(String label) {
    if (label == darkThemeKey) {
      return AppTheme.Dark;
    }
    return AppTheme.Light;
  }

  static void showAlreadyLoggedInDialog(
      {required BuildContext context, Function? onLoggedInCallback}) {
    context.read<AuthCubit>().signOut();
    showDialog(
        context: context,
        builder: (_) => WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: AlreadyLoggedInDialog(
                onAlreadyLoggedInCallBack: onLoggedInCallback,
              ),
            ));
  }

  /*
  //will be in use while playing screen
  //this method will be in use to display color based on user's answer
  static Color getOptionBackgroundColor(Question question, BuildContext context,
      String? optionId, String? showCorrectAnswerMode) {
    if (question.attempted) {
      if (showCorrectAnswerMode == "0") {
        return Theme.of(context).primaryColor.withOpacity(0.65);
      }

      // if given answer is correct
      if (question.submittedAnswerId == question.correctAnswerOptionId) {
        //if given option is same as answer
        if (question.submittedAnswerId == optionId) {
          return Colors.greenAccent;
        }
        //color will not change for other options
        return Theme.of(context).colorScheme.secondary;
      } else {
        //option id is same as given answer then change color to red
        if (question.submittedAnswerId == optionId) {
          return Colors.redAccent;
        }
        //if given option id is correct as same answer then change color to green
        else if (question.correctAnswerOptionId == optionId) {
          return Colors.greenAccent;
        }
        //do not change color
        return Theme.of(context).colorScheme.secondary;
      }
    }
    return Theme.of(context).colorScheme.secondary;
  }

  //will be in use while playing  quiz screen
  //this method will be in use to display color based on user's answer
  static Color getOptionTextColor(Question question, BuildContext context,
      String? optionId, String? showCorrectAnswerMode) {
    if (question.attempted) {
      if (showCorrectAnswerMode == "0") {
        return Theme.of(context).scaffoldBackgroundColor;
      }

      // if given answer is correct
      if (question.submittedAnswerId == question.correctAnswerOptionId) {
        //if given option is same as answer
        if (question.submittedAnswerId == optionId) {
          return Theme.of(context).scaffoldBackgroundColor;
        }
        //color will not change for other options
        return Theme.of(context).scaffoldBackgroundColor;
      } else {
        //option id is same as given answer then change color to red
        if (question.submittedAnswerId == optionId) {
          return Theme.of(context).scaffoldBackgroundColor;
        }
        //if given option id is correct as same answer then change color to green
        else if (question.correctAnswerOptionId == optionId) {
          return Theme.of(context).scaffoldBackgroundColor;
        }
        //do not change color
        return Theme.of(context).scaffoldBackgroundColor;
      }
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }
  */
}
