import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../data/campaign_levels.dart';
import '../data/constellation_data.dart';
import '../models/campaign_level.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';
import 'match_challenge_screen.dart';
import 'mythology_quiz_screen.dart';
import 'premium_screen.dart';
import 'quiz_screen.dart';

class CampaignScreen extends StatelessWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const CampaignScreen({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
  });

  String text(String key) {
    return AppText.get(progress.selectedLanguageCode, key);
  }

  String translatedLevelTitle(CampaignLevel level) {
    return text('level${level.levelNumber}Title');
  }

  int expectedQuestionsForLevel(CampaignLevel level) {
    return min(5, level.constellations.length);
  }

  bool isLevelUnlocked(CampaignLevel level) {
    if (level.levelNumber == 1) {
      return true;
    }

    final hasRequiredXp = progress.totalXp >= level.requiredXp;

    final previousLevelId = level.previousLevelId;
    final previousLevel = previousLevelId == null
        ? null
        : campaignLevels.where((item) => item.id == previousLevelId).firstOrNull;

    final hasPerfectPreviousLevel = previousLevel != null &&
        progress.hasPerfectScore(
          levelId: previousLevel.id,
          totalQuestions: expectedQuestionsForLevel(previousLevel),
        );

    return hasRequiredXp || hasPerfectPreviousLevel;
  }

  bool hasGoldAward(CampaignLevel level) {
    return progress.hasGoldAward(
      level.id,
      expectedQuestionsForLevel(level),
    );
  }

  int campaignGoldAwardCount() {
    return campaignLevels.where((level) {
      final totalQuestions = expectedQuestionsForLevel(level);
      return progress.hasGoldAward(level.id, totalQuestions);
    }).length;
  }

  int latestUnlockedLevelNumber() {
    int latest = 1;

    for (final level in campaignLevels) {
      if (isLevelUnlocked(level)) {
        latest = level.levelNumber;
      }
    }

    return latest;
  }

  void startLevel(BuildContext context, CampaignLevel level) {
    StellaAudioService.playButtonTap();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LevelModeSheet(
        level: level,
        languageCode: progress.selectedLanguageCode,
        onClassicTap: () {
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(
                level: level,
                progress: progress,
                onProgressUpdated: onProgressUpdated,
              ),
            ),
          );
        },
        onMythologyTap: () {
          Navigator.pop(context);

          if (!progress.hasPremium) {
            openPremiumMenu(context);
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MythologyQuizScreen(
                level: level,
                progress: progress,
                onProgressUpdated: onProgressUpdated,
              ),
            ),
          );
        },
        onAll88Tap: () {
          Navigator.pop(context);

          if (!progress.hasPremium) {
            openPremiumMenu(context);
            return;
          }

          final all88Level = CampaignLevel(
            id: 'all_88_challenge',
            title: 'All 88 Challenge',
            description: 'Master every official constellation.',
            levelNumber: 88,
            requiredXp: 0,
            previousLevelId: null,
            constellations: allConstellations,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(
                level: all88Level,
                progress: progress,
                onProgressUpdated: onProgressUpdated,
              ),
            ),
          );
        },
        onMatchModeTap: () {
          Navigator.pop(context);

          if (!progress.hasPremium) {
            openPremiumMenu(context);
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MatchChallengeScreen(
                titleKey: 'matchMode',
                constellations: level.constellations,
                progress: progress,
                campaignLevel: level,
                onProgressUpdated: onProgressUpdated,
                countForCampaignProgress: true,
              ),
            ),
          );
        },
      ),
    );
  }

  void openPremiumMenu(BuildContext context) {
    StellaAudioService.playButtonTap();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PremiumScreen(
        languageCode: progress.selectedLanguageCode,
        progress: progress,
        onProgressUpdated: onProgressUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestUnlocked = latestUnlockedLevelNumber();

    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              text('campaign'),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD98A),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.bolt,
                  color: Color(0xFFFFD98A),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${progress.totalXp} ${text('xp')}',
                  style: const TextStyle(
                    color: Color(0xFFFFD98A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 18),
                const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFFFD98A),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${campaignGoldAwardCount()} ${text('gold')}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              text('campaignDescription'),
              style: const TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            ...campaignLevels.map((level) {
              final unlocked = isLevelUnlocked(level);
              final gold = hasGoldAward(level);
              final isCurrent = unlocked && level.levelNumber == latestUnlocked;
              final alignLeft = level.levelNumber.isOdd;

              return _CampaignMapNode(
                level: level,
                unlocked: unlocked,
                gold: gold,
                isCurrent: isCurrent,
                alignLeft: alignLeft,
                bestScore: progress.bestScoresByLevel[level.id] ?? 0,
                totalQuestions: expectedQuestionsForLevel(level),
                languageCode: progress.selectedLanguageCode,
                translatedTitle: translatedLevelTitle(level),
                onTap: unlocked ? () => startLevel(context, level) : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LevelModeSheet extends StatelessWidget {
  final CampaignLevel level;
  final String languageCode;
  final VoidCallback onClassicTap;
  final VoidCallback onMythologyTap;
  final VoidCallback onAll88Tap;
  final VoidCallback onMatchModeTap;

  const _LevelModeSheet({
    required this.level,
    required this.languageCode,
    required this.onClassicTap,
    required this.onMythologyTap,
    required this.onAll88Tap,
    required this.onMatchModeTap,
  });

  String text(String key) {
    return AppText.get(languageCode, key);
  }

  String translatedLevelTitle() {
    return AppText.get(languageCode, 'level${level.levelNumber}Title');
  }

  @override
  Widget build(BuildContext context) {
    final constellationCount = level.constellations.length;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF071426),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      translatedLevelTitle(),
                      style: const TextStyle(
                        color: Color(0xFFFFD98A),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      StellaAudioService.playButtonTap();
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                '$constellationCount ${text('availableInLevel')}',
                style: const TextStyle(
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                text('chooseQuizMode'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              _LevelModeOption(
                title: text('classicQuiz'),
                subtitle: text('classicQuizSubtitle'),
                icon: Icons.auto_awesome,
                premium: false,
                onTap: onClassicTap,
              ),

              const SizedBox(height: 12),

              _LevelModeOption(
                title: text('mythology'),
                subtitle: text('mythologySubtitle'),
                icon: Icons.menu_book,
                premium: true,
                onTap: onMythologyTap,
              ),

              const SizedBox(height: 12),

              _LevelModeOption(
                title: text('all88Challenge'),
                subtitle: text('all88ChallengeSubtitle'),
                icon: Icons.public,
                premium: true,
                onTap: onAll88Tap,
              ),

              const SizedBox(height: 12),

              _LevelModeOption(
                title: text('matchMode'),
                subtitle: text('matchModeSubtitle'),
                icon: Icons.grid_view,
                premium: true,
                onTap: onMatchModeTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelModeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool premium;
  final VoidCallback onTap;

  const _LevelModeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.premium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: premium ? const Color(0xFF132B46) : const Color(0xFF10243B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: premium
              ? const Color(0x55FFD98A)
              : const Color(0x223A5B80),
        ),
      ),
      child: InkWell(
        onTap: () {
          StellaAudioService.playButtonTap();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFFD98A),
                size: 30,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (premium) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.workspace_premium,
                            color: Color(0xFFFFD98A),
                            size: 16,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color:
                            premium ? const Color(0xFFFFD98A) : Colors.white60,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampaignMapNode extends StatelessWidget {
  final CampaignLevel level;
  final bool unlocked;
  final bool gold;
  final bool isCurrent;
  final bool alignLeft;
  final int bestScore;
  final int totalQuestions;
  final String languageCode;
  final String translatedTitle;
  final VoidCallback? onTap;

  const _CampaignMapNode({
    required this.level,
    required this.unlocked,
    required this.gold,
    required this.isCurrent,
    required this.alignLeft,
    required this.bestScore,
    required this.totalQuestions,
    required this.languageCode,
    required this.translatedTitle,
    this.onTap,
  });

  String text(String key) {
    return AppText.get(languageCode, key);
  }

  @override
  Widget build(BuildContext context) {
    final constellationCount = level.constellations.length;

    final statusText = gold
        ? '${text('goldAward')} • ${text('perfectScore')}'
        : unlocked
            ? '${text('best')}: $bestScore / $totalQuestions • $constellationCount ${text('constellations')}'
            : '${text('locked')} • ${level.requiredXp} ${text('xp')} ${text('or100Previous')}';

    final node = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gold
              ? const Color(0xFF172B3F)
              : unlocked
                  ? const Color(0xFF10243B)
                  : const Color(0xFF081525),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: gold
                ? const Color(0xFFFFD98A)
                : unlocked
                    ? const Color(0x44FFD98A)
                    : const Color(0x223A5B80),
            width: gold ? 2 : 1,
          ),
          boxShadow: gold
              ? const [
                  BoxShadow(
                    color: Color(0x33FFD98A),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 29,
                  backgroundColor: gold
                      ? const Color(0xFFFFD98A)
                      : unlocked
                          ? const Color(0xFF233A55)
                          : const Color(0xFF0D1A2B),
                  child: Icon(
                    gold
                        ? Icons.workspace_premium
                        : unlocked
                            ? Icons.star
                            : Icons.lock_outline,
                    color: gold ? const Color(0xFF071426) : Colors.white70,
                    size: 29,
                  ),
                ),
                if (isCurrent)
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD98A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF071426),
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translatedTitle,
                    style: TextStyle(
                      color: unlocked ? Colors.white : Colors.white38,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: gold
                          ? const Color(0xFFFFD98A)
                          : unlocked
                              ? Colors.white60
                              : Colors.white30,
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: gold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      children: [
        Align(
          alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: node,
        ),

        if (level.levelNumber != campaignLevels.length)
          SizedBox(
            height: 42,
            child: CustomPaint(
              painter: _PathLinePainter(
                alignLeft: alignLeft,
                unlocked: unlocked,
              ),
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

class _PathLinePainter extends CustomPainter {
  final bool alignLeft;
  final bool unlocked;

  const _PathLinePainter({
    required this.alignLeft,
    required this.unlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = unlocked
          ? const Color(0x66FFD98A)
          : const Color(0x223A5B80)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final startX = alignLeft ? size.width * 0.28 : size.width * 0.72;
    final endX = alignLeft ? size.width * 0.72 : size.width * 0.28;

    final path = Path()
      ..moveTo(startX, 0)
      ..cubicTo(
        startX,
        size.height * 0.45,
        endX,
        size.height * 0.55,
        endX,
        size.height,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathLinePainter oldDelegate) {
    return oldDelegate.alignLeft != alignLeft ||
        oldDelegate.unlocked != unlocked;
  }
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }

    return first;
  }
}