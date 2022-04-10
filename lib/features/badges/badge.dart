class Badge {
  Badge({
    required this.id,
    required this.type,
    required this.badgeLabel,
    required this.badgeNote,
    required this.badgeReward,
    required this.badgeIcon,
    required this.badgeCounter,
    required this.status,
  });
  late final String id;
  late final String type;
  late final String badgeLabel;
  late final String badgeNote;
  late final String badgeReward;
  late final String badgeIcon;
  late final String badgeCounter;
  late final String status;

  Badge.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    type = json['type'] ?? "";
    badgeLabel = json['badge_label'] ?? "";
    badgeNote = json['badge_note'] ?? "";
    badgeReward = json['badge_reward'] ?? "";
    badgeIcon = json['badge_icon'] ?? "";
    badgeCounter = json['badge_counter'] ?? "";
    status = json['status'] ?? "0";
  }

  Badge copyWith({String? updatedStatus}) {
    return Badge(
      id: id,
      type: type,
      badgeLabel: badgeLabel,
      badgeNote: badgeNote,
      badgeReward: badgeReward,
      badgeIcon: badgeIcon,
      badgeCounter: badgeCounter,
      status: updatedStatus ?? this.status,
    );
  }
}
