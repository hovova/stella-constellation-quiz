import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../data/app_text.dart';
import '../data/campaign_levels.dart';
import '../models/achievement.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';

class AchievementsScreen extends StatelessWidget {
  final PlayerProgress progress;

  const AchievementsScreen({
    super.key,
    required this.progress,
  });

  String text(String key) {
    return AppText.get(progress.selectedLanguageCode, key);
  }

  String achievementTitle(Achievement achievement) {
    switch (achievement.id) {
      case AchievementIds.firstLogin:
        return text('firstLoginTitle');
      case AchievementIds.firstQuiz:
        return text('firstQuizTitle');
      case AchievementIds.goldStargazer:
        return text('goldStargazerTitle');
      case AchievementIds.diamondSkyMaster:
        return text('diamondSkyMasterTitle');
      case AchievementIds.sevenDayLogin:
        return text('sevenDayLoginTitle');
      default:
        return achievement.title;
    }
  }

  String achievementDescription(Achievement achievement) {
    switch (achievement.id) {
      case AchievementIds.firstLogin:
        return text('firstLoginDescription');
      case AchievementIds.firstQuiz:
        return text('firstQuizDescription');
      case AchievementIds.goldStargazer:
        return text('goldStargazerDescription');
      case AchievementIds.diamondSkyMaster:
        return text('diamondSkyMasterDescription');
      case AchievementIds.sevenDayLogin:
        return text('sevenDayLoginDescription');
      default:
        return achievement.description;
    }
  }

  bool shouldShowProgressBar(Achievement achievement) {
    return achievement.id == AchievementIds.sevenDayLogin ||
        achievement.id == AchievementIds.diamondSkyMaster;
  }

  double achievementProgressValue(Achievement achievement) {
    if (achievement.id == AchievementIds.sevenDayLogin) {
      return progress.dailyLoginStreak.clamp(0, 7) / 7;
    }

    if (achievement.id == AchievementIds.diamondSkyMaster) {
      final totalLevels = campaignLevels.length;

      if (totalLevels == 0) {
        return 0;
      }

      final goldAwards = campaignLevels.where((level) {
        final totalQuestions = level.constellations.length < 5
            ? level.constellations.length
            : 5;

        return progress.hasGoldAward(level.id, totalQuestions);
      }).length;

      return goldAwards / totalLevels;
    }

    return progress.hasAchievement(achievement.id) ? 1 : 0;
  }

  String achievementProgressText(Achievement achievement) {
    if (achievement.id == AchievementIds.sevenDayLogin) {
      final streak = progress.dailyLoginStreak.clamp(0, 7);
      return '$streak / 7';
    }

    if (achievement.id == AchievementIds.diamondSkyMaster) {
      final totalLevels = campaignLevels.length;

      final goldAwards = campaignLevels.where((level) {
        final totalQuestions = level.constellations.length < 5
            ? level.constellations.length
            : 5;

        return progress.hasGoldAward(level.id, totalQuestions);
      }).length;

      return '$goldAwards / $totalLevels';
    }

    return progress.hasAchievement(achievement.id) ? '1 / 1' : '0 / 1';
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = progress.unlockedAchievements.length;

    return Scaffold(
      body: StellaGradientScaffold(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              IconButton(
                alignment: Alignment.centerLeft,
                onPressed: () {
                  StellaAudioService.playButtonTap();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 16),

              Text(
                text('achievementsTitle'),
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '$unlockedCount / ${allAchievements.length} ${text('unlocked')}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 28),

              ...allAchievements.map((achievement) {
                final unlocked =
                    progress.unlockedAchievements.contains(achievement.id);

                return Card(
                  color: unlocked
                      ? const Color(0xFF10243B)
                      : const Color(0x99081422),
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: unlocked
                          ? const Color(0x77FFD98A)
                          : const Color(0x113A5B80),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.emoji,
                          style: TextStyle(
                            fontSize: 30,
                            color: unlocked ? Colors.white : Colors.white24,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      achievementTitle(achievement),
                                      style: TextStyle(
                                        color: unlocked
                                            ? Colors.white
                                            : Colors.white24,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    unlocked
                                        ? Icons.check_circle
                                        : Icons.lock_outline,
                                    color: unlocked
                                        ? const Color(0xFFFFD98A)
                                        : Colors.white38,
                                    size: 22,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Text(
                                achievementDescription(achievement),
                                style: TextStyle(
                                  color: unlocked
                                      ? Colors.white60
                                      : Colors.white24,
                                  height: 1.35,
                                  fontSize: 13,
                                ),
                              ),

                              if (shouldShowProgressBar(achievement)) ...[
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        child: LinearProgressIndicator(
                                          value: achievementProgressValue(
                                            achievement,
                                          ),
                                          minHeight: 8,
                                          backgroundColor:
                                              const Color(0xFF071426),
                                          color: unlocked
                                              ? const Color(0xFFFFD98A)
                                              : const Color(0xFF8EA0B8),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Text(
                                      achievementProgressText(achievement),
                                      style: TextStyle(
                                        color: unlocked
                                            ? const Color(0xFFFFD98A)
                                            : Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}