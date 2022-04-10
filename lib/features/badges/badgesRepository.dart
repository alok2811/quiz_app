import 'package:ayuprep/features/badges/badge.dart';
import 'package:ayuprep/features/badges/badgesExecption.dart';
import 'package:ayuprep/features/badges/badgesRemoteDataSource.dart';
import 'package:ayuprep/utils/constants.dart';

class BadgesRepository {
  static final BadgesRepository _badgesRepository = BadgesRepository._internal();
  late BadgesRemoteDataSource _badgesRemoteDataSource;

  factory BadgesRepository() {
    _badgesRepository._badgesRemoteDataSource = BadgesRemoteDataSource();
    return _badgesRepository;
  }

  BadgesRepository._internal();

  Future<List<Badge>> getBadges({required String userId}) async {
    try {
      List<Badge> badges = [];
      final badgesResult = await _badgesRemoteDataSource.getBadges(userId: userId);

      //get badges
      badgeTypes.forEach((element) {
        print(badgesResult[element]);
        badges.add(Badge.fromJson(Map.from(badgesResult[element])));
      });

      return badges;
    } catch (e) {
      throw BadgesException(errorMessageCode: e.toString());
    }
  }

  Future<void> setBadge({required String userId, required String badgeType}) async {
    try {
      await _badgesRemoteDataSource.setBadges(userId: userId, badgeType: badgeType);
    } catch (e) {
      print("Error while updating badge");
      print(e.toString());
    }
  }
}
