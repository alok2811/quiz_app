import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayuprep/features/quiz/models/userBattleRoomDetails.dart';

class BattleRoom {
  final String? roomId;
  final String? categoryId;
  final String? createdBy;
  final String? languageId;

  final UserBattleRoomDetails? user1;
  //it will be in use for multiUserBattleRoom
  //user1 will be the creator of this room
  final UserBattleRoomDetails? user2; //it will be in use for multiUserBattleRoom
  final UserBattleRoomDetails? user3; //it will be in use for multiUserBattleRoom
  final UserBattleRoomDetails? user4; //it will be in use for multiUserBattleRoom
  final int? entryFee; //it will be in use for multiUserBattleRoom
  final String? roomCode; //it will be in use for multiUserBattleRoom
  final bool? readyToPlay; //it will be in use for multiUserBattleRoom

  BattleRoom({this.roomId, this.categoryId, this.user1, this.user2, this.createdBy, this.readyToPlay, this.roomCode, this.user3, this.user4, this.entryFee, this.languageId});

  static BattleRoom fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;
    return BattleRoom(
      languageId: data['languageId'] ?? "",
      categoryId: data['categoryId'] ?? "",
      createdBy: data['createdBy'],
      roomId: documentSnapshot.id,
      readyToPlay: data['readyToPlay'] ?? false,
      entryFee: data['entryFee'] ?? 0,
      roomCode: data['roomCode'] ?? "",
      user3: UserBattleRoomDetails.fromJson(Map.from(data['user3'] ?? {})),
      user4: UserBattleRoomDetails.fromJson(Map.from(data['user4'] ?? {})),
      user1: UserBattleRoomDetails.fromJson(Map.from(data['user1'])),
      user2: UserBattleRoomDetails.fromJson(Map.from(data['user2'])),
    );
  }

  BattleRoom copyWih({String? categoryId}) {
    return BattleRoom(
      categoryId: categoryId ?? this.categoryId,
      roomId: this.roomId,
      createdBy: this.createdBy,
      user1: this.user1,
      user2: this.user2,
      languageId: this.languageId,
    );
  }
}
