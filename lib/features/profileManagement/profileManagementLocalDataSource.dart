import 'package:ayuprep/utils/constants.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManagementLocalDataSource {
  String getName() {
    return Hive.box(userdetailsBox).get(nameBoxKey, defaultValue: "");
  }

  String getUserUID() {
    return Hive.box(userdetailsBox).get(userUIdBoxKey, defaultValue: "");
  }

  String getEmail() {
    return Hive.box(userdetailsBox).get(emailBoxKey, defaultValue: "");
  }

  String getMobileNumber() {
    return Hive.box(userdetailsBox).get(mobileNumberBoxKey, defaultValue: "");
  }

  String getRank() {
    return Hive.box(userdetailsBox).get(rankBoxKey, defaultValue: "");
  }

  String getCoins() {
    return Hive.box(userdetailsBox).get(coinsBoxKey, defaultValue: "");
  }

  String getScore() {
    return Hive.box(userdetailsBox).get(scoreBoxKey, defaultValue: "");
  }

  String getProfileUrl() {
    return Hive.box(userdetailsBox).get(profileUrlBoxKey, defaultValue: "");
  }

  String getFirebaseId() {
    return Hive.box(userdetailsBox).get(firebaseIdBoxKey, defaultValue: "");
  }

  String getStatus() {
    return Hive.box(userdetailsBox).get(statusBoxKey, defaultValue: "1");
  }

  String getReferCode() {
    return Hive.box(userdetailsBox).get(referCodeBoxKey, defaultValue: "");
  }

  String getFCMToken() {
    return Hive.box(userdetailsBox).get(fcmTokenBoxKey, defaultValue: "");
  }
  //

  Future<void> setEmail(String email) async {
    Hive.box(userdetailsBox).put(emailBoxKey, email);
  }

  Future<void> setUserUId(String userId) async {
    Hive.box(userdetailsBox).put(userUIdBoxKey, userId);
  }

  Future<void> setName(String name) async {
    Hive.box(userdetailsBox).put(nameBoxKey, name);
  }

  Future<void> serProfilrUrl(String profileUrl) async {
    Hive.box(userdetailsBox).put(profileUrlBoxKey, profileUrl);
  }

  Future<void> setRank(String rank) async {
    Hive.box(userdetailsBox).put(rankBoxKey, rank);
  }

  Future<void> setCoins(String coins) async {
    Hive.box(userdetailsBox).put(coinsBoxKey, coins);
  }

  Future<void> setMobileNumber(String mobileNumber) async {
    Hive.box(userdetailsBox).put(mobileNumberBoxKey, mobileNumber);
  }

  Future<void> setScore(String score) async {
    Hive.box(userdetailsBox).put(scoreBoxKey, score);
  }

  Future<void> setStatus(String status) async {
    Hive.box(userdetailsBox).put(statusBoxKey, status);
  }

  Future<void> setFirebaseId(String firebaseId) async {
    Hive.box(userdetailsBox).put(firebaseIdBoxKey, firebaseId);
  }

  Future<void> setReferCode(String referCode) async {
    Hive.box(userdetailsBox).put(referCodeBoxKey, referCode);
  }

  Future<void> setFCMToken(String fcmToken) async {
    Hive.box(userdetailsBox).put(fcmTokenBoxKey, fcmToken);
  }

  static Future<void> updateReversedCoins(int coins) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("reversedCoins", coins);
  }

  static Future<int> getUpdateReversedCoins() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.reload();
      return sharedPreferences.getInt("reversedCoins") ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
