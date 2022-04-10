class BattleRoomException implements Exception {
  final String? errorMessageCode;

  BattleRoomException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode!;
}
