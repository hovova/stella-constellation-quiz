class PlayerProgress {
  final int totalXp;
  final Map<String, int> bestScoresByLevel;
  final Set<String> unlockedAchievements;

  const PlayerProgress({
    required this.totalXp,
    required this.bestScoresByLevel,
    required this.unlockedAchievements,
  });

  factory PlayerProgress.initial() {
    return const PlayerProgress(
      totalXp: 0,
      bestScoresByLevel: {},
      unlockedAchievements: {},
    );
  }

  PlayerProgress copyWith({
    int? totalXp,
    Map<String, int>? bestScoresByLevel,
    Set<String>? unlockedAchievements,
  }) {
    return PlayerProgress(
      totalXp: totalXp ?? this.totalXp,
      bestScoresByLevel: bestScoresByLevel ?? this.bestScoresByLevel,
      unlockedAchievements:
          unlockedAchievements ?? this.unlockedAchievements,
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
}