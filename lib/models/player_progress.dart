class PlayerProgress {
  final int totalXp;
  final Map<String, int> bestScoresByLevel;
  final Set<String> unlockedAchievements;
  final String playerName;
  final String selectedAvatarId;
  final bool hasNoAds;
  final bool hasPremium;

  const PlayerProgress({
    required this.totalXp,
    required this.bestScoresByLevel,
    required this.unlockedAchievements,
    required this.playerName,
    required this.selectedAvatarId,
    required this.hasNoAds,
    required this.hasPremium,
  });

  factory PlayerProgress.initial() {
    return const PlayerProgress(
      totalXp: 0,
      bestScoresByLevel: {},
      unlockedAchievements: {},
      playerName: 'Stargazer',
      selectedAvatarId: 'star',
      hasNoAds: false,
      hasPremium: false,
    );
  }

  PlayerProgress copyWith({
    int? totalXp,
    Map<String, int>? bestScoresByLevel,
    Set<String>? unlockedAchievements,
    String? playerName,
    String? selectedAvatarId,
    bool? hasNoAds,
    bool? hasPremium,
  }) {
    return PlayerProgress(
      totalXp: totalXp ?? this.totalXp,
      bestScoresByLevel: bestScoresByLevel ?? this.bestScoresByLevel,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      playerName: playerName ?? this.playerName,
      selectedAvatarId: selectedAvatarId ?? this.selectedAvatarId,
      hasNoAds: hasNoAds ?? this.hasNoAds,
      hasPremium: hasPremium ?? this.hasPremium,
    );
  }

  PlayerProgress addQuizResult({
    required String levelId,
    required int score,
    required int totalQuestions,
    required int xpEarned,
  }) {
    final currentBestScore = bestScoresByLevel[levelId] ?? 0;
    final newBestScore = score > currentBestScore ? score : currentBestScore;

    return copyWith(
      totalXp: totalXp + xpEarned,
      bestScoresByLevel: {
        ...bestScoresByLevel,
        levelId: newBestScore,
      },
    );
  }

  PlayerProgress unlockAchievement(String achievementId) {
    return copyWith(
      unlockedAchievements: {
        ...unlockedAchievements,
        achievementId,
      },
    );
  }

  bool hasAchievement(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }

  bool hasPerfectScore({
    required String levelId,
    required int totalQuestions,
  }) {
    return bestScoresByLevel[levelId] == totalQuestions;
  }

  bool hasGoldAward(String levelId, int totalQuestions) {
    return hasPerfectScore(
      levelId: levelId,
      totalQuestions: totalQuestions,
    );
  }

  int goldAwardCount(int totalQuestions) {
    return bestScoresByLevel.values
        .where((score) => score == totalQuestions)
        .length;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
      'bestScoresByLevel': bestScoresByLevel,
      'unlockedAchievements': unlockedAchievements.toList(),
      'playerName': playerName,
      'selectedAvatarId': selectedAvatarId,
      'hasNoAds': hasNoAds,
      'hasPremium': hasPremium,
    };
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      totalXp: json['totalXp'] as int? ?? 0,
      bestScoresByLevel: Map<String, int>.from(
        json['bestScoresByLevel'] as Map? ?? {},
      ),
      unlockedAchievements: Set<String>.from(
        json['unlockedAchievements'] as List? ?? [],
      ),
      playerName: json['playerName'] as String? ?? 'Stargazer',
      selectedAvatarId: json['selectedAvatarId'] as String? ?? 'star',
      hasNoAds: json['hasNoAds'] as bool? ?? false,
      hasPremium: json['hasPremium'] as bool? ?? false,
    );
  }
}