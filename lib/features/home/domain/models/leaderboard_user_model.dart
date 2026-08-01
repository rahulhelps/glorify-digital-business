class LeaderboardUserModel {
  final String uid;
  final String name;
  final String profileImageUrl;
  final int rankCount;
  final bool isDemo;

  LeaderboardUserModel({
    required this.uid,
    required this.name,
    required this.profileImageUrl,
    required this.rankCount,
    this.isDemo = false,
  });

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json, String uid) {
    return LeaderboardUserModel(
      uid: uid,
      name: json['name'] ?? 'Unknown',
      profileImageUrl: json['profileImageUrl'] ?? '',
      rankCount: json['rankCount'] ?? 0,
    );
  }
}
