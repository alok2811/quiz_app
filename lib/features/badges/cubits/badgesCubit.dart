import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/badges/badge.dart';
import 'package:ayuprep/features/badges/badgesRepository.dart';

abstract class BadgesState {}

class BadgesInitial extends BadgesState {}

class BadgesFetchInProgress extends BadgesState {}

class BadgesFetchSuccess extends BadgesState {
  final List<Badge> badges;

  BadgesFetchSuccess(this.badges);
}

class BadgesFetchFailure extends BadgesState {
  final String errorMessage;

  BadgesFetchFailure(this.errorMessage);
}

class BadgesCubit extends Cubit<BadgesState> {
  final BadgesRepository badgesRepository;
  BadgesCubit(this.badgesRepository) : super(BadgesInitial());

  void updateState(BadgesState updatedState) {
    emit(updatedState);
  }

  void getBadges({required String userId, bool? refreshBadges}) async {
    bool callRefreshBadge = refreshBadges ?? false;
    emit(BadgesFetchInProgress());
    badgesRepository.getBadges(userId: userId).then((value) {
      //call this
      if (!callRefreshBadge) {
        setBadge(badgeType: "streak", userId: userId);
      }
      emit(BadgesFetchSuccess(value));
    }).catchError((e) {
      emit(BadgesFetchFailure(e.toString()));
    });
  }

  //update badges
  void _updateBadge(String badgeType, String status) {
    if (state is BadgesFetchSuccess) {
      List<Badge> currentBadges = (state as BadgesFetchSuccess).badges;
      List<Badge> updatedBadges = List.from(currentBadges);
      int badgeIndex = currentBadges.indexWhere((element) => element.type == badgeType);
      updatedBadges[badgeIndex] = currentBadges[badgeIndex].copyWith(updatedStatus: status);
      emit(BadgesFetchSuccess(updatedBadges));
    }
  }

  void unlockBadge(String badgeType) {
    _updateBadge(badgeType, "1");
  }

  void unlockReward(String badgeType) {
    _updateBadge(badgeType, "2");
  }

  //
  bool isBadgeLocked(String badgeType) {
    if (state is BadgesFetchSuccess) {
      final badge = (state as BadgesFetchSuccess).badges.where((element) => element.type == badgeType).toList().first;
      return badge.status == "0";
    }
    return true;
  }

  List<Badge> getUnlockedBadges() {
    if (state is BadgesFetchSuccess) {
      return (state as BadgesFetchSuccess).badges.where((element) => element.status != "0").toList();
    }
    return [];
  }

  bool isRewardUnlocked(String badgeType) {
    if (state is BadgesFetchSuccess) {
      final badge = (state as BadgesFetchSuccess).badges.where((element) => element.type == badgeType).toList().first;
      return badge.status == "2";
    }
    return true;
  }

  void setBadge({required String badgeType, required String userId}) async {
    badgesRepository.setBadge(userId: userId, badgeType: badgeType);
  }

  List<Badge> getAllBadges() {
    if (state is BadgesFetchSuccess) {
      return (state as BadgesFetchSuccess).badges;
    }
    return [];
  }

  int getBadgeCounterByType(String type) {
    if (state is BadgesFetchSuccess) {
      final badges = (state as BadgesFetchSuccess).badges;
      return int.parse(badges[badges.indexWhere((element) => element.type == type)].badgeCounter);
    }
    return -1;
  }

  List<Badge> getRewards() {
    List<Badge> rewards = getAllBadges().where((element) => element.status != "0").toList();
    List<Badge> scratchedRewards = rewards.where((element) => element.status == "2").toList();
    List<Badge> unscratchedRewards = rewards.where((element) => element.status == "1").toList();
    unscratchedRewards.addAll(scratchedRewards);
    return unscratchedRewards;
  }

  int getRewardedCoins() {
    final rewards = getRewards();
    int totalCoins = 0;
    rewards.forEach((element) {
      if (element.status == "2") {
        totalCoins = int.parse(element.badgeReward) + totalCoins;
      }
    });

    return totalCoins;
  }
}
