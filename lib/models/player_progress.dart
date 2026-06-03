class PlayerProgress {
  final int totalXp;
  final Map<String, int> bestScoresByLevel;
  final Set<String> unlockedAchievements;
  final String playerName;
  final String selectedAvatarId;
  final bool hasNoAds;
  final bool hasPremium;
  final String selectedLanguageCode;
  final bool soundEnabled;
  final bool musicEnabled;

  // Daily login / streak tracking
  final String? lastLoginDate;
  final int dailyLoginStreak;

  // Daily challenge tracking
  final String? lastDailyChallengeDate;

  // Avatar frames
  final Set<String> unlockedAvatarFrameIds;
  final String selectedAvatarFrameId;

  const PlayerProgress({
    required this.totalXp,
    required this.bestScoresByLevel,
    required this.unlockedAchievements,
    required this.playerName,
    required this.selectedAvatarId,
    required this.hasNoAds,
    required this.hasPremium,
    required this.selectedLanguageCode,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.lastLoginDate,
    required this.dailyLoginStreak,
    required this.lastDailyChallengeDate,
    required this.unlockedAvatarFrameIds,
    required this.selectedAvatarFrameId,
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
      selectedLanguageCode: 'en',
      soundEnabled: true,
      musicEnabled: true,
      lastLoginDate: null,
      dailyLoginStreak: 0,
      lastDailyChallengeDate: null,
      unlockedAvatarFrameIds: {'none'},
      selectedAvatarFrameId: 'none',
    );
  }

  static String todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '${now.year}-$month-$day';
  }

  static String yesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final month = yesterday.month.toString().padLeft(2, '0');
    final day = yesterday.day.toString().padLeft(2, '0');

    return '${yesterday.year}-$month-$day';
  }

  bool get hasCompletedDailyChallengeToday {
    return lastDailyChallengeDate == todayKey();
  }

  bool get adsRemoved {
    return hasNoAds || hasPremium;
  }

  PlayerProgress copyWith({
    int? totalXp,
    Map<String, int>? bestScoresByLevel,
    Set<String>? unlockedAchievements,
    String? playerName,
    String? selectedAvatarId,
    bool? hasNoAds,
    bool? hasPremium,
    String? selectedLanguageCode,
    bool? soundEnabled,
    bool? musicEnabled,
    String? lastLoginDate,
    int? dailyLoginStreak,
    String? lastDailyChallengeDate,
    Set<String>? unlockedAvatarFrameIds,
    String? selectedAvatarFrameId,
  }) {
    return PlayerProgress(
      totalXp: totalXp ?? this.totalXp,
      bestScoresByLevel: bestScoresByLevel ?? this.bestScoresByLevel,
      unlockedAchievements:
          unlockedAchievements ?? this.unlockedAchievements,
      playerName: playerName ?? this.playerName,
      selectedAvatarId: selectedAvatarId ?? this.selectedAvatarId,
      hasNoAds: hasNoAds ?? this.hasNoAds,
      hasPremium: hasPremium ?? this.hasPremium,
      selectedLanguageCode:
          selectedLanguageCode ?? this.selectedLanguageCode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      dailyLoginStreak: dailyLoginStreak ?? this.dailyLoginStreak,
      lastDailyChallengeDate:
          lastDailyChallengeDate ?? this.lastDailyChallengeDate,
      unlockedAvatarFrameIds:
          unlockedAvatarFrameIds ?? this.unlockedAvatarFrameIds,
      selectedAvatarFrameId:
          selectedAvatarFrameId ?? this.selectedAvatarFrameId,
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

  PlayerProgress addXp(int xp) {
    return copyWith(
      totalXp: totalXp + xp,
    );
  }

  PlayerProgress markDailyChallengeCompleted() {
    return copyWith(
      lastDailyChallengeDate: todayKey(),
    );
  }

  PlayerProgress recordDailyLogin() {
    final today = todayKey();

    if (lastLoginDate == today) {
      return this;
    }

    final newStreak = lastLoginDate == yesterdayKey()
        ? dailyLoginStreak + 1
        : 1;

    return copyWith(
      lastLoginDate: today,
      dailyLoginStreak: newStreak,
    );
  }

  PlayerProgress unlockAvatarFrame(String frameId) {
    return copyWith(
      unlockedAvatarFrameIds: {
        ...unlockedAvatarFrameIds,
        frameId,
      },
      selectedAvatarFrameId: frameId,
    );
  }

  PlayerProgress selectAvatarFrame(String frameId) {
    final isAlwaysAvailable = frameId == 'none';
    final isUnlockedRewardFrame = unlockedAvatarFrameIds.contains(frameId);
    final isPremiumFrame = frameId == 'premium_gold' && hasPremium;

    if (!isAlwaysAvailable && !isUnlockedRewardFrame && !isPremiumFrame) {
      return this;
    }

    return copyWith(
      selectedAvatarFrameId: frameId,
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
      'selectedLanguageCode': selectedLanguageCode,
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'lastLoginDate': lastLoginDate,
      'dailyLoginStreak': dailyLoginStreak,
      'lastDailyChallengeDate': lastDailyChallengeDate,
      'unlockedAvatarFrameIds': unlockedAvatarFrameIds.toList(),
      'selectedAvatarFrameId': selectedAvatarFrameId,
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
      selectedLanguageCode:
          json['selectedLanguageCode'] as String? ?? 'en',
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      lastLoginDate: json['lastLoginDate'] as String?,
      dailyLoginStreak: json['dailyLoginStreak'] as int? ?? 0,
      lastDailyChallengeDate:
          json['lastDailyChallengeDate'] as String?,
      unlockedAvatarFrameIds: Set<String>.from(
        json['unlockedAvatarFrameIds'] as List? ?? ['none'],
      ),
      selectedAvatarFrameId:
          json['selectedAvatarFrameId'] as String? ?? 'none',
    );
  }
}