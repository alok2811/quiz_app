//errorMessagesKey for localization
//error message code starts from 101 to 159

//
//if you make any changes here in keys make sure to update in all languages files
//
import 'package:ayuprep/utils/stringLabels.dart';

final String defaultErrorMessageKey =
    "defaultErrorMessage"; //something went wrong
final String noInternetKey = "noInternet";
final String invalidHashKey = "invalidHash";
final String dataNotFoundKey = "dataNotFound";
final String fillAllDataKey = "fillAllData";
final String fileUploadFailKey = "fileUploadFail";
final String dailyQuizAlreadyPlayedKey = "dailyQuizAlreadyPlayed";
final String noMatchesPlayedKey = "noMatchesPlayed";
final String noUpcomingContestKey = "noUpcomingContest";
final String noContestKey = "noContest";
final String notPlayedContestKey = "notPlayedContest";
final String contestAlreadyPlayedKey = "contestAlreadyPlayed";
final String roomAlreadyCreatedKey = "roomAlreadyCreated";
final String unauthorizedAccessKey = "unauthorizedAccess";

//
//firebase auth exceptions
//
final String invalidEmailKey = "invalid-email";
final String userDisabledKey = "user-disabled";
final String userNotFoundKey = "user-not-found";
final String wrongPasswordKey = "wrong-password";
final String accountExistCredentialKey =
    "account-exists-with-different-credential";
final String invalidCredentialKey = "invalid-credential";
final String operationNotAllowedKey = "operation-not-allowed";
final String invalidVerificationCodeKey = "invalid-verification-code";
final String invalidVerificationIdKey = "invalid-verification-id";
final String emailExistKey = "email-already-in-use";
final String weakPasswordKey = "weak-password";
final String verifyEmailKey = "verifyEmail";
final String levelLockedKey = "levelLocked";
final String updateBookmarkFailureKey = "updateBookmarkFailure";
final String lifeLineUsedKey = "lifeLineUsed";
final String notEnoughCoinsKey = "notEnoughCoins";
final String notesNotAvailableKey = "notesNotAvailable";
final String selectAllValuesKey = "selectAllValues";
final String canNotStartGameKey = "canNotStartGame";
final String roomCodeInvalidKey = "roomCodeInvalid";
final String gameStartedKey = "gameStarted";
final String roomIsFullKey = "roomIsFull";
final String alreadyInExamKey = "alreadyInExam";
final String noExamForTodayKey = "noExamForToday";
final String haveNotCompletedExamKey = "haveNotCompletedExam";
final String requireRecentLoginKey = "requires-recent-login";
final String noTransactionsKey = "noTransactions";
final String accountHasBeenDeactiveKey = "accountHasBeenDeactive";
final String canNotMakeRequestKey = "canNotMakeRequest";

//
//error message code that is not given from api
//error code after 137 occurs in frontend.
//
final String defaultErrorMessageCode = "122";
final String noInternetCode = "126";
final String levelLockedCode = "138";
final String updateBookmarkFailureCode = "139";
final String lifeLineUsedCode = "140";
final String notEnoughCoinsCode = "141";
final String notesNotAvailableCode = "142";
final String selectAllValuesCode = "143";
final String canNotStartGameCode = "144";
final String roomCodeInvalidCode = "145";
final String gameStartedCode = "146";
final String roomIsFullCode = "147";
final String unableToCreateRoomCode = "148";
final String unableToFindRoomCode = "149";
final String unableToJoinRoomCode = "150";
final String unableToSubmitAnswerCode = "151";
final String alreadyInExamCode = "152";
final String noExamForTodayCode = "153";
final String haveNotCompletedExamCode = "154";
final String requireRecentLoginCode = "155";
final String noTransactionsCode = "156";
final String accountHasBeenDeactiveCode = "157";
final String canNotMakeRequestCode = "158";
final String userNotFoundCode = "159";
final String unauthorizedAccessCode = "129";

//
//firebase auth exceptions code
//
String firebaseErrorCodeToNumber(String firebaseErrorCode) {
  switch (firebaseErrorCode) {
    case "invalid-email":
      return "127";
    case "user-disabled":
      return "128";
    case "user-not-found":
      return userNotFoundCode;
    case "wrong-password":
      return "130";
    case "account-exists-with-different-credential":
      return "131";
    case "invalid-credential":
      return "132";
    case "operation-not-allowed":
      return "133";
    case "invalid-verification-code":
      return "134";
    case "verifyEmail":
      return "135";
    case "email-already-in-use":
      return "136";
    case "weak-password":
      return "137";
    case "requires-recent-login":
      return "155";

    default:
      return defaultErrorMessageCode;
  }
}

//
//to convert error code into error keys for localization
//every error occurs in app will have code assign to it
//
String convertErrorCodeToLanguageKey(String code) {
  switch (code) {
    case "101":
      return invalidHashKey;
    case "102":
      return dataNotFoundKey;
    case "103":
      return fillAllDataKey;
    case "104":
      return defaultErrorMessageKey;
    case "105":
      return defaultErrorMessageKey;
    case "106":
      return defaultErrorMessageKey;
    case "107":
      return fileUploadFailKey;
    case "108":
      return defaultErrorMessageKey;
    case "109":
      return defaultErrorMessageKey;
    case "110":
      return defaultErrorMessageKey;
    case "111":
      return defaultErrorMessageKey;
    case "112":
      return dailyQuizAlreadyPlayedKey;
    case "113":
      return noMatchesPlayedKey;
    case "114":
      return noUpcomingContestKey;
    case "115":
      return noContestKey;
    case "116":
      return notPlayedContestKey;
    case "117":
      return contestAlreadyPlayedKey;
    case "118":
      return defaultErrorMessageKey;
    case "119":
      return roomAlreadyCreatedKey;
    case "120":
      return defaultErrorMessageKey;
    case "121":
      return defaultErrorMessageKey;
    case "122":
      return defaultErrorMessageKey;
    case "123":
      return defaultErrorMessageKey;
    case "124":
      return invalidHashKey;
    case "125":
      return unauthorizedAccessKey;
    case "126":
      return noInternetKey;
    case "127":
      return invalidEmailKey;
    case "128":
      return userDisabledKey;
    case "129":
      return unauthorizedAccessKey;
    case "130":
      return wrongPasswordKey;
    case "131":
      return accountExistCredentialKey;
    case "132":
      return invalidCredentialKey;
    case "133":
      return operationNotAllowedKey;
    case "134":
      return invalidVerificationCodeKey;
    case "135":
      return verifyEmailKey;
    case "136":
      return emailExistKey;
    case "137":
      return weakPasswordKey;

    case "138":
      return levelLockedKey;

    case "139":
      return updateBookmarkFailureKey;

    case "140":
      return lifeLineUsedKey;

    case "141":
      return notEnoughCoinsKey;

    case "142":
      return notesNotAvailableKey;

    case "143":
      return selectAllValuesKey;

    case "144":
      return canNotStartGameKey;

    case "145":
      return roomCodeInvalidKey;

    case "146":
      return gameStartedKey;

    case "147":
      return roomIsFullKey;

    case "148":
      return unableToCreateRoomKey;

    case "149":
      return unableToFindRoomKey;

    case "150":
      return unableToJoinRoomCode;

    case "151":
      return unableToSubmitAnswerCode;

    case "152":
      return alreadyInExamKey;

    case "153":
      return noExamForTodayKey;

    case "154":
      return haveNotCompletedExamKey;

    case "155":
      return requireRecentLoginKey;

    case "156":
      return noTransactionsKey;

    case "157":
      return accountHasBeenDeactiveKey;
    case "158":
      return canNotMakeRequestKey;

    case "159":
      return userNotFoundKey;

    default:
      {
        return defaultErrorMessageKey;
      }
  }
}
