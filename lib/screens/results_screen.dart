import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../data/app_text.dart';
import '../data/campaign_levels.dart';
import '../models/achievement.dart';
import '../models/campaign_level.dart';
import '../models/player_progress.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../widgets/achievement_popup.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';
import '../services/interstitial_ad_service.dart';

class ResultsScreen extends StatefulWidget {
  final CampaignLevel level;
  final PlayerProgress progress;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const ResultsScreen({
    super.key,
    required this.level,
    required this.progress,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.onProgressUpdated,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late PlayerProgress visibleProgress;

  String text(String key) {
    return AppText.get(visibleProgress.selectedLanguageCode, key);
  }

  String translatedLevelTitle() {
    if (widget.level.id == 'all_88_challenge') {
      return text('all88Challenge');
    }

    return AppText.get(
      visibleProgress.selectedLanguageCode,
      'level${widget.level.levelNumber}Title',
    );
  }

@override
void initState() {
  super.initState();
  visibleProgress = widget.progress;

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    unlockResultAchievements();

    if (AdService.shouldShowInterstitialAfterLevel(visibleProgress)) {
      await Future.delayed(const Duration(milliseconds: 900));
      await StellaInterstitialAdService.showInterstitialAdIfReady();
    }
  });
}

  int get accuracy {
    return ((widget.score / widget.totalQuestions) * 100).round();
  }

  bool get gotGoldAward {
    return widget.score == widget.totalQuestions;
  }

  void unlockResultAchievements() {
    var updatedProgress = visibleProgress;
    final achievementsToShow = <Achievement>[];

    if (!updatedProgress.hasAchievement(AchievementIds.firstQuiz)) {
      updatedProgress = updatedProgress.unlockAchievement(
        AchievementIds.firstQuiz,
      );
      achievementsToShow.add(firstQuizAchievement);
    }

    if (gotGoldAward &&
        !updatedProgress.hasAchievement(AchievementIds.goldStargazer)) {
      updatedProgress = updatedProgress.unlockAchievement(
        AchievementIds.goldStargazer,
      );
      achievementsToShow.add(goldStargazerAchievement);
    }

    final totalCampaignLevels = campaignLevels.length;

    final goldAwards = campaignLevels.where((level) {
      final totalQuestions =
          level.constellations.length < 5 ? level.constellations.length : 5;

      return updatedProgress.hasGoldAward(level.id, totalQuestions);
    }).length;

    if (goldAwards == totalCampaignLevels &&
        !updatedProgress.hasAchievement(AchievementIds.diamondSkyMaster)) {
      updatedProgress = updatedProgress.unlockAchievement(
        AchievementIds.diamondSkyMaster,
      );
      achievementsToShow.add(diamondSkyMasterAchievement);
    }

    if (updatedProgress != visibleProgress) {
      setState(() {
        visibleProgress = updatedProgress;
      });

      widget.onProgressUpdated(updatedProgress);
    }

    for (final achievement in achievementsToShow) {
      showAchievementPopup(
        context,
        achievement,
        languageCode: visibleProgress.selectedLanguageCode,
      );
    }
  }

  void retryQuiz() {
    StellaAudioService.playButtonTap();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          level: widget.level,
          progress: visibleProgress,
          onProgressUpdated: widget.onProgressUpdated,
        ),
      ),
    );
  }

  void backToCampaign() {
    StellaAudioService.playButtonTap();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StellaGradientScaffold(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              const SizedBox(height: 28),

              Text(
                gotGoldAward ? text('goldAwardEarned') : text('quizComplete'),
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                translatedLevelTitle(),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              if (gotGoldAward)
                Card(
                  color: const Color(0xFF10243B),
                  margin: const EdgeInsets.only(bottom: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(
                      color: Color(0xFFFFD98A),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Color(0xFFFFD98A),
                          size: 42,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                text('goldAward'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                text('perfectScore'),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              _ResultCard(
                title: text('score'),
                value: '${widget.score} / ${widget.totalQuestions}',
                icon: Icons.check_circle_outline,
              ),
              _ResultCard(
                title: text('accuracy'),
                value: '$accuracy%',
                icon: Icons.analytics_outlined,
              ),
              _ResultCard(
                title: text('xpEarned'),
                value: '+${widget.xpEarned} ${text('xp')}',
                icon: Icons.bolt,
              ),
              _ResultCard(
                title: text('totalXp'),
                value: '${visibleProgress.totalXp} ${text('xp')}',
                icon: Icons.workspace_premium_outlined,
              ),
              _ResultCard(
                title: text('goldAwards'),
                value: '${visibleProgress.goldAwardCount(widget.totalQuestions)}',
                icon: Icons.emoji_events_outlined,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: retryQuiz,
                  child: Text(text('tryAgain')),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: backToCampaign,
                  child: Text(text('backToCampaign')),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ResultCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF10243B),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0x223A5B80)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFFFFD98A),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}