class PlayerProgress {
  final int totalXp;
  final Map<String, int> bestScoresByLevel;

  const PlayerProgress({
    required this.totalXp,
    required this.bestScoresByLevel,
  });

  factory PlayerProgress.initial() {
    return const PlayerProgress(
      totalXp: 0,
      bestScoresByLevel: {},
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

    return PlayerProgress(
      totalXp: totalXp + xpEarned,
      bestScoresByLevel: {
        ...bestScoresByLevel,
        levelId: newBestScore,
      },
    );
  }

  bool hasPerfectScore({
    required String levelId,
    required int totalQuestions,
  }) {
    return bestScoresByLevel[levelId] == totalQuestions;
  }
}